package com.example.pixelfree_camera

import android.app.Activity
import android.content.Context
import android.graphics.*
import android.hardware.camera2.*
import android.hardware.camera2.params.StreamConfigurationMap
import android.os.Environment
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import android.util.Range
import android.util.Size
import android.view.Display
import android.view.Surface
import android.hardware.display.DisplayManager
import androidx.camera.camera2.interop.Camera2CameraInfo
import androidx.camera.camera2.interop.Camera2Interop
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.exifinterface.media.ExifInterface
import com.google.mediapipe.solutioncore.CameraInput
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import io.flutter.view.TextureRegistry
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.CountDownLatch
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Camera pipeline built on **CameraX** ([ProcessCameraProvider]): Preview + [ImageAnalysis] + [ImageCapture],
 * wired to [GlPreviewRenderer] for Flutter [TextureRegistry] output, beauty, AR, and GL-based recording.
 * Live preview pixels are driven by **[ImageAnalysis]** ([PreparedFaceFrame.sensorArgb]) so face mesh and display
 * share one frame; Preview OES is fallback only ([GlPreviewRenderer.requestPreviewOesFrame]).
 * Camera characteristics / still JPEG orientation still use **Camera2** APIs where needed; the live
 * session is not [android.hardware.camera2.CameraDevice].
 */
class CameraXEngine(
    private val context: Context,
    private val textureRegistry: TextureRegistry,
    private val activityProvider: () -> Activity? = { null },
    private val onFaceOverlay: ((Map<String, Double>) -> Unit)? = null,
    private val onFrontFlashHint: ((Boolean, Double) -> Unit)? = null,
) {
    private val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private val photoEffectProcessor = PhotoEffectProcessor()
    private var glPreviewRenderer: GlPreviewRenderer? = null
    private val faceTracker = FaceTracker()
    /** Shared between GL, ML Kit fallback, and MediaPipe — never null after [openCamera] allocates it. */
    private var faceLandmarkKalman: LandmarkKalmanFilter? = null
    @Volatile private var mediaPipeTracker: MediaPipeFaceTracker? = null
    /** Official MediaPipe [CameraInput] + [FaceMesh.getGlContext] — excludes CameraX Preview/ImageAnalysis for the same lens. */
    private var cameraInput: CameraInput? = null
    @Volatile private var useFaceMeshCameraInputPipeline: Boolean = false
    private var selfieSegmentationHelper: SelfieSegmentationHelper? = null
    private var subjectSegmentationHelper: SubjectSegmentationHelper? = null
    /** Official Solutions [com.google.mediapipe.solutions.facemesh.FaceMesh] runs on [cameraExecutor] (sync per frame). */
    private val mediaPipeInitLock = Any()
    @Volatile private var mediaPipeInitFailed = false
    private var faceDiagFrameCount = 0
    /** Latest face/buffer alignment snapshot for [getFaceAlignmentDebug] and optional logcat tag `PixelfreeFaceAlign`. */
    @Volatile private var lastFaceAlignmentDebug: Map<String, Any>? = null
    private var faceAlignLogCounter = 0
    private val mainHandler = Handler(Looper.getMainLooper())
    private var backgroundThread: HandlerThread? = null
    private var backgroundHandler: Handler? = null
    private var cameraExecutor: ExecutorService? = null
    private var processCameraProvider: ProcessCameraProvider? = null
    private var previewUseCase: Preview? = null
    private var imageAnalysis: ImageAnalysis? = null
    private var imageCaptureUseCase: ImageCapture? = null
    private var cameraXLifecycle = CameraEngineLifecycle()
    private var surfaceTextureEntry: TextureRegistry.SurfaceTextureEntry? = null
    private var outputSurface: Surface? = null
    lateinit var surfaceTexture: SurfaceTexture
    private var textureId = 0L
    private var currentRatio = "9:16"
    private var currentFlashMode = "off"
    private var currentCameraId = "0"
    private var currentEnableAudio = true
    private var sensorOrientation = 90
    private var lensFacing = CameraCharacteristics.LENS_FACING_BACK
    private var supportsContinuousAf = false
    private var supportsContinuousVideoAf = false
    private var supportsHdrScene = false
    private var aeAntibandingAuto = false
    private var noiseReductionMode: Int? = null
    private var noiseReductionFastAvailable: Boolean = false
    /** 前置预览用，限制 AE 帧率区间，减轻曝光来回拉扯导致的「时不时闪一下」。 */
    private var previewAeTargetFpsRange: Range<Int>? = null
    private var previewSize: Size? = null
    /** [SurfaceRequest.resolution] after bind — matches ImageAnalysis buffer + GL output (see [GlPreviewRenderer.syncPreviewPipelineSize]). */
    private var previewStreamSize: Size? = null
    private var captureSize: Size? = null
    private var glVideoRecorder: GlSurfaceVideoRecorder? = null
    private var audioRecorder: AudioClipRecorder? = null
    private var recordingVideoTempFile: File? = null
    private var recordingAudioTempFile: File? = null
    /** 与 [GlSurfaceVideoRecorder] / 合并成片共用，保证带音频时 MP4 旋转元数据不丢。 */
    private var lastRecordedVideoOrientationHint: Int = 0
    private var isRecording = false
    private var photoPath: String? = null
    private var videoPath: String? = null
    private var beautySettings: Map<String, Any?> = emptyMap()
    private var filterSettings: Map<String, Any?> = emptyMap()

    // AR effect type (Phase 2: "none", "facemesh", "bigEye", "particles", etc.)
    @Volatile private var currentArEffect: String = "none"

    /** Matches [GlPreviewRenderer.start] mirror flag; used when display rotation changes. */
    private var previewMirrorHorizontal: Boolean = false

    /** Flutter preview area (logical px). Used to pick a capture size whose aspect matches the view (Douyin-style full bleed). */
    private var previewViewportWidth: Double? = null
    private var previewViewportHeight: Double? = null

    private var enableScreenFlashForFront: Boolean = true
    private var gifMaxDurationMs: Int = 5000
    private var recordSpeedProfileName: String = "normal"

    /** One in-flight JPEG still; listener clears after delivery. Prevents overlapping captures crashing the session. */
    private val stillPhotoLock = Any()
    private var stillPhotoCallback: ((String, Int, Int) -> Unit)? = null

    /**
     * Preview Y-plane EMA (0=dark .. 1=bright). Updated when [currentFlashMode] is [auto].
     * Used to skip hardware / screen "flash" in bright scenes.
     */
    @Volatile private var sceneLumaEma: Float = 0.45f
    private var sceneLumaSampleCount: Int = 0
    /** 与 [applyCamera2InteropForStillFlash] 中后置 auto 亮/暗分支同步，避免 Builder 停留在旧 AE 意图。 */
    private var lastRearAutoStillInteropBright: Boolean? = null
    private var rearAutoFlashInteropRebindRunnable: Runnable? = null

    private val displayRotationListener = object : DisplayManager.DisplayListener {
        override fun onDisplayAdded(displayId: Int) {}
        override fun onDisplayRemoved(displayId: Int) {}
        override fun onDisplayChanged(displayId: Int) {
            if (displayId != Display.DEFAULT_DISPLAY) return
            glPreviewRenderer?.updateTransform(glPreviewRotationDegrees(), previewMirrorHorizontal)
            if (useFaceMeshCameraInputPipeline) {
                val sz = previewSize ?: return
                mainHandler.post {
                    runCatching { cameraInput?.updateOutputSize(sz.width, sz.height) }
                    glPreviewRenderer?.syncPreviewPipelineSize(sz.width, sz.height)
                }
            } else {
                imageCaptureUseCase?.targetRotation = displayTargetRotation()
                processCameraProvider?.let { runCatching { bindCameraXUseCases(it) } }
            }
        }
    }

    fun initCamera(
        ratio: String,
        flashMode: String,
        cameraId: Int,
        enableAudio: Boolean,
        viewportWidth: Double?,
        viewportHeight: Double?,
        screenFlashForFront: Boolean = true,
        maxGifDurationMs: Int = 5000,
        recordSpeed: String = "normal",
    ): Long {
        currentRatio = ratio
        currentFlashMode = flashMode
        currentCameraId = cameraId.toString()
        currentEnableAudio = enableAudio
        previewViewportWidth = viewportWidth?.takeIf { it > 0 }
        previewViewportHeight = viewportHeight?.takeIf { it > 0 }
        enableScreenFlashForFront = screenFlashForFront
        gifMaxDurationMs = maxGifDurationMs.coerceIn(1000, 30_000)
        recordSpeedProfileName = recordSpeed
        startBackgroundThread()
        surfaceTextureEntry = textureRegistry.createSurfaceTexture(); textureId = surfaceTextureEntry!!.id(); surfaceTexture = surfaceTextureEntry!!.surfaceTexture()
        openCamera()
        return textureId
    }

    /**
     * Reported to Flutter for metadata / viewport math. [previewSize] is often **landscape** W>H
     * while the on-screen preview is portrait — return **portrait-normalized** (width ≤ height) so
     * clients don’t build wrong aspect [FittedBox] children.
     */
    fun getPreviewBufferSize(): Map<String, Int>? {
        val sz = previewStreamSize ?: previewSize ?: return null
        val w = sz.width
        val h = sz.height
        return if (w <= h) {
            mapOf("width" to w, "height" to h)
        } else {
            mapOf("width" to h, "height" to w)
        }
    }

    fun setBeautySettings(settings: Map<String, Any?>) { beautySettings = settings; glPreviewRenderer?.updateEffects(beautySettings, filterSettings) }
    fun setFilterSettings(settings: Map<String, Any?>) { filterSettings = settings; glPreviewRenderer?.updateEffects(beautySettings, filterSettings) }

    fun setArEffect(effect: String) {
        currentArEffect = effect
        glPreviewRenderer?.currentArEffect = effect
    }

    fun setRecordSpeedProfile(name: String) {
        recordSpeedProfileName = name
        applyRecordSpeedMultiplier()
    }

    private fun applyRecordSpeedMultiplier() {
        glPreviewRenderer?.recordPresentationMultiplier = when (recordSpeedProfileName) {
            "slow" -> 2.0
            "fast" -> 0.5
            else -> 1.0
        }
    }

    /**
     * Writes consecutive JPEG frames to a cache directory; Flutter assembles GIF.
     * Invokes [done] on a background thread with the directory path or "" on failure.
     */
    fun captureGifFramesToDir(durationMs: Int, fps: Int, done: (String) -> Unit) {
        val gl = glPreviewRenderer ?: run { done(""); return }
        val dur = durationMs.coerceIn(400, gifMaxDurationMs)
        val f = fps.coerceIn(3, 15)
        val n = ((dur / 1000f) * f).toInt().coerceIn(4, 60)
        val dir = File(context.cacheDir, "gif_burst_${System.currentTimeMillis()}").apply { mkdirs() }
        gl.requestJpegBurst(n) { list ->
            try {
                if (list.isEmpty()) {
                    done("")
                    return@requestJpegBurst
                }
                list.forEachIndexed { i, bytes ->
                    File(dir, "f_${String.format("%04d", i)}.jpg").writeBytes(bytes)
                }
                done(dir.absolutePath)
            } catch (_: Exception) {
                done("")
            }
        }
    }

    // Kept for backward compatibility — now a no-op (stickers move to Flutter post-capture layer)
    fun setStickerSettings(settings: Map<String, Any?>) { /* no-op */ }

    /**
     * Lazily creates [mediaPipeTracker] on the **ImageAnalysis** thread when using CameraX
     * (Face Mesh [CameraInput] path already builds the tracker in [openCamera]).
     */
    private fun ensureMediaPipeTrackerOnAnalysisThread() {
        val kalman = faceLandmarkKalman ?: return
        if (mediaPipeTracker != null || mediaPipeInitFailed) return
        synchronized(mediaPipeInitLock) {
            if (mediaPipeTracker != null || mediaPipeInitFailed) return
            val tracker = MediaPipeFaceTracker.create(context, kalman) ?: run {
                mediaPipeInitFailed = true
                return
            }
            tracker.onFaceOverlayUpdate = { overlay ->
                mainHandler.post { onFaceOverlay?.invoke(overlayToMap(overlay)) }
            }
            mediaPipeTracker = tracker
            glPreviewRenderer?.mediaPipeTracker = tracker
            glPreviewRenderer?.currentArEffect = currentArEffect
        }
    }

    private fun shouldCaptureFromGl(): Boolean {
        // Face Mesh + CameraInput：无 CameraX ImageCapture，必须走 GL 纹理快照
        if (useFaceMeshCameraInputPipeline) {
            if (lensFacing == CameraCharacteristics.LENS_FACING_BACK &&
                (currentFlashMode == "on" || currentFlashMode == "auto")
            ) {
                return false
            }
            return true
        }
        // GL 截的是已美颜/特效的纹理，无法触发物理闪光灯；需要闪光时必须走传感器拍照
        if (lensFacing == CameraCharacteristics.LENS_FACING_BACK &&
            (currentFlashMode == "on" || currentFlashMode == "auto")
        ) {
            return false
        }
        if (currentArEffect != "none") return true
        val b = beautySettings
        val be = ((b["bigEye"] as? Number)?.toFloat() ?: 0f) > 0.03f
        val sf = ((b["slimFace"] as? Number)?.toFloat() ?: 0f) > 0.03f
        val pb = ((b["portraitBlur"] as? Number)?.toFloat() ?: 0f) > 0.03f
        return be || sf || pb
    }

    /** ML Kit selfie segmentation is heavy — only when portrait blur is actually used. */
    private fun shouldRunPortraitSegmentation(): Boolean {
        if (currentArEffect == "portrait_blur") return true
        val pb = ((beautySettings["portraitBlur"] as? Number)?.toFloat() ?: 0f)
        return pb > 0.03f
    }

    /** Subject segmentation (~200ms class models) — only for green_hair AR. */
    private fun shouldRunSubjectSegmentation(): Boolean = currentArEffect == "green_hair"

    private fun startBackgroundThread() {
        if (backgroundThread != null) return
        backgroundThread = HandlerThread("BeautyCameraBackground").also { it.start() }
        backgroundHandler = Handler(backgroundThread!!.looper)
    }
    private fun stopBackgroundThread() { backgroundThread?.quitSafely(); backgroundThread?.join(); backgroundThread = null; backgroundHandler = null }

    private fun openCamera() {
        val characteristics = cameraManager.getCameraCharacteristics(currentCameraId)
        sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 90
        lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING) ?: CameraCharacteristics.LENS_FACING_BACK
        val afModes = characteristics.get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES) ?: intArrayOf()
        supportsContinuousAf = afModes.contains(CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE)
        supportsContinuousVideoAf = afModes.contains(CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO)
        val sceneModes = characteristics.get(CameraCharacteristics.CONTROL_AVAILABLE_SCENE_MODES) ?: intArrayOf()
        supportsHdrScene = sceneModes.contains(CaptureRequest.CONTROL_SCENE_MODE_HDR)
        val abModes = characteristics.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_ANTIBANDING_MODES) ?: intArrayOf()
        aeAntibandingAuto = abModes.contains(CaptureRequest.CONTROL_AE_ANTIBANDING_MODE_AUTO)
        val nrModes = characteristics.get(CameraCharacteristics.NOISE_REDUCTION_AVAILABLE_NOISE_REDUCTION_MODES) ?: intArrayOf()
        noiseReductionFastAvailable = nrModes.contains(CaptureRequest.NOISE_REDUCTION_MODE_FAST)
        noiseReductionMode = when {
            nrModes.contains(CaptureRequest.NOISE_REDUCTION_MODE_HIGH_QUALITY) -> CaptureRequest.NOISE_REDUCTION_MODE_HIGH_QUALITY
            nrModes.contains(CaptureRequest.NOISE_REDUCTION_MODE_FAST) -> CaptureRequest.NOISE_REDUCTION_MODE_FAST
            else -> null
        }
        previewAeTargetFpsRange = run {
            val ranges = characteristics.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES) ?: return@run null
            if (ranges.isEmpty()) return@run null
            ranges.firstOrNull { it.upper <= 30 && it.lower >= 15 }
                ?: ranges.firstOrNull { it.upper == 30 }
                ?: ranges.maxByOrNull { it.upper }
        }
        val map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)!!
        captureSize = getBestCaptureSizeByRatio(map, currentRatio)
        previewSize = Size(captureSize!!.width, captureSize!!.height)
        glPreviewRenderer?.selfieSegmentationHelper = null
        glPreviewRenderer?.subjectSegmentationHelper = null
        selfieSegmentationHelper?.release()
        selfieSegmentationHelper = null
        subjectSegmentationHelper?.release()
        subjectSegmentationHelper = null
        runCatching { cameraInput?.close() }
        cameraInput = null
        useFaceMeshCameraInputPipeline = false
        mediaPipeTracker?.release()
        mediaPipeTracker = null
        mediaPipeInitFailed = false
        glPreviewRenderer?.release()
        faceLandmarkKalman = LandmarkKalmanFilter()
        val klm = faceLandmarkKalman!!
        // Do not mirror in GL here either: many front streams are already mirrored after rotation+stMatrix;
        // an extra Flutter scaleX(-1) was inverting left↔right vs reality. Preview = raw GL output only.
        previewMirrorHorizontal = false
        selfieSegmentationHelper = SelfieSegmentationHelper()
        subjectSegmentationHelper = SubjectSegmentationHelper()
        val act = activityProvider()
        val tracker = MediaPipeFaceTracker.create(context, klm)
        mediaPipeTracker = tracker
        mediaPipeInitFailed = tracker == null
        // CameraInput（GPU 纹理）高帧率；与 [ImageCapture] 不能同时独占同一摄像头。后置闪光灯见 [captureStillWithTransientCameraX]。
        useFaceMeshCameraInputPipeline = act != null && tracker != null
        val rotationDeg = glPreviewRotationDegrees()
        tracker?.textureInputMode = useFaceMeshCameraInputPipeline
        tracker?.onFaceOverlayUpdate = { overlay ->
            mainHandler.post { onFaceOverlay?.invoke(overlayToMap(overlay)) }
        }
        val meshForEgl = if (useFaceMeshCameraInputPipeline) tracker!!.faceMesh else null
        glPreviewRenderer = GlPreviewRenderer(surfaceTexture, context.applicationContext).also { gl ->
            gl.start(
                previewSize!!.width,
                previewSize!!.height,
                rotationDeg,
                previewMirrorHorizontal,
                meshForEgl,
            )
            gl.applyBackCameraTextureRotate180 =
                lensFacing == CameraCharacteristics.LENS_FACING_BACK
            gl.kalmanFilter = klm
            gl.selfieSegmentationHelper = selfieSegmentationHelper
            gl.subjectSegmentationHelper = subjectSegmentationHelper
            gl.updateEffects(beautySettings, filterSettings)
            gl.currentArEffect = currentArEffect
            gl.mediaPipeTracker = tracker
            tracker?.onFaceMeshGlFrame = { tf -> gl.queueFaceMeshFrame(tf) }
            applyRecordSpeedMultiplier()
        }
        val dm = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        runCatching { dm.unregisterDisplayListener(displayRotationListener) }
        dm.registerDisplayListener(displayRotationListener, mainHandler)
        sceneLumaEma = 0.45f
        sceneLumaSampleCount = 0
        lastRearAutoStillInteropBright = null
        rearAutoFlashInteropRebindRunnable?.let { mainHandler.removeCallbacks(it) }
        rearAutoFlashInteropRebindRunnable = null

        if (useFaceMeshCameraInputPipeline && act != null) {
            previewStreamSize = previewSize
            startMediaPipeCameraInput(act)
            return
        }

        cameraExecutor?.shutdownNow()
        cameraExecutor = Executors.newSingleThreadExecutor { r ->
            Thread(r, "CameraXAnalysis").apply { isDaemon = true }
        }

        val future = ProcessCameraProvider.getInstance(context)
        future.addListener(
            {
                try {
                    val provider = future.get()
                    processCameraProvider = provider
                    bindCameraXUseCases(provider)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            },
            ContextCompat.getMainExecutor(context),
        )
    }

    private fun startMediaPipeCameraInput(activity: Activity) {
        val mesh = mediaPipeTracker?.faceMesh ?: return
        runCatching { cameraInput?.close() }
        val ci = CameraInput(activity)
        cameraInput = ci
        val facing = if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
            CameraInput.CameraFacing.FRONT
        } else {
            CameraInput.CameraFacing.BACK
        }
        ci.setNewFrameListener { tf ->
            mesh.send(tf)
            glPreviewRenderer?.cameraInputImageRotated = ci.isCameraRotated
        }
        val w = previewSize!!.width
        val h = previewSize!!.height
        mainHandler.post {
            runCatching {
                ci.start(activity, mesh.getGlContext(), facing, w, h)
            }.onFailure { it.printStackTrace() }
        }
    }

    private fun displayTargetRotation(): Int {
        val dm = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        return dm.getDisplay(Display.DEFAULT_DISPLAY)?.rotation ?: Surface.ROTATION_0
    }

    private fun bindCameraXUseCases(provider: ProcessCameraProvider) {
        if (useFaceMeshCameraInputPipeline) return
        runCatching { provider.unbindAll() }
        runCatching { cameraXLifecycle.destroy() }
        cameraXLifecycle = CameraEngineLifecycle()
        cameraXLifecycle.resumeCamera()

        val previewSz = previewSize ?: return
        val captureSz = captureSize ?: return
        val camExec = cameraExecutor ?: return
        val targetRot = displayTargetRotation()

        val selector = CameraSelector.Builder()
            .addCameraFilter { infos ->
                val match = infos.filter { info ->
                    runCatching { Camera2CameraInfo.from(info).cameraId == currentCameraId }.getOrDefault(false)
                }
                if (match.isNotEmpty()) match else infos
            }
            .build()

        val previewResolutionSelector = ResolutionSelector.Builder()
            .setResolutionStrategy(
                ResolutionStrategy(
                    previewSz,
                    ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER_THEN_HIGHER,
                ),
            )
            .build()

        val captureResolutionSelector = ResolutionSelector.Builder()
            .setResolutionStrategy(
                ResolutionStrategy(
                    captureSz,
                    ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER_THEN_HIGHER,
                ),
            )
            .build()

        previewUseCase = Preview.Builder()
            .setTargetRotation(targetRot)
            .setResolutionSelector(previewResolutionSelector)
            .build()

        previewUseCase!!.setSurfaceProvider { request ->
            val surf = glPreviewRenderer?.getCameraSurface()
            if (surf == null) {
                request.willNotProvideSurface()
                return@setSurfaceProvider
            }
            val bound = request.resolution
            previewStreamSize = Size(bound.width, bound.height)
            glPreviewRenderer?.syncPreviewPipelineSize(bound.width, bound.height)
            request.provideSurface(surf, camExec) { }
        }

        imageAnalysis = ImageAnalysis.Builder()
            .setTargetRotation(targetRot)
            .setResolutionSelector(previewResolutionSelector)
            // Default **YUV_420_888**: RGBA analysis often reports planes where [imageProxyToArgb] fails and
            // YUV fallback [imageToBitmap] cannot use planes[1] — [PreparedFaceFrame] stays null → no Kalman updates.
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()

        imageAnalysis!!.setAnalyzer(camExec) { proxy ->
            try {
                ensureMediaPipeTrackerOnAnalysisThread()
                val mediaImage = proxy.image
                if (currentFlashMode == "auto") {
                    val y = when {
                        mediaImage != null && mediaImage.planes.size >= 3 ->
                            PreviewSceneLuma.computeLuma01(mediaImage)
                        else -> PreviewSceneLuma.computeLuma01FromRgbaImageProxy(proxy)
                    }
                    y?.let {
                        sceneLumaEma = sceneLumaEma * 0.78f + it * 0.22f
                        sceneLumaSampleCount++
                        maybeRebindImageCaptureForRearAutoFlashInterop()
                    }
                }
                val rotForMl = proxy.imageInfo.rotationDegrees
                if (shouldRunPortraitSegmentation() && mediaImage != null) {
                    selfieSegmentationHelper?.processFrame(mediaImage, rotForMl)
                }
                if (shouldRunSubjectSegmentation() && mediaImage != null) {
                    subjectSegmentationHelper?.processFrame(mediaImage, rotForMl)
                }
                val isFront = lensFacing == CameraCharacteristics.LENS_FACING_FRONT
                val prep = PreparedFaceFrame.fromImageProxy(proxy, isFront)
                if (prep != null) {
                    try {
                        val mpFace = mediaPipeTracker?.detectFromPrepared(prep) == true
                        val mlPath: String = if (mpFace) {
                            "mediapipe"
                        } else {
                            var overlay: FaceOverlay? = null
                            var path = "none"
                            if (mediaImage != null && mediaImage.planes.size >= 3) {
                                overlay = faceTracker.processSyncRemappedToBuffer(mediaImage, rotForMl, prep)
                                if (overlay != null) path = "remapped"
                            }
                            if (overlay == null) {
                                overlay = faceTracker.processPreparedSync(prep)
                                if (overlay != null) path = "prepared"
                            }
                            if (overlay != null) {
                                faceLandmarkKalman?.update(SyntheticFaceLandmarks.fromOverlay(overlay))
                                mediaPipeTracker?.markAuxiliaryFaceMeasurement()
                                mainHandler.post { onFaceOverlay?.invoke(overlayToMap(overlay)) }
                            }
                            path
                        }
                        publishFaceAlignmentDebug(prep, rotForMl, isFront, mpFace, mlPath)
                        if (Log.isLoggable("PixelfreeFace", Log.DEBUG) && ++faceDiagFrameCount % 45 == 0) {
                            Log.d(
                                "PixelfreeFace",
                                "mpFace=$mpFace kalmanInit=${faceLandmarkKalman?.hasData == true} " +
                                    "mpNull=${mediaPipeTracker == null} mlPath=$mlPath",
                            )
                        }
                    } finally {
                        val sensor = prep.sensorArgb
                        prep.recycleRotatedOnly()
                        val glr = glPreviewRenderer
                        if (glr != null) {
                            glr.queueAnalysisDisplayFrame(sensor, rotForMl)
                        } else {
                            sensor.recycle()
                        }
                    }
                } else if (mediaImage != null) {
                    val overlay = faceTracker.processSync(mediaImage, rotForMl)
                    if (overlay != null) {
                        faceLandmarkKalman?.update(SyntheticFaceLandmarks.fromOverlay(overlay))
                        mediaPipeTracker?.markAuxiliaryFaceMeasurement()
                        mainHandler.post { onFaceOverlay?.invoke(overlayToMap(overlay)) }
                    } else {
                        faceLandmarkKalman?.reset()
                    }
                    publishFaceAlignmentDebug(null, rotForMl, isFront, mpFace = false, mlPath = if (overlay != null) "legacy_sync" else "legacy_sync_miss")
                    glPreviewRenderer?.requestPreviewOesFrame()
                } else {
                    glPreviewRenderer?.requestPreviewOesFrame()
                }
            } finally {
                proxy.close()
            }
        }

        imageCaptureUseCase = ImageCapture.Builder()
            .setTargetRotation(targetRot)
            // MINIMIZE_LATENCY 在多数机型上会削弱测光/预闪，导致「开灯 / 自动闪光」不稳定；仍图优先质量与闪光可靠性。
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
            .setResolutionSelector(captureResolutionSelector)
            .apply { syncImageCaptureFlashMode(this) }
            .apply { applyCamera2InteropForStillFlash(this) }
            .build()

        runCatching {
            provider.bindToLifecycle(
                cameraXLifecycle,
                selector,
                previewUseCase!!,
                imageAnalysis!!,
                imageCaptureUseCase!!,
            )
        }
        // Prime preview before first ImageAnalysis callback (analysis path will take over when prep succeeds).
        camExec.execute { glPreviewRenderer?.requestPreviewOesFrame() }
    }

    /**
     * 仍图 [ImageCapture] 闪光模式：与预览 [applyFlashModeForPreview] 分离，避免仅依赖 HAL 的 AUTO 而忽略场景亮度。
     *
     * - **后置 + auto**：已采样且画面够亮 → 关闪；否则 → AUTO（由设备决定是否预闪）。
     * - **前置**：多数无补光灯，AUTO/ON 对仍图无效；关硬件闪，由 [needsFrontScreenFlash] + 屏幕补光。
     */
    private fun imageCaptureFlashModeForStill(): Int {
        when (currentFlashMode) {
            "on" -> {
                // 前置仍图不走 LED（多数无灯）；「开灯」补光由 [needsFrontScreenFlash] + 屏幕白光完成。
                if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
                    return ImageCapture.FLASH_MODE_OFF
                }
                return ImageCapture.FLASH_MODE_ON
            }
            "auto" -> {
                if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
                    return ImageCapture.FLASH_MODE_OFF
                }
                if (sceneLumaSampleCount >= 1 && isAutoFlashSceneBright()) {
                    return ImageCapture.FLASH_MODE_OFF
                }
                return ImageCapture.FLASH_MODE_AUTO
            }
            else -> return ImageCapture.FLASH_MODE_OFF
        }
    }

    private fun syncImageCaptureFlashMode(builder: ImageCapture.Builder) {
        builder.setFlashMode(imageCaptureFlashModeForStill())
    }

    /**
     * 部分机型上仅 [ImageCapture.setFlashMode] 不足以触发 AE/预闪；与 [applyFlashModeForStillCapture] 对齐下发 Camera2 请求。
     * 选项在 Builder 上，故 [setFlashMode] / 切换镜头时会 [bindCameraXUseCases] 重建。
     */
    private fun applyCamera2InteropForStillFlash(builder: ImageCapture.Builder) {
        val ext = Camera2Interop.Extender(builder)
        if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
            ext.setCaptureRequestOption(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
            ext.setCaptureRequestOption(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
            return
        }
        when (currentFlashMode) {
            "on" -> {
                ext.setCaptureRequestOption(
                    CaptureRequest.CONTROL_AE_MODE,
                    CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH,
                )
                ext.setCaptureRequestOption(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
            }
            "auto" -> {
                ext.setCaptureRequestOption(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
                when {
                    isAutoFlashSceneBright() ->
                        ext.setCaptureRequestOption(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                    else ->
                        ext.setCaptureRequestOption(
                            CaptureRequest.CONTROL_AE_MODE,
                            CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH,
                        )
                }
            }
            else -> {
                ext.setCaptureRequestOption(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                ext.setCaptureRequestOption(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
            }
        }
    }

    private fun applyImageCaptureFlashFromSettings() {
        val ic = imageCaptureUseCase ?: return
        ic.flashMode = imageCaptureFlashModeForStill()
    }

    /** CameraInput 预览运行时无 [ImageCapture]；后置 on/auto 需短暂释放 CameraInput 并仅绑定 [ImageCapture] 以触发闪光灯。 */
    private fun needsTransientCameraXStill(): Boolean =
        useFaceMeshCameraInputPipeline &&
            lensFacing == CameraCharacteristics.LENS_FACING_BACK &&
            (currentFlashMode == "on" || currentFlashMode == "auto")

    /**
     * 仅绑定 [ImageCapture]（无 Preview），避免依赖 [GlPreviewRenderer.getCameraSurface] 在 FaceMesh 路径下为 null。
     */
    private fun bindTransientImageCaptureOnly(provider: ProcessCameraProvider) {
        runCatching { provider.unbindAll() }
        runCatching { cameraXLifecycle.destroy() }
        cameraXLifecycle = CameraEngineLifecycle()
        cameraXLifecycle.resumeCamera()
        val captureSz = captureSize ?: Size(1920, 1080)
        val targetRot = displayTargetRotation()
        val selector = CameraSelector.Builder()
            .addCameraFilter { infos ->
                val match = infos.filter { info ->
                    runCatching { Camera2CameraInfo.from(info).cameraId == currentCameraId }.getOrDefault(false)
                }
                if (match.isNotEmpty()) match else infos
            }
            .build()
        val captureResolutionSelector = ResolutionSelector.Builder()
            .setResolutionStrategy(
                ResolutionStrategy(
                    captureSz,
                    ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER_THEN_HIGHER,
                ),
            )
            .build()
        previewUseCase = null
        imageAnalysis = null
        imageCaptureUseCase = ImageCapture.Builder()
            .setTargetRotation(targetRot)
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
            .setResolutionSelector(captureResolutionSelector)
            .apply { syncImageCaptureFlashMode(this) }
            .apply { applyCamera2InteropForStillFlash(this) }
            .build()
        runCatching {
            provider.bindToLifecycle(
                cameraXLifecycle,
                selector,
                imageCaptureUseCase!!,
            )
        }
    }

    private fun resumeCameraInputAfterTransientStill() {
        runCatching { processCameraProvider?.unbindAll() }
        imageCaptureUseCase = null
        previewUseCase = null
        imageAnalysis = null
        val act = activityProvider()
        if (act != null && useFaceMeshCameraInputPipeline) {
            mainHandler.post {
                runCatching { startMediaPipeCameraInput(act) }
            }
        }
    }

    /** 后置 + auto：场景亮度跨越阈值时重建 [ImageCapture]，使 Camera2Interop 与 [isAutoFlashSceneBright] 一致。 */
    private fun maybeRebindImageCaptureForRearAutoFlashInterop() {
        if (currentFlashMode != "auto") return
        if (lensFacing != CameraCharacteristics.LENS_FACING_BACK) return
        if (sceneLumaSampleCount < 1) return
        if (useFaceMeshCameraInputPipeline) return
        val bright = isAutoFlashSceneBright()
        if (bright == lastRearAutoStillInteropBright) return
        lastRearAutoStillInteropBright = bright
        rearAutoFlashInteropRebindRunnable?.let { mainHandler.removeCallbacks(it) }
        val r = Runnable {
            rearAutoFlashInteropRebindRunnable = null
            processCameraProvider?.let { runCatching { bindCameraXUseCases(it) } }
        }
        rearAutoFlashInteropRebindRunnable = r
        mainHandler.postDelayed(r, 320)
    }

    /** Short side / long side — matches Flutter preview slot (9:16 or 3:4) when viewport is set. */
    private fun previewTargetAspect(ratio: String): Float {
        val vw = previewViewportWidth
        val vh = previewViewportHeight
        if (vw != null && vh != null && vw > 0 && vh > 0) {
            return min(vw, vh).toFloat() / max(vw, vh).toFloat()
        }
        return if (ratio == "9:16") 9f / 16f else 3f / 4f
    }

    /**
     * 在「与 Flutter 槽位比例足够接近」的候选里优先 **最大像素数**，避免为略好一点的宽高比选中低分辨率仍图（观感「照片变小」）。
     */
    private fun getBestCaptureSizeByRatio(map: StreamConfigurationMap, ratio: String): Size {
        val sizes = map.getOutputSizes(ImageFormat.JPEG) ?: return Size(1920, 1080)
        if (sizes.size == 1) return sizes[0]
        val target = previewTargetAspect(ratio)
        val scored = sizes.map { size ->
            val rw = size.width.toFloat()
            val rh = size.height.toFloat()
            val r = min(rw, rh) / max(rw, rh)
            val score = abs(r - target)
            Triple(size, score, size.width * size.height)
        }
        val minScore = scored.minOf { it.second }
        val tolerance = 0.045f
        val candidates = scored.filter { it.second <= minScore + tolerance }
        return candidates.maxBy { it.third }.first
    }
    /** Same formula as Android docs for camera preview vs device display rotation. */
    private fun computePreviewRotationDegrees(): Int {
        val displayManager = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        val rotation = displayManager.getDisplay(Display.DEFAULT_DISPLAY)?.rotation ?: Surface.ROTATION_0
        val surfaceRotationDegrees = when (rotation) {
            Surface.ROTATION_90 -> 90
            Surface.ROTATION_180 -> 180
            Surface.ROTATION_270 -> 270
            else -> 0
        }
        val ch = try {
            cameraManager.getCameraCharacteristics(currentCameraId)
        } catch (_: Exception) {
            return 0
        }
        val sensorOrientationDegrees = ch.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 0
        val sign = if (ch.get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_FRONT) 1 else -1
        return (sensorOrientationDegrees - surfaceRotationDegrees * sign + 360) % 360
    }

    /**
     * CameraX OES + [SurfaceTexture.getTransformMatrix] 与 [computePreviewRotationDegrees] 之间需 +90° 对齐 UV。
     * 后置若仍倒立，由 [GlPreviewRenderer.applyBackCameraTextureRotate180] 在 [stMatrix] 上再左乘 180°。
     */
    private fun rotationForGlTexture(): Int {
        val r = computePreviewRotationDegrees()
        return (r + 90) % 360
    }

    /**
     * Rotation (degrees) for [GlPreviewRenderer] `uUserTexMatrix`.
     * [CameraInput] + GPU [com.google.mediapipe.framework.TextureFrame] follow the usual
     * sensor/display preview convention — do **not** apply the +90/+270 used for CameraX YUV/OES.
     */
    private fun glPreviewRotationDegrees(): Int = if (useFaceMeshCameraInputPipeline) {
        computePreviewRotationDegrees()
    } else {
        rotationForGlTexture()
    }

    /**
     * MP4 的 [MediaMuxer.setOrientationHint]：标准传感器 + 屏幕朝向公式，相册里会按竖屏显示「较大」的宽高元数据。
     * 成片像素已在 GL 中与预览对齐，与「未旋转的原始传感器帧」假设不一致；录像时在 [GlPreviewRenderer] 里对编码帧额外做 -90°
     * 与完整 hint 相抵，避免只减 hint 时元数据变成 0°、相册里分辨率显得变小。
     */
    private fun computeVideoOrientationHint(): Int {
        val dm = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        val rotation = dm.getDisplay(Display.DEFAULT_DISPLAY)?.rotation ?: Surface.ROTATION_0
        val deviceDegrees = when (rotation) {
            Surface.ROTATION_0 -> 0
            Surface.ROTATION_90 -> 90
            Surface.ROTATION_180 -> 180
            Surface.ROTATION_270 -> 270
            else -> 0
        }
        val sensorBased = if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
            val r = (sensorOrientation + deviceDegrees) % 360
            (360 - r) % 360
        } else {
            (sensorOrientation - deviceDegrees + 360) % 360
        }
        return ((sensorBased % 360) + 360) % 360
    }

    /**
     * 仍图朝向必须用 Camera2 官方定义（与 [rotationForGlTexture] 不同）：后者含 GL 纹理坐标专用的 +90°/+270°，
     * 若误当作 [JPEG_ORIENTATION] 下发，成片会错转约 90°、相册里宽高/缩放观感异常。
     *
     * 参考：developer.android.com — sensorOrientation 与 display rotation 合成；前置再取镜像等价 (360 - r) % 360。
     */
    private fun computeJpegOrientationForStillCapture(): Int {
        val dm = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        val rotation = dm.getDisplay(Display.DEFAULT_DISPLAY)?.rotation ?: Surface.ROTATION_0
        val degrees = when (rotation) {
            Surface.ROTATION_0 -> 0
            Surface.ROTATION_90 -> 90
            Surface.ROTATION_180 -> 180
            Surface.ROTATION_270 -> 270
            else -> 0
        }
        return if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
            val r = (sensorOrientation + degrees) % 360
            val textbook = (360 - r) % 360
            // 本管线（GL 预览 + 仍图 + 前置镜像）下教材公式仍图相对预览整幅倒立 180°，补 +180° 与屏幕一致。
            (textbook + 180) % 360
        } else {
            (sensorOrientation - degrees + 360) % 360
        }
    }

    /**
     * 与「水平镜像」组合的 EXIF 朝向（1–8），避免前置整图解码重编码；失败时再走 [mirrorFrontJpegByBitmap]。
     */
    private fun flipExifOrientationHorizontally(o: Int): Int = when (o) {
        ExifInterface.ORIENTATION_UNDEFINED,
        ExifInterface.ORIENTATION_NORMAL -> ExifInterface.ORIENTATION_FLIP_HORIZONTAL
        ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> ExifInterface.ORIENTATION_NORMAL
        ExifInterface.ORIENTATION_ROTATE_180 -> ExifInterface.ORIENTATION_FLIP_VERTICAL
        ExifInterface.ORIENTATION_FLIP_VERTICAL -> ExifInterface.ORIENTATION_ROTATE_180
        ExifInterface.ORIENTATION_TRANSPOSE -> ExifInterface.ORIENTATION_ROTATE_270
        ExifInterface.ORIENTATION_ROTATE_90 -> ExifInterface.ORIENTATION_TRANSVERSE
        ExifInterface.ORIENTATION_TRANSVERSE -> ExifInterface.ORIENTATION_ROTATE_90
        ExifInterface.ORIENTATION_ROTATE_270 -> ExifInterface.ORIENTATION_TRANSPOSE
        else -> ExifInterface.ORIENTATION_FLIP_HORIZONTAL
    }

    private fun attachNormalExifOrientation(jpegBytes: ByteArray): ByteArray {
        return try {
            val tmp = File.createTempFile("pf_orient_", ".jpg", context.cacheDir)
            try {
                FileOutputStream(tmp).use { it.write(jpegBytes) }
                ExifInterface(tmp).apply {
                    setAttribute(
                        ExifInterface.TAG_ORIENTATION,
                        ExifInterface.ORIENTATION_NORMAL.toString(),
                    )
                    saveAttributes()
                }
                tmp.readBytes()
            } finally {
                tmp.delete()
            }
        } catch (_: Exception) {
            jpegBytes
        }
    }

    /**
     * GL 仍图为全屏 surface [readPixels] 与预览同源；第二元组为 JPEG 像素宽高，失败 (0,0)。
     */
    private fun finalizeGlStillJpeg(jpegBytes: ByteArray): Pair<ByteArray, Pair<Int, Int>> {
        return try {
            val bmp = BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size)
                ?: return Pair(attachNormalExifOrientation(jpegBytes), Pair(0, 0))
            val fw = bmp.width
            val fh = bmp.height
            val bos = ByteArrayOutputStream(max(fw * fh / 6, 65536))
            bmp.compress(Bitmap.CompressFormat.JPEG, 95, bos)
            bmp.recycle()
            val out = attachNormalExifOrientation(bos.toByteArray())
            Pair(out, Pair(fw, fh))
        } catch (_: Exception) {
            Pair(attachNormalExifOrientation(jpegBytes), Pair(0, 0))
        }
    }

    /** 前置成片与镜像预览左右一致：传感器 JPEG 多为非镜像，预览经旋转后像镜子。 */
    private fun mirrorFrontJpegToMatchPreview(jpegBytes: ByteArray): ByteArray {
        if (lensFacing != CameraCharacteristics.LENS_FACING_FRONT) return jpegBytes
        return try {
            val tmp = File.createTempFile("pf_mirror_", ".jpg", context.cacheDir)
            try {
                FileOutputStream(tmp).use { it.write(jpegBytes) }
                val exif = ExifInterface(tmp)
                val raw = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                val o = if (raw == 0) ExifInterface.ORIENTATION_NORMAL else raw
                exif.setAttribute(ExifInterface.TAG_ORIENTATION, flipExifOrientationHorizontally(o).toString())
                exif.saveAttributes()
                tmp.readBytes()
            } finally {
                tmp.delete()
            }
        } catch (_: Exception) {
            mirrorFrontJpegByBitmap(jpegBytes)
        }
    }

    private fun mirrorFrontJpegByBitmap(jpegBytes: ByteArray): ByteArray {
        val bmp = BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size) ?: return jpegBytes
        val m = Matrix().apply { postScale(-1f, 1f, bmp.width / 2f, bmp.height / 2f) }
        val flipped = Bitmap.createBitmap(bmp.width, bmp.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(flipped)
        canvas.drawBitmap(bmp, m, null)
        bmp.recycle()
        val bos = ByteArrayOutputStream(jpegBytes.size.coerceAtLeast(65536))
        flipped.compress(Bitmap.CompressFormat.JPEG, 92, bos)
        flipped.recycle()
        return bos.toByteArray()
    }

    /** CameraX owns the repeating request; no-op kept for paths that used to restart Camera2 preview. */
    private fun startPreview() {
        applyImageCaptureFlashFromSettings()
    }
    private fun applyFocusMode(builder: CaptureRequest.Builder?) {
        when {
            supportsContinuousVideoAf -> builder?.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO)
            supportsContinuousAf -> builder?.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE)
            else -> builder?.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO)
        }
    }
    fun setFlashMode(mode: String) {
        currentFlashMode = mode
        applyImageCaptureFlashFromSettings()
        // Camera2Interop 选项在 Builder 上；仅改 [ImageCapture.flashMode] 不足以更新底层 AE/闪光意图。
        if (!useFaceMeshCameraInputPipeline) {
            processCameraProvider?.let { provider ->
                mainHandler.post { runCatching { bindCameraXUseCases(provider) } }
            }
        }
    }

    /** 预览：保持正常曝光与画面；勿用 TORCH+AE_OFF（易导致预览全黑、仅 LED 常亮）。「开灯」仅表示拍照时强制闪光。 */
    private fun applyFlashModeForPreview(builder: CaptureRequest.Builder?) {
        if (builder == null) return
        if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
            builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
            builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
            return
        }
        when (currentFlashMode) {
            "on" -> {
                builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
                builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
            }
            "auto" -> {
                builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
                // 未采样前不要用 ON_AUTO_FLASH，否则亮环境也会反复测光/预闪，快门体感很拖
                when {
                    sceneLumaSampleCount == 0 -> builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                    isAutoFlashSceneBright() -> builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                    else -> builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH)
                }
            }
            else -> {
                builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
                builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
            }
        }
    }

    /**
     * 已采样且画面足够亮：auto 模式下不补闪光（后置 LED / 前置屏幕补光均以此为参考）。
     * 阈值约对应室内正常照明；过暗（低于阈值）仍走自动闪光逻辑。
     */
    private fun isAutoFlashSceneBright(): Boolean =
        currentFlashMode == "auto" &&
            sceneLumaSampleCount >= 1 &&
            sceneLumaEma >= AUTO_FLASH_BRIGHT_LUMA_THRESHOLD

    /**
     * 后置 auto 且已采样、判定偏暗：UI 仍为「自动」，但拍照管线按「强制闪光」意图下发。
     * vivo/部分机型上 [CONTROL_AE_MODE_ON_AUTO_FLASH] 预拍/仍图仍不亮灯，[CONTROL_AE_MODE_ON_ALWAYS_FLASH] 才稳定。
     */
    private fun rearAutoDarkUseForcedFlashIntent(): Boolean =
        lensFacing == CameraCharacteristics.LENS_FACING_BACK &&
            currentFlashMode == "auto" &&
            sceneLumaSampleCount >= 1 &&
            !isAutoFlashSceneBright()

    companion object {
        /** Y 通道亮度 EMA 高于此值视为「足够亮」，auto 不强制补光。 */
        private const val AUTO_FLASH_BRIGHT_LUMA_THRESHOLD = 0.42f
        /** Logcat tag for [publishFaceAlignmentDebug] throttled lines. */
        private const val FACE_ALIGN_TAG = "PixelfreeFaceAlign"
    }

    /** 静态拍照：在此刻真正触发闪光灯（与预览策略分离）。 */
    private fun applyFlashModeForStillCapture(builder: CaptureRequest.Builder?) {
        if (builder == null) return
        if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
            builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
            builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
            return
        }
        when (currentFlashMode) {
            // 与 FLASH_MODE_SINGLE 同时设易在部分机型上冲突；由 AE 接管闪光，FLASH 保持 OFF
            "on" -> {
                builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH)
                builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
            }
            "auto" -> {
                builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
                when {
                    isAutoFlashSceneBright() ->
                        builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                    rearAutoDarkUseForcedFlashIntent() -> {
                        // 预拍已用 ALWAYS_FLASH 做过测光；仍图再用 ALWAYS 易继承预览的高增益 + 全功率闪 → 整幅过曝发白。
                        // 仍图改 AUTO_FLASH，让 HAL 按预拍结果控制曝光与补光量（vivo 等需先预拍再仍图才稳定）。
                        builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH)
                    }
                    else ->
                        builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH)
                }
            }
            else -> {
                builder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF)
                builder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
            }
        }
    }

    /** HDR scene mode when supported — improves backlight / bright-wall scenes (OEM-style "逆光 HDR"). */
    private fun applySceneModeForPreview(builder: CaptureRequest.Builder?) {
        if (builder == null) return
        // 前置开 HDR 易与测光/肤色策略打架，表现为预览「时不时闪一下」，前置一律关 HDR
        if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) {
            builder.set(CaptureRequest.CONTROL_SCENE_MODE, CaptureRequest.CONTROL_SCENE_MODE_DISABLED)
            return
        }
        if (supportsHdrScene && currentFlashMode == "off") {
            builder.set(CaptureRequest.CONTROL_SCENE_MODE, CaptureRequest.CONTROL_SCENE_MODE_HDR)
        } else {
            builder.set(CaptureRequest.CONTROL_SCENE_MODE, CaptureRequest.CONTROL_SCENE_MODE_DISABLED)
        }
    }

    private fun applyAeAntibanding(builder: CaptureRequest.Builder?) {
        if (builder == null) return
        // 前置 + 日光灯场景下 AUTO 抗闪烁可能反复切换，预览会「时不时闪一下」
        if (lensFacing == CameraCharacteristics.LENS_FACING_FRONT) return
        if (aeAntibandingAuto) {
            builder.set(CaptureRequest.CONTROL_AE_ANTIBANDING_MODE, CaptureRequest.CONTROL_AE_ANTIBANDING_MODE_AUTO)
        }
    }

    /** 预览走 FAST，降低 ISP 多帧降噪带来的延迟，观感更接近系统相机「跟手」。 */
    private fun applyNoiseReduction(builder: CaptureRequest.Builder?) {
        if (builder == null) return
        if (noiseReductionFastAvailable) {
            builder.set(CaptureRequest.NOISE_REDUCTION_MODE, CaptureRequest.NOISE_REDUCTION_MODE_FAST)
            return
        }
        val m = noiseReductionMode ?: return
        builder.set(CaptureRequest.NOISE_REDUCTION_MODE, m)
    }

    /** 仍图禁用 HDR/场景增强，避免多帧合成拖慢快门（数秒级）。 */
    private fun applySceneModeForStillCapture(builder: CaptureRequest.Builder?) {
        if (builder == null) return
        builder.set(CaptureRequest.CONTROL_SCENE_MODE, CaptureRequest.CONTROL_SCENE_MODE_DISABLED)
    }

    /** 仍图优先 FAST 降噪；高质量 NR 在部分机型上会明显拉长仍图耗时。 */
    private fun applyNoiseReductionForStill(builder: CaptureRequest.Builder?) {
        if (builder == null) return
        if (noiseReductionFastAvailable) {
            builder.set(CaptureRequest.NOISE_REDUCTION_MODE, CaptureRequest.NOISE_REDUCTION_MODE_FAST)
        } else {
            applyNoiseReduction(builder)
        }
    }
    fun setRatio(ratio: String) { currentRatio = ratio; restartCamera() }
    fun flipCamera() { currentCameraId = if (currentCameraId == "0") "1" else "0"; restartCamera() }

    private fun needsFrontScreenFlash(): Boolean {
        if (lensFacing != CameraCharacteristics.LENS_FACING_FRONT) return false
        if (!enableScreenFlashForFront) return false
        return when (currentFlashMode) {
            "on" -> true
            // auto：已确认够亮则关；未采样或偏暗则允许补光（避免「未采样前永远不闪」）
            "auto" -> {
                if (sceneLumaSampleCount >= 1 && sceneLumaEma >= AUTO_FLASH_BRIGHT_LUMA_THRESHOLD) {
                    false
                } else {
                    true
                }
            }
            else -> false
        }
    }

    /** [pixelWidth]/[pixelHeight] are saved JPEG dimensions (0 if unknown). */
    fun takePhoto(callback: (String, Int, Int) -> Unit) {
        if (shouldCaptureFromGl()) {
            val gl = glPreviewRenderer
            if (gl != null) {
                val runGlCapture: () -> Unit = {
                    gl.requestJpegSnapshot { bytes, surfW, surfH ->
                        if (bytes == null || bytes.isEmpty()) {
                            mainHandler.post {
                                if (needsFrontScreenFlash()) {
                                    onFrontFlashHint?.invoke(false, 0.0)
                                }
                                capturePhotoFromSensor(callback)
                            }
                            return@requestJpegSnapshot
                        }
                        backgroundHandler?.post {
                            try {
                                val file = createFile("photo")
                                val (out, dim) = finalizeGlStillJpeg(bytes)
                                FileOutputStream(file).use { it.write(out) }
                                val pw = dim.first.takeIf { it > 0 } ?: surfW.coerceAtLeast(0)
                                val ph = dim.second.takeIf { it > 0 } ?: surfH.coerceAtLeast(0)
                                mainHandler.post {
                                    if (needsFrontScreenFlash()) {
                                        onFrontFlashHint?.invoke(false, 0.0)
                                    }
                                    callback(photoPath ?: "", pw, ph)
                                }
                            } catch (_: Exception) {
                                mainHandler.post {
                                    if (needsFrontScreenFlash()) {
                                        onFrontFlashHint?.invoke(false, 0.0)
                                    }
                                    capturePhotoFromSensor(callback)
                                }
                            }
                        }
                    }
                }
                if (needsFrontScreenFlash()) {
                    mainHandler.post {
                        onFrontFlashHint?.invoke(true, 0.92)
                        mainHandler.postDelayed({
                            runGlCapture()
                        }, 180)
                    }
                } else {
                    runGlCapture()
                }
                return
            }
        }
        if (needsFrontScreenFlash()) {
            mainHandler.post {
                onFrontFlashHint?.invoke(true, 0.92)
                mainHandler.postDelayed({
                    capturePhotoFromSensor { path, pw, ph ->
                        onFrontFlashHint?.invoke(false, 0.0)
                        callback(path, pw, ph)
                    }
                }, 180)
            }
        } else {
            capturePhotoFromSensor(callback)
        }
    }

    /**
     * 一律单帧 still：按下即拍、尽快回调。补闪由 [applyFlashModeForStillCapture] + HAL。
     */
    private fun capturePhotoFromSensor(callback: (String, Int, Int) -> Unit) {
        if (needsTransientCameraXStill()) {
            captureStillWithTransientCameraX(callback)
        } else {
            captureStillPictureDirect(callback)
        }
    }

    /**
     * CameraInput 预览时临时释放相机，仅绑 [ImageCapture] 拍照（带闪），再恢复 [startMediaPipeCameraInput]。
     * 预览会短暂停格，属硬件独占限制下的折中。
     */
    private fun captureStillWithTransientCameraX(callback: (String, Int, Int) -> Unit) {
        val act = activityProvider()
        if (act == null) {
            mainHandler.post { capturePreviewAsJpegViaGl(callback) }
            return
        }
        synchronized(stillPhotoLock) {
            if (stillPhotoCallback != null) {
                mainHandler.post { callback("", 0, 0) }
                return
            }
            stillPhotoCallback = callback
        }
        val bg = backgroundHandler ?: mainHandler
        bg.post {
            runCatching { cameraInput?.close() }
            cameraInput = null
            try {
                val provider = ProcessCameraProvider.getInstance(context).get()
                mainHandler.post {
                    try {
                        processCameraProvider = provider
                        if (cameraExecutor == null || cameraExecutor!!.isShutdown) {
                            cameraExecutor?.shutdownNow()
                            cameraExecutor = Executors.newSingleThreadExecutor { r ->
                                Thread(r, "CameraXStill").apply { isDaemon = true }
                            }
                        }
                        bindTransientImageCaptureOnly(provider)
                        val ic = imageCaptureUseCase
                        val exec = cameraExecutor
                        if (ic == null || exec == null) {
                            synchronized(stillPhotoLock) { stillPhotoCallback = null }
                            resumeCameraInputAfterTransientStill()
                            callback("", 0, 0)
                            return@post
                        }
                        applyImageCaptureFlashFromSettings()
                        val file = createFile("photo")
                        val outputOptions = ImageCapture.OutputFileOptions.Builder(file).build()
                        ic.takePicture(
                            outputOptions,
                            exec,
                            object : ImageCapture.OnImageSavedCallback {
                                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                                    val userCb = synchronized(stillPhotoLock) {
                                        val p = stillPhotoCallback
                                        stillPhotoCallback = null
                                        p
                                    } ?: return
                                    dispatchProcessStillJpegFromFile(file, userCb) {
                                        resumeCameraInputAfterTransientStill()
                                    }
                                }

                                override fun onError(exc: ImageCaptureException) {
                                    val userCb = synchronized(stillPhotoLock) {
                                        val p = stillPhotoCallback
                                        stillPhotoCallback = null
                                        p
                                    }
                                    resumeCameraInputAfterTransientStill()
                                    mainHandler.post { userCb?.invoke("", 0, 0) }
                                }
                            },
                        )
                    } catch (_: Exception) {
                        synchronized(stillPhotoLock) { stillPhotoCallback = null }
                        resumeCameraInputAfterTransientStill()
                        callback("", 0, 0)
                    }
                }
            } catch (_: Exception) {
                synchronized(stillPhotoLock) { stillPhotoCallback = null }
                mainHandler.post {
                    resumeCameraInputAfterTransientStill()
                    callback("", 0, 0)
                }
            }
        }
    }

    private fun dispatchProcessStillJpegFromFile(
        file: File,
        userCb: (String, Int, Int) -> Unit,
        afterDelivered: (() -> Unit)? = null,
    ) {
        val bg = backgroundHandler
        if (bg == null) {
            mainHandler.post {
                userCb("", 0, 0)
                afterDelivered?.invoke()
            }
            return
        }
        bg.post {
            try {
                val bytes = file.readBytes()
                val processed: ByteArray =
                    if (shouldSaveStillWithoutCpuBeauty()) {
                        bytes
                    } else {
                        val overlay = mediaPipeTracker?.latest() ?: faceTracker.latest()
                        photoEffectProcessor.processJpeg(bytes, beautySettings, filterSettings, overlay)
                    }
                val outBytes = mirrorFrontJpegToMatchPreview(processed)
                FileOutputStream(file, false).use { it.write(outBytes) }
                photoPath = file.absolutePath
                val opts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeByteArray(outBytes, 0, outBytes.size, opts)
                var jw = opts.outWidth
                var jh = opts.outHeight
                if (jw <= 0 || jh <= 0) {
                    BitmapFactory.decodeFile(file.absolutePath, opts)
                    jw = opts.outWidth
                    jh = opts.outHeight
                }
                mainHandler.post {
                    userCb(photoPath ?: "", jw.coerceAtLeast(0), jh.coerceAtLeast(0))
                    afterDelivered?.invoke()
                }
            } catch (_: Exception) {
                mainHandler.post {
                    userCb("", 0, 0)
                    afterDelivered?.invoke()
                }
            }
        }
    }

    /** Full-resolution GL snapshot when CameraX [ImageCapture] is not bound (Face Mesh [CameraInput] path). */
    private fun capturePreviewAsJpegViaGl(callback: (String, Int, Int) -> Unit) {
        val gl = glPreviewRenderer
        if (gl == null) {
            mainHandler.post { callback("", 0, 0) }
            return
        }
        gl.requestJpegSnapshot { bytes, surfW, surfH ->
            if (bytes == null || bytes.isEmpty()) {
                mainHandler.post { callback("", 0, 0) }
                return@requestJpegSnapshot
            }
            backgroundHandler?.post {
                try {
                    val file = createFile("photo")
                    val (out, dim) = finalizeGlStillJpeg(bytes)
                    FileOutputStream(file).use { it.write(out) }
                    val pw = dim.first.takeIf { it > 0 } ?: surfW.coerceAtLeast(0)
                    val ph = dim.second.takeIf { it > 0 } ?: surfH.coerceAtLeast(0)
                    mainHandler.post {
                        callback(photoPath ?: "", pw, ph)
                    }
                } catch (_: Exception) {
                    mainHandler.post { callback("", 0, 0) }
                }
            } ?: mainHandler.post { callback("", 0, 0) }
        }
    }

    private fun captureStillPictureDirect(callback: (String, Int, Int) -> Unit) {
        val ic = imageCaptureUseCase
        val exec = cameraExecutor
        if (ic == null || exec == null) {
            if (useFaceMeshCameraInputPipeline) {
                capturePreviewAsJpegViaGl(callback)
            } else {
                mainHandler.post { callback("", 0, 0) }
            }
            return
        }
        synchronized(stillPhotoLock) {
            if (stillPhotoCallback != null) {
                mainHandler.post { callback("", 0, 0) }
                return
            }
            stillPhotoCallback = callback
        }
        applyImageCaptureFlashFromSettings()
        val file = createFile("photo")
        val outputOptions = ImageCapture.OutputFileOptions.Builder(file).build()
        ic.takePicture(
            outputOptions,
            exec,
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    val userCb = synchronized(stillPhotoLock) {
                        val p = stillPhotoCallback
                        stillPhotoCallback = null
                        p
                    } ?: return
                    dispatchProcessStillJpegFromFile(file, userCb, null)
                }

                override fun onError(exc: ImageCaptureException) {
                    val userCb = synchronized(stillPhotoLock) {
                        val p = stillPhotoCallback
                        stillPhotoCallback = null
                        p
                    }
                    mainHandler.post { userCb?.invoke("", 0, 0) }
                }
            },
        )
    }

    private fun orientFaceOverlay(overlay: FaceOverlay): FaceOverlay {
        val rotation = ((sensorOrientation % 360) + 360) % 360
        val isFront = lensFacing == CameraCharacteristics.LENS_FACING_FRONT

        fun xform(x: Float, y: Float): Pair<Float, Float> {
            var nx = x; var ny = y
            when (rotation) {
                90  -> { val t = nx; nx = 1f - ny; ny = t }
                180 -> { nx = 1f - nx; ny = 1f - ny }
                270 -> { val t = nx; nx = ny; ny = 1f - t }
            }
            if (isFront) nx = 1f - nx
            return nx.coerceIn(0f, 1f) to ny.coerceIn(0f, 1f)
        }

        val (cx, cy) = xform(overlay.centerX, overlay.centerY)
        val (ex, ey) = xform(overlay.eyeCenterX, overlay.eyeCenterY)
        val (hx, hy) = xform(overlay.headTopX, overlay.headTopY)
        val (fw, fh) = when (rotation) {
            90, 270 -> overlay.faceHeight to overlay.faceWidth
            else -> overlay.faceWidth to overlay.faceHeight
        }
        return FaceOverlay(cx, cy, fw, fh, ex, ey, hx, hy)
    }
    /** 无磨皮/美白/滤镜等 CPU 管线时直接落盘相机 JPEG，避免全图解码（否则易卡顿数秒）。 */
    private fun shouldSaveStillWithoutCpuBeauty(): Boolean {
        val s = BeautyFlutterScale.smoothingFromFlutter(beautySettings["smoothing"] as? Number)
        val w = BeautyFlutterScale.whiteningFromFlutter(beautySettings["whitening"] as? Number)
        val r = (beautySettings["ruddy"] as? Number)?.toFloat() ?: 0f
        val sh = (beautySettings["sharpen"] as? Number)?.toFloat() ?: 0f
        val fi = (filterSettings["intensity"] as? Number)?.toFloat() ?: 0f
        val filterId = filterSettings["filterId"] as? String
        val hasFilter = !filterId.isNullOrBlank() && fi > 0.02f
        if (hasFilter) return false
        return s <= 0.02f && w <= 0.02f && r <= 0.02f && sh <= 0.02f
    }

    fun startRecord(enableAudio: Boolean) {
        if (isRecording) return
        val preview = previewSize ?: return
        currentEnableAudio = enableAudio
        val finalOutputFile = createFile("video")
        val videoTempFile = createTempRecordingFile("video_track", ".mp4")
        val audioTempFile = if (currentEnableAudio) createTempRecordingFile("audio_track", ".m4a") else null
        recordingVideoTempFile = videoTempFile
        recordingAudioTempFile = audioTempFile
        lastRecordedVideoOrientationHint = computeVideoOrientationHint()
        backgroundHandler?.post {
            val gl = glPreviewRenderer ?: return@post
            applyRecordSpeedMultiplier()
            val rec = GlSurfaceVideoRecorder(
                videoTempFile,
                preview.width,
                preview.height,
                orientationHintDegrees = lastRecordedVideoOrientationHint,
            )
            val encSurface = rec.start()
            gl.attachVideoEncoderSync(
                rec,
                encSurface,
                preview.width,
                preview.height,
                preRotateNeg90ForFullOrientationHint = true,
            )
            glVideoRecorder = rec
            if (currentEnableAudio && audioTempFile != null) {
                audioRecorder = AudioClipRecorder(audioTempFile).also { it.start() }
            }
            videoPath = finalOutputFile.absolutePath
            isRecording = true
            startPreview()
        }
    }

    fun stopRecord(): String {
        if (!isRecording) return videoPath ?: ""
        isRecording = false
        audioRecorder?.stop()
        audioRecorder = null
        val rec = glVideoRecorder
        glVideoRecorder = null
        val finalPath = videoPath ?: ""
        val videoTempFile = recordingVideoTempFile
        val audioTempFile = recordingAudioTempFile
        val finalFile = if (finalPath.isNotBlank()) File(finalPath) else null
        val latch = CountDownLatch(1)
        backgroundHandler?.post {
            try {
                glPreviewRenderer?.stopVideoEncodingSync()
                rec?.finishEncoding()
            } finally {
                latch.countDown()
            }
        }
        latch.await(15, TimeUnit.SECONDS)
        if (videoTempFile != null && finalFile != null) {
            if (currentEnableAudio && audioTempFile != null && audioTempFile.exists()) {
                runCatching {
                    MediaMuxerHelper.mergeVideoAndAudio(
                        videoFile = videoTempFile,
                        audioFile = audioTempFile,
                        outputFile = finalFile,
                        orientationHintDegrees = lastRecordedVideoOrientationHint,
                    )
                }.onFailure { videoTempFile.copyTo(finalFile, overwrite = true) }
            } else {
                videoTempFile.copyTo(finalFile, overwrite = true)
            }
        }
        runCatching { recordingVideoTempFile?.delete() }
        runCatching { recordingAudioTempFile?.delete() }
        recordingVideoTempFile = null
        recordingAudioTempFile = null
        startPreview()
        return finalPath
    }

    fun restartCamera() {
        releaseCamera()
        initCamera(
            currentRatio,
            currentFlashMode,
            currentCameraId.toInt(),
            currentEnableAudio,
            previewViewportWidth,
            previewViewportHeight,
            enableScreenFlashForFront,
            gifMaxDurationMs,
            recordSpeedProfileName,
        )
    }
    fun getInputGlTextureId(): Int = glPreviewRenderer?.getInputTextureId() ?: -1

    fun getFaceOverlay(): Map<String, Double>? {
        val face = mediaPipeTracker?.latest() ?: faceTracker.latest() ?: return null
        return overlayToMap(face)
    }

    /**
     * Single snapshot of buffer / upright / detection path / Kalman nose (0..1 in buffer-normalized landmark space).
     * Call from Flutter while preview runs; no extra frame cost beyond one map write per analyzed frame.
     * Optional: `adb logcat -s PixelfreeFaceAlign:I` (one line every ~30 analysis frames when the tag is loggable).
     */
    fun getFaceAlignmentDebug(): Map<String, Any>? = lastFaceAlignmentDebug

    private fun publishFaceAlignmentDebug(
        prep: PreparedFaceFrame?,
        rotForMl: Int,
        isFront: Boolean,
        mpFace: Boolean,
        mlPath: String,
    ) {
        val klm = faceLandmarkKalman
        val lm = klm?.predict(System.nanoTime())
        val pv = previewStreamSize ?: previewSize
        val overlay = mediaPipeTracker?.latest() ?: faceTracker.latest()
        val snap = LinkedHashMap<String, Any>()
        snap["arEffect"] = currentArEffect
        snap["imageProxyRotationDeg"] = rotForMl
        snap["glUserTexRotationDeg"] = glPreviewRotationDegrees()
        snap["displayTargetRotation"] = displayTargetRotation()
        snap["frontCamera"] = isFront
        snap["mpFace"] = mpFace
        snap["mlPath"] = mlPath
        snap["kalmanHasData"] = klm?.hasData == true
        snap["mediaPipeTrackerNull"] = mediaPipeTracker == null
        if (pv != null) {
            snap["previewBufferW"] = pv.width
            snap["previewBufferH"] = pv.height
            snap["previewStreamIsBound"] = previewStreamSize != null
        }
        if (prep != null) {
            snap["sensorBufferW"] = prep.bufferW
            snap["sensorBufferH"] = prep.bufferH
            snap["uprightW"] = prep.mpW
            snap["uprightH"] = prep.mpH
            snap["inferScale"] = prep.landmarkInferScale.toDouble()
            snap["detBitmapW"] = prep.rotated.width
            snap["detBitmapH"] = prep.rotated.height
            snap["uprightCanvasLeft"] = prep.uprightCanvasLeft.toDouble()
            snap["uprightCanvasTop"] = prep.uprightCanvasTop.toDouble()
        } else {
            snap["prepNull"] = true
        }
        if (lm != null) {
            snap["kalmanNoseX"] = lm.x(FaceLandmarks.NOSE_TIP).toDouble()
            snap["kalmanNoseY"] = lm.y(FaceLandmarks.NOSE_TIP).toDouble()
        }
        if (overlay != null) {
            snap["overlayCenterX"] = overlay.centerX.toDouble()
            snap["overlayCenterY"] = overlay.centerY.toDouble()
        }
        lastFaceAlignmentDebug = snap
        if (Log.isLoggable(FACE_ALIGN_TAG, Log.INFO) && ++faceAlignLogCounter % 30 == 0) {
            Log.i(FACE_ALIGN_TAG, snap.entries.joinToString(" ") { "${it.key}=${it.value}" })
        }
    }

    private fun overlayToMap(face: FaceOverlay): Map<String, Double> = mapOf(
        "centerX" to face.centerX.toDouble(),
        "centerY" to face.centerY.toDouble(),
        "faceWidth" to face.faceWidth.toDouble(),
        "faceHeight" to face.faceHeight.toDouble(),
        "eyeCenterX" to face.eyeCenterX.toDouble(),
        "eyeCenterY" to face.eyeCenterY.toDouble(),
        "headTopX" to face.headTopX.toDouble(),
        "headTopY" to face.headTopY.toDouble(),
        "rollDegrees" to face.rollDegrees.toDouble(),
    )

    fun releaseCamera() {
        synchronized(stillPhotoLock) {
            val pending = stillPhotoCallback
            stillPhotoCallback = null
            pending?.let { cb -> mainHandler.post { cb("", 0, 0) } }
        }
        runCatching {
            (context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager)
                .unregisterDisplayListener(displayRotationListener)
        }
        rearAutoFlashInteropRebindRunnable?.let { mainHandler.removeCallbacks(it) }
        rearAutoFlashInteropRebindRunnable = null
        lastRearAutoStillInteropBright = null
        runCatching { cameraInput?.close() }
        cameraInput = null
        useFaceMeshCameraInputPipeline = false
        mediaPipeTracker?.textureInputMode = false
        runCatching { processCameraProvider?.unbindAll() }
        processCameraProvider = null
        previewStreamSize = null
        previewUseCase = null
        imageAnalysis = null
        imageCaptureUseCase = null
        cameraXLifecycle.destroy()
        runCatching { cameraExecutor?.shutdown() }
        cameraExecutor = null

        audioRecorder?.stop()
        audioRecorder = null
        glVideoRecorder?.let { rec ->
            glPreviewRenderer?.stopVideoEncodingSync()
            runCatching { rec.finishEncoding() }
        }
        glVideoRecorder = null
        glPreviewRenderer?.selfieSegmentationHelper = null
        glPreviewRenderer?.subjectSegmentationHelper = null
        selfieSegmentationHelper?.release()
        selfieSegmentationHelper = null
        subjectSegmentationHelper?.release()
        subjectSegmentationHelper = null
        glPreviewRenderer?.release(); glPreviewRenderer = null
        outputSurface?.release(); outputSurface = null; surfaceTextureEntry?.release(); surfaceTextureEntry = null
        stopBackgroundThread()
        mediaPipeTracker?.release(); mediaPipeTracker = null
        mediaPipeInitFailed = false
        faceLandmarkKalman = null
        lastFaceAlignmentDebug = null
        faceTracker.release()
    }

    private fun createFile(type: String): File {
        val time = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val dir = context.getExternalFilesDir(Environment.DIRECTORY_DCIM)
        return if (type == "photo") File(dir, "IMG_$time.jpg").also { photoPath = it.absolutePath }
        else File(dir, "VID_$time.mp4").also { videoPath = it.absolutePath }
    }
    private fun createTempRecordingFile(prefix: String, extension: String): File =
        File(context.cacheDir, "${prefix}_${System.currentTimeMillis()}$extension")
}

/** Minimal [LifecycleOwner] so [ProcessCameraProvider.bindToLifecycle] works outside an Activity. */
private class CameraEngineLifecycle : LifecycleOwner {
    private val registry = LifecycleRegistry(this)
    override val lifecycle: Lifecycle
        get() = registry

    fun resumeCamera() {
        if (registry.currentState == Lifecycle.State.INITIALIZED) {
            registry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE)
        }
        if (registry.currentState == Lifecycle.State.CREATED) {
            registry.handleLifecycleEvent(Lifecycle.Event.ON_START)
        }
        if (registry.currentState == Lifecycle.State.STARTED) {
            registry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        }
    }

    fun destroy() {
        if (registry.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            registry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
        }
        if (registry.currentState.isAtLeast(Lifecycle.State.STARTED)) {
            registry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
        }
        if (registry.currentState.isAtLeast(Lifecycle.State.CREATED)) {
            registry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY)
        }
    }
}
