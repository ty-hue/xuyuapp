package com.example.pixelfree_camera

import android.content.Context
import android.graphics.Bitmap
import android.graphics.SurfaceTexture
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.GLES11Ext
import android.opengl.EGLExt
import android.opengl.GLUtils
import android.opengl.GLES20
import android.opengl.Matrix
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import android.view.Surface
import com.google.mediapipe.framework.TextureFrame
import com.google.mediapipe.glutil.EglManager
import com.google.mediapipe.solutions.facemesh.FaceMesh
import javax.microedition.khronos.egl.EGLSurface
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import java.util.concurrent.CountDownLatch
import kotlin.math.abs

/**
 * OpenGL ES 2.0 renderer: camera + beauty (whiten, contrast, big-eye, slim-face, portrait blur)
 * + AR overlays. Supports JPEG snapshot of the composed frame (WYSIWYG for photo).
 *
 * **Single display pipeline (default):** Each [ImageAnalysis] frame’s [PreparedFaceFrame.sensorArgb] is uploaded to
 * a [GL_TEXTURE_2D] and composed on the GL thread so **shown pixels = analyzed pixels** (time-aligned mesh).
 * [Preview] still binds the OES surface for session stability; OES is used only as fallback when prep fails
 * ([requestPreviewOesFrame]).
 *
 * Portrait blur: ML Kit selfie segmentation mask when available ([SelfieSegmentationHelper]); else
 * ellipse from MediaPipe face-oval AABB expanded and EMA-smoothed into [portraitShield*].
 *
 * AR: display uses Kalman [predict] at render time only (no blend toward async raw mesh). Several
 * effects use [FaceMeshArPass] — face triangles + live camera texture (mesh-attached tint), not flat
 * screen stickers. `green_hair` combines mesh filtering with ML Kit subject foreground mask
 * ([SubjectSegmentationHelper], texture unit 2) when available.
 */
internal class GlPreviewRenderer(
    private val outputTexture: SurfaceTexture,
    /** Used to load `glasses_06.glb` from [Context.getAssets] for [glasses_3d] AR. */
    private val androidContext: Context? = null,
) {
    private var renderThread: HandlerThread? = null
    private var renderHandler: Handler? = null
    private var surfaceWidth = 0
    private var surfaceHeight = 0
    private var eglDisplay = EGL14.EGL_NO_DISPLAY
    private var eglContext = EGL14.EGL_NO_CONTEXT
    private var eglSurface = EGL14.EGL_NO_SURFACE
    private var eglConfig: EGLConfig? = null
    /** Child [EglManager] sharing [FaceMesh.getGlContext]; owns Flutter + encoder window surfaces only. */
    private var faceMeshEglManager: EglManager? = null
    private var khrWindowSurface: EGLSurface? = null
    private var khrEncoderSurface: EGLSurface? = null
    /** True when preview samples MediaPipe GPU [TextureFrame] (official CameraInput path). */
    var usesFaceMeshCameraInput: Boolean = false
        private set
    /** From [com.google.mediapipe.solutioncore.CameraInput.isCameraRotated]. */
    @Volatile var cameraInputImageRotated: Boolean = false
    /**
     * 后置：在 [SurfaceTexture.getTransformMatrix] 之后对 OES 纹理坐标再左乘绕 (0.5,0.5) 的 180°，
     * 修正与 [userTexMatrix] 组合后仍相对现实世界倒立的问题（前置勿开）。
     */
    @Volatile var applyBackCameraTextureRotate180: Boolean = false
    private var encoderEglSurface: android.opengl.EGLSurface? = null
    private var encoderWidth = 0
    private var encoderHeight = 0
    /** 与 [MediaMuxer.setOrientationHint] 完整传感器角配合：编码前对纹理再旋 -90°，避免只改 hint 导致相册分辨率显小。 */
    private var encoderPreRotateNeg90 = false
    private val savedUserTexForEncoder = FloatArray(16)
    private var videoRecorder: GlSurfaceVideoRecorder? = null
    private var outputSurface: Surface? = null
    private var cameraSurfaceTexture: SurfaceTexture? = null
    private var cameraSurface: Surface? = null
    private var cameraTextureId = 0
    /** ML Kit selfie segmentation mask (LUMINANCE), texture unit 1 — full person vs ellipse fallback. */
    private var portraitSegTextureId = 0
    /** ML Kit subject-segmentation foreground mask (LUMINANCE), texture unit 2 — [green_hair] vs background. */
    private var subjectSegTextureId = 0

    private data class BeautyHandles(
        val program: Int,
        val position: Int,
        val texMatrix: Int,
        val userTexMatrix: Int,
        val stillCrop: Int,
        val brightness: Int,
        val contrast: Int,
        val ruddy: Int,
        val colorScale: Int,
        val colorOffset: Int,
        val bigEye: Int,
        val eyeBrighten: Int,
        val slimFace: Int,
        val portraitBlur: Int,
        val portraitBlurAr: Int,
        val eyeLeftUv: Int,
        val eyeRightUv: Int,
        val faceCenterUv: Int,
        val hasFace: Int,
        val sampler: Int,
        val faceMaskCenter: Int,
        val faceMaskHalf: Int,
        val portraitShieldCenter: Int,
        val portraitShieldHalf: Int,
        val smoothing: Int,
        val portraitSegMask: Int,
        val portraitSegReady: Int,
        val chinUv: Int,
        val mouthUv: Int,
        val foreheadUv: Int,
        val mouthLeftUv: Int,
        val mouthRightUv: Int,
        val faceNarrow: Int,
        val faceChin: Int,
        val faceV: Int,
        val faceNose: Int,
        val faceForehead: Int,
        val faceMouth: Int,
        val facePhiltrum: Int,
        val faceLongNose: Int,
        val faceEyeSpace: Int,
        val faceSmile: Int,
        val faceCanthus: Int,
    ) {
        companion object {
            fun create(program: Int) = BeautyHandles(
                program = program,
                position = GLES20.glGetAttribLocation(program, "aPosition"),
                texMatrix = GLES20.glGetUniformLocation(program, "uTexMatrix"),
                userTexMatrix = GLES20.glGetUniformLocation(program, "uUserTexMatrix"),
                stillCrop = GLES20.glGetUniformLocation(program, "uStillCrop"),
                brightness = GLES20.glGetUniformLocation(program, "uBrightness"),
                contrast = GLES20.glGetUniformLocation(program, "uContrast"),
                ruddy = GLES20.glGetUniformLocation(program, "uRuddy"),
                colorScale = GLES20.glGetUniformLocation(program, "uColorScale"),
                colorOffset = GLES20.glGetUniformLocation(program, "uColorOffset"),
                bigEye = GLES20.glGetUniformLocation(program, "uBigEye"),
                eyeBrighten = GLES20.glGetUniformLocation(program, "uEyeBrighten"),
                slimFace = GLES20.glGetUniformLocation(program, "uSlimFace"),
                portraitBlur = GLES20.glGetUniformLocation(program, "uPortraitBlur"),
                portraitBlurAr = GLES20.glGetUniformLocation(program, "uPortraitBlurAr"),
                eyeLeftUv = GLES20.glGetUniformLocation(program, "uEyeLeftUv"),
                eyeRightUv = GLES20.glGetUniformLocation(program, "uEyeRightUv"),
                faceCenterUv = GLES20.glGetUniformLocation(program, "uFaceCenterUv"),
                hasFace = GLES20.glGetUniformLocation(program, "uHasFace"),
                sampler = GLES20.glGetUniformLocation(program, "sTexture"),
                faceMaskCenter = GLES20.glGetUniformLocation(program, "uFaceMaskCenter"),
                faceMaskHalf = GLES20.glGetUniformLocation(program, "uFaceMaskHalf"),
                portraitShieldCenter = GLES20.glGetUniformLocation(program, "uPortraitShieldCenter"),
                portraitShieldHalf = GLES20.glGetUniformLocation(program, "uPortraitShieldHalf"),
                smoothing = GLES20.glGetUniformLocation(program, "uSmoothing"),
                portraitSegMask = GLES20.glGetUniformLocation(program, "uPortraitSegMask"),
                portraitSegReady = GLES20.glGetUniformLocation(program, "uPortraitSegReady"),
                chinUv = GLES20.glGetUniformLocation(program, "uChinUv"),
                mouthUv = GLES20.glGetUniformLocation(program, "uMouthUv"),
                foreheadUv = GLES20.glGetUniformLocation(program, "uForeheadUv"),
                mouthLeftUv = GLES20.glGetUniformLocation(program, "uMouthLeftUv"),
                mouthRightUv = GLES20.glGetUniformLocation(program, "uMouthRightUv"),
                faceNarrow = GLES20.glGetUniformLocation(program, "uFaceNarrow"),
                faceChin = GLES20.glGetUniformLocation(program, "uFaceChin"),
                faceV = GLES20.glGetUniformLocation(program, "uFaceV"),
                faceNose = GLES20.glGetUniformLocation(program, "uFaceNose"),
                faceForehead = GLES20.glGetUniformLocation(program, "uFaceForehead"),
                faceMouth = GLES20.glGetUniformLocation(program, "uFaceMouth"),
                facePhiltrum = GLES20.glGetUniformLocation(program, "uFacePhiltrum"),
                faceLongNose = GLES20.glGetUniformLocation(program, "uFaceLongNose"),
                faceEyeSpace = GLES20.glGetUniformLocation(program, "uFaceEyeSpace"),
                faceSmile = GLES20.glGetUniformLocation(program, "uFaceSmile"),
                faceCanthus = GLES20.glGetUniformLocation(program, "uFaceCanthus"),
            )
        }
    }

    private var beautyOes: BeautyHandles? = null
    private var beautyRgb: BeautyHandles? = null
    /** Filled from [PreparedFaceFrame.sensorArgb]; sampled as [GL_TEXTURE_2D] when [runOneFrame] uses analysis RGB. */
    private var analysisRgbTexId = 0
    /** Last composed draw source — for [runOneFrame] with refreshInput false (e.g. JPEG snapshot without swapping buffers). */
    private var lastComposedUsedAnalysisRgb = false
    private val analysisDisplayLock = Any()
    private val faceMeshFrameLock = Any()
    private var coalescedFaceMeshFrame: TextureFrame? = null
    /** Keeps the last **drawn** CameraInput texture alive until the next frame (see [runPipelineFaceMeshRedrawNoNewTexture]). */
    private var displayedFaceMeshFrame: TextureFrame? = null

    private data class PendingAnalysisFrame(val bitmap: Bitmap, val bufferRotationDegrees: Int)

    /** Latest frame wins; superseded bitmaps recycled without drawing (backpressure). */
    private var coalescedAnalysis: PendingAnalysisFrame? = null

    private val stMatrix = FloatArray(16)
    private val userTexMatrix = FloatArray(16)
    private val combinedTexMat = FloatArray(16)
    /** Left factor for [applyBackCameraOesTextureRotate180To]: R180 about texture center. */
    private val rotate180AroundCenter = FloatArray(16).also {
        Matrix.setIdentityM(it, 0)
        Matrix.translateM(it, 0, 0.5f, 0.5f, 0f)
        Matrix.rotateM(it, 0, 180f, 0f, 0f, 1f)
        Matrix.translateM(it, 0, -0.5f, -0.5f, 0f)
    }
    private val stMatrixMulTemp = FloatArray(16)
    /** Inverse of [combinedTexMat] for [landmarkToGl] — same quad as [VERTEX_SHADER] `uUserTexMatrix * uTexMatrix`. */
    private val invCombinedTexMat = FloatArray(16)
    /**
     * OES preview: [SurfaceTexture.getTransformMatrix] cached here for the **external** texture path only.
     * **Analysis [GL_TEXTURE_2D]** must not reuse it — OES packing ≠ [GLUtils.texImage2D](sensorArgb); use
     * [setStMatrixForAnalysisBuffer] + the same frame’s rotation instead, or landmarks float / twist vs face.
     */
    private val cachedPreviewStMatrix = FloatArray(16)
    private var hasCachedPreviewStMatrix = false
    private val tmpUv = FloatArray(4)
    private val tmpUvOut = FloatArray(4)
    private val tmpLandmarkInvIn = FloatArray(4)
    private val tmpLandmarkInvOut = FloatArray(4)

    private val colorScale = FloatArray(3) { 1f }
    private val colorOffset = FloatArray(3)
    private var brightness = 0f
    private var contrast = 1f
    private var ruddy = 0f
    private var bigEye = 0f
    private var eyeBrighten = 0f
    private var slimFace = 0f
    private var portraitBlurBeauty = 0f
    private var smoothing = 0f
    private var faceNarrow = 0f
    private var faceChin = 0f
    private var faceV = 0f
    private var faceNose = 0f
    private var faceForeheadAmt = 0f
    private var faceMouth = 0f
    private var facePhiltrum = 0f
    private var faceLongNose = 0f
    private var faceEyeSpace = 0f
    private var faceSmile = 0f
    private var faceCanthus = 0f

    @Volatile var kalmanFilter: LandmarkKalmanFilter? = null
    /** Raw MediaPipe mesh (async). Laser eyes use [latestFull] so overlays track each detection frame. */
    @Volatile var mediaPipeTracker: MediaPipeFaceTracker? = null
    /** ML Kit person/background mask for portrait blur ([SelfieSegmentationHelper]). */
    @Volatile var selfieSegmentationHelper: SelfieSegmentationHelper? = null
    /** ML Kit subject foreground mask for [green_hair] AR ([SubjectSegmentationHelper]). */
    @Volatile var subjectSegmentationHelper: SubjectSegmentationHelper? = null

    private var portraitSegMaskGpuReady = false
    private var subjectSegMaskGpuReady = false

    /** Face mesh + camera texture AR (replaces flat 2D stickers for listed effects). */
    private val faceMeshArPass = FaceMeshArPass()
    /** Cyan wireframe on top of [face_mesh_uv] textured mesh. */
    private val faceMeshWireframeOverlay = FaceMeshEffect()
    @Volatile private var currentLandmarks: FaceLandmarks? = null
    /** Last good face mesh for AR when [currentLandmarks] is null (face left frame / tracker gap). */
    private var cachedLandmarksForAr: FaceLandmarks? = null

    /** EMA-smoothed ellipse for portrait blur only (expanded AABB of face oval); reduces frame jitter. */
    private var portraitShieldMx = 0.5f
    private var portraitShieldMy = 0.5f
    private var portraitShieldHx = 0.25f
    private var portraitShieldHy = 0.32f

    @Volatile var currentArEffect: String = "none"
        set(value) {
            if (field == value) return
            field = value
            val rh = renderHandler ?: return
            // 必须等特效在 GL 线程创建完再返回，否则 Flutter await setArEffect 后首帧 activeEffect 仍为 null（眼镜完全不显示）。
            if (Looper.myLooper() == rh.looper) {
                switchEffectInternal(value)
            } else {
                runSync { switchEffectInternal(value) }
            }
        }
    private var activeEffect: ArEffectRenderer? = null

    private var pendingSnapshot: ((ByteArray?, Int, Int) -> Unit)? = null

    private val identityStillCrop = FloatArray(16).also { Matrix.setIdentityM(it, 0) }

    /** Sequential JPEG captures across preview frames (e.g. GIF). */
    private var jpegBurstRemaining: Int = 0
    private var jpegBurstList: MutableList<ByteArray>? = null
    private var jpegBurstCallback: ((List<ByteArray>) -> Unit)? = null

    /** >1 stretches muxed PTS timeline (slow-mo feel); <1 compresses (fast). */
    @Volatile var recordPresentationMultiplier: Double = 1.0
    private var encoderAccumulatedPresentationNs: Long = 0L
    private val encoderFrameDurationNs: Long = 1_000_000_000L / 30L

    private val vertexBuffer: FloatBuffer = allocBuf(VERTICES)

    /**
     * @param faceMeshForSharedEgl If non-null, create a **share-group** EGL context from [FaceMesh.getGlContext]
     * (same pattern as official `SolutionGlSurfaceView` + [EglManager]) so CameraInput GPU textures are sampleable.
     */
    fun start(width: Int, height: Int, rotationDegrees: Int, mirror: Boolean, faceMeshForSharedEgl: FaceMesh? = null) {
        release()
        renderThread = HandlerThread("GlPreviewRenderer").also { it.start() }
        renderHandler = Handler(renderThread!!.looper)
        runSync {
            if (faceMeshForSharedEgl != null) {
                initEglSharedFaceMesh(faceMeshForSharedEgl, width, height)
            } else {
                initEgl(width, height)
            }
            updateTransformInternal(rotationDegrees, mirror)
            updateEffectsInternal(emptyMap(), emptyMap())
        }
    }

    /**
     * Draw one frame using [TextureFrame] from [com.google.mediapipe.solutions.facemesh.FaceMeshResult.acquireInputTextureFrame].
     * Supersedes undrawn frames (released) like [queueAnalysisDisplayFrame]. [TextureFrame.release] after draw on render thread.
     */
    fun queueFaceMeshFrame(textureFrame: TextureFrame) {
        if (!usesFaceMeshCameraInput) {
            textureFrame.release()
            return
        }
        val superseded = synchronized(faceMeshFrameLock) {
            val old = coalescedFaceMeshFrame
            coalescedFaceMeshFrame = textureFrame
            old
        }
        superseded?.release()
        renderHandler?.post { drainFaceMeshFrameQueue() }
    }

    private fun drainFaceMeshFrameQueue() {
        val tf = synchronized(faceMeshFrameLock) {
            val p = coalescedFaceMeshFrame
            coalescedFaceMeshFrame = null
            p
        } ?: return
        try {
            runPipelineFaceMeshInput(tf)
        } catch (_: Throwable) {
            tf.release()
            return
        }
        val prev = displayedFaceMeshFrame
        displayedFaceMeshFrame = tf
        prev?.release()
    }

    fun getCameraSurface(): Surface? = cameraSurface
    fun getInputTextureId(): Int = if (usesFaceMeshCameraInput) lastFaceMeshPipeTexId else cameraTextureId

    /**
     * Display + landmarks use the **same** [PreparedFaceFrame.sensorArgb] as MediaPath; runs on render thread.
     * [imageInfoRotationDegrees] drives [setStMatrixForAnalysisBuffer] for this bitmap (do not use OES matrix).
     * Supersedes any older undrawn bitmap (recycled). Do not recycle [sensorArgb] after calling — GL owns it.
     */
    fun queueAnalysisDisplayFrame(sensorArgb: Bitmap, imageInfoRotationDegrees: Int) {
        val superseded = synchronized(analysisDisplayLock) {
            val old = coalescedAnalysis
            coalescedAnalysis = PendingAnalysisFrame(sensorArgb, imageInfoRotationDegrees)
            old
        }
        superseded?.bitmap?.recycle()
        renderHandler?.post { drainAnalysisDisplayQueue() }
    }

    private fun drainAnalysisDisplayQueue() {
        val pending = synchronized(analysisDisplayLock) {
            val p = coalescedAnalysis
            coalescedAnalysis = null
            p
        } ?: return
        try {
            runOneFrame(pending.bitmap, pending.bufferRotationDegrees)
        } finally {
            if (!pending.bitmap.isRecycled) pending.bitmap.recycle()
        }
    }

    /** Fallback when [PreparedFaceFrame] is null: draw current Preview OES frame (may not match last ML frame). */
    fun requestPreviewOesFrame() {
        renderHandler?.post { runOneFrame(null) }
    }

    fun updateTransform(rot: Int, mirror: Boolean) {
        renderHandler?.post { updateTransformInternal(rot, mirror) }
    }

    fun updateEffects(b: Map<String, Any?>, f: Map<String, Any?>) {
        renderHandler?.post { updateEffectsInternal(b, f) }
    }

    /**
     * Capture current composed frame as JPEG (preview resolution). Callback may run on render thread.
     * Width/height match GL readback / saved JPEG pixels.
     */
    fun requestJpegSnapshot(done: (ByteArray?, Int, Int) -> Unit) {
        renderHandler?.post {
            pendingSnapshot = done
            if (usesFaceMeshCameraInput) {
                runPipelineFaceMeshRedrawNoNewTexture()
            } else {
                runOneFrame(refreshInput = false)
            }
        }
    }

    /**
     * Captures [count] consecutive preview frames as JPEG (one per incoming camera frame).
     * Callback runs on the GL render thread.
     */
    fun requestJpegBurst(count: Int, done: (List<ByteArray>) -> Unit) {
        if (count <= 0) {
            renderHandler?.post { done(emptyList()) }
            return
        }
        renderHandler?.post {
            jpegBurstList = mutableListOf()
            jpegBurstRemaining = count
            jpegBurstCallback = done
        }
    }

    /**
     * Renders the same pipeline to [surface] (MediaCodec input) — must run on render thread.
     * [recorder] receives [GlSurfaceVideoRecorder.drainOutput] after each frame.
     *
     * @param preRotateNeg90ForFullOrientationHint 为 true 时，编码多乘一次绕 Z 轴 -90°，与完整 orientation 元数据一起抵消「多转 90°」。
     */
    fun attachVideoEncoderSync(
        recorder: GlSurfaceVideoRecorder,
        surface: Surface,
        width: Int,
        height: Int,
        preRotateNeg90ForFullOrientationHint: Boolean = false,
    ) {
        runSync {
            val em = faceMeshEglManager
            if (em != null) {
                khrEncoderSurface?.let { runCatching { em.releaseSurface(it) } }
                khrEncoderSurface = em.createWindowSurface(surface)
                encoderEglSurface = EGL14.EGL_NO_SURFACE
            } else {
                val cfg = eglConfig ?: return@runSync
                encoderEglSurface = EGL14.eglCreateWindowSurface(eglDisplay, cfg, surface, intArrayOf(EGL14.EGL_NONE), 0)
            }
            encoderWidth = width
            encoderHeight = height
            encoderPreRotateNeg90 = preRotateNeg90ForFullOrientationHint
            videoRecorder = recorder
            encoderAccumulatedPresentationNs = 0L
        }
    }

    /** Stop encoding to MediaCodec surface (destroy encoder EGL window). */
    fun stopVideoEncodingSync() {
        runSync {
            videoRecorder = null
            encoderPreRotateNeg90 = false
            encoderAccumulatedPresentationNs = 0L
            val em = faceMeshEglManager
            if (em != null && khrEncoderSurface != null) {
                runCatching { em.releaseSurface(khrEncoderSurface!!) }
                khrEncoderSurface = null
            }
            encoderEglSurface?.let { s ->
                if (eglDisplay != EGL14.EGL_NO_DISPLAY) EGL14.eglDestroySurface(eglDisplay, s)
            }
            encoderEglSurface = null
        }
    }

    fun release() {
        val t = renderThread ?: return
        runSync { releaseInternal() }
        t.quitSafely()
        t.join()
        renderThread = null
        renderHandler = null
    }

    /**
     * CameraX [SurfaceRequest.resolution] is often **not** the JPEG-based size passed to [start].
     * We must set **both** the camera OES buffer and the **Flutter output** [outputTexture] to this size,
     * recreate the EGL window surface, and [glViewport], or `stMatrix` letterboxing breaks linear
     * landmark ↔ NDC mapping and the mesh drifts globally.
     */
    fun syncPreviewPipelineSize(width: Int, height: Int) {
        if (width <= 0 || height <= 0) return
        if (renderThread == null) return
        runSync { syncPreviewPipelineSizeInternal(width, height) }
    }

    private fun syncPreviewPipelineSizeInternal(w: Int, h: Int) {
        cameraSurfaceTexture?.setDefaultBufferSize(w, h)
        outputTexture.setDefaultBufferSize(w, h)
        val resized = surfaceWidth != w || surfaceHeight != h
        surfaceWidth = w
        surfaceHeight = h
        val em = faceMeshEglManager
        if (em != null && khrWindowSurface != null && resized) {
            runCatching { em.releaseSurface(khrWindowSurface!!) }
            khrWindowSurface = em.createWindowSurface(outputTexture)
            em.makeCurrent(khrWindowSurface!!, khrWindowSurface!!)
        } else {
            val disp = eglDisplay
            val cfg = eglConfig
            val outSurf = outputSurface
            if (resized && disp != EGL14.EGL_NO_DISPLAY && cfg != null && outSurf != null &&
                eglContext != EGL14.EGL_NO_CONTEXT
            ) {
                if (eglSurface != EGL14.EGL_NO_SURFACE) {
                    EGL14.eglMakeCurrent(disp, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, eglContext)
                    EGL14.eglDestroySurface(disp, eglSurface)
                    eglSurface = EGL14.EGL_NO_SURFACE
                }
                eglSurface =
                    EGL14.eglCreateWindowSurface(disp, cfg, outSurf, intArrayOf(EGL14.EGL_NONE), 0)
                if (eglSurface != EGL14.EGL_NO_SURFACE) {
                    EGL14.eglMakeCurrent(disp, eglSurface, eglSurface, eglContext)
                }
            } else if (eglSurface != EGL14.EGL_NO_SURFACE && eglContext != EGL14.EGL_NO_CONTEXT &&
                disp != EGL14.EGL_NO_DISPLAY
            ) {
                EGL14.eglMakeCurrent(disp, eglSurface, eglSurface, eglContext)
            }
        }
        GLES20.glViewport(0, 0, w, h)
        hasCachedPreviewStMatrix = false
    }

    private fun runSync(block: () -> Unit) {
        val l = CountDownLatch(1)
        renderHandler?.post { try { block() } finally { l.countDown() } }
        l.await()
    }

    /**
     * MediaPipe / bitmap: x→right, y→**down** (y=0 top). Fullscreen quad `baseSt`: s→right, t→**up**
     * (t=0 bottom NDC, t=1 top). Same physical pixel → texture UV **before** [combinedTexMat] is **(s,t)=(x,1−y)**
     * (matches [GLUtils.texImage2D] + fragment `vTexCoord`).
     */
    private fun landmarkNormToQuadSt(x: Float, y: Float): Pair<Float, Float> =
        Pair(x, 1f - y)

    /** Per-frame render correction: must match in [landmarkToGl] and [landmarkToTexUvRaw]. */
    private fun renderAdjustBufferNorm(x: Float, y: Float): Pair<Float, Float> {
        val xa = (x + LandmarkSpaceTuning.RENDER_LANDMARK_SHIFT_BUF_X).coerceIn(0f, 1f)
        val ya = (y + LandmarkSpaceTuning.RENDER_LANDMARK_SHIFT_BUF_Y).coerceIn(0f, 1f)
        return xa to ya
    }

    /**
     * Normalized landmark → **NDC** for AR overlays. Vertex shader uses `vTexCoord = combined * baseSt` with
     * `baseSt = (gl_Position.xy+1)*0.5`, so the buffer pixel at `(x,y)` has pre-transform ST `(x,1−y)` and appears at
     * `baseSt = inv(combined) * (x,1−y)` → **NDC = 2·baseSt − 1** (homogeneous divide). This matches the composed
     * preview for both OES and analysis [GL_TEXTURE_2D] paths.
     */
    fun landmarkToGl(x: Float, y: Float): Pair<Float, Float> {
        val (xb, yb) = renderAdjustBufferNorm(x, y)
        val (s, t) = landmarkNormToQuadSt(xb, yb)
        tmpLandmarkInvIn[0] = s
        tmpLandmarkInvIn[1] = t
        tmpLandmarkInvIn[2] = 0f
        tmpLandmarkInvIn[3] = 1f
        Matrix.multiplyMV(tmpLandmarkInvOut, 0, invCombinedTexMat, 0, tmpLandmarkInvIn, 0)
        val w = tmpLandmarkInvOut[3]
        val iw = if (kotlin.math.abs(w) < 1e-5f) 1f else w
        val bx = tmpLandmarkInvOut[0] / iw
        val by = tmpLandmarkInvOut[1] / iw
        return Pair(bx * 2f - 1f, by * 2f - 1f)
    }

    /**
     * Same as fragment `vTexCoord` for this landmark: `combinedTexMat * vec4(s,t,0,1)` with
     * `(s,t)` = [landmarkNormToQuadSt](x,y). **Not** clamped — [landmarkToTexUv] clamps for sampling.
     */
    private fun landmarkToTexUvRaw(x: Float, y: Float): Pair<Float, Float> {
        val (xb, yb) = renderAdjustBufferNorm(x, y)
        val (s, t) = landmarkNormToQuadSt(xb, yb)
        tmpUv[0] = s
        tmpUv[1] = t
        tmpUv[2] = 0f
        tmpUv[3] = 1f
        Matrix.multiplyMV(tmpUvOut, 0, combinedTexMat, 0, tmpUv, 0)
        val w = tmpUvOut[3]
        val iw = if (kotlin.math.abs(w) < 1e-5f) 1f else w
        return Pair(tmpUvOut[0] / iw, tmpUvOut[1] / iw)
    }

    /**
     * Landmark → UV for **texture2D** / external-OES sampling — clamped to [0,1] for stable sampling.
     */
    private fun landmarkToTexUv(x: Float, y: Float): Pair<Float, Float> {
        val (u, v) = landmarkToTexUvRaw(x, y)
        return Pair(u.coerceIn(0f, 1f), v.coerceIn(0f, 1f))
    }

    fun getCurrentLandmarks(): FaceLandmarks? = currentLandmarks

    private fun initEgl(w: Int, h: Int) {
        surfaceWidth = w
        surfaceHeight = h
        eglDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        val ver = IntArray(2)
        EGL14.eglInitialize(eglDisplay, ver, 0, ver, 1)
        val cfgs = arrayOfNulls<EGLConfig>(1)
        val cnt = IntArray(1)
        val recordable = 0x3142
        val attribsRecordable = intArrayOf(
            EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8,
            EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_RENDERABLE_TYPE, 4,
            recordable, 1,
            EGL14.EGL_NONE,
        )
        val attribsBasic = intArrayOf(
            EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8,
            EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_RENDERABLE_TYPE, 4, EGL14.EGL_NONE,
        )
        if (!EGL14.eglChooseConfig(eglDisplay, attribsRecordable, 0, cfgs, 0, 1, cnt, 0) || cnt[0] == 0) {
            EGL14.eglChooseConfig(eglDisplay, attribsBasic, 0, cfgs, 0, 1, cnt, 0)
        }
        eglConfig = cfgs[0]
        eglContext = EGL14.eglCreateContext(
            eglDisplay, cfgs[0], EGL14.EGL_NO_CONTEXT,
            intArrayOf(0x3098, 2, EGL14.EGL_NONE), 0,
        )
        outputTexture.setDefaultBufferSize(w, h)
        outputSurface = Surface(outputTexture)
        eglSurface = EGL14.eglCreateWindowSurface(
            eglDisplay, cfgs[0], outputSurface,
            intArrayOf(EGL14.EGL_NONE), 0,
        )
        EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)
        // Opaque clear avoids some devices compositing (0,0,0,0) as fully transparent over black.
        GLES20.glClearColor(0f, 0f, 0f, 1f)

        beautyOes = BeautyHandles.create(buildProgram(VERTEX_SHADER, FRAGMENT_SHADER))
        beautyRgb = BeautyHandles.create(buildProgram(VERTEX_SHADER, FRAGMENT_SHADER_RGB))

        cameraTextureId = createExternalTexture()
        cameraSurfaceTexture = SurfaceTexture(cameraTextureId).also { st ->
            st.setDefaultBufferSize(w, h)
            // Drain Preview + cache [getTransformMatrix] for analysis-frame draws (same UV mapping as OES).
            st.setOnFrameAvailableListener(
                { renderHandler?.post { refreshPreviewTransformMatrixFromOes() } },
                renderHandler,
            )
        }
        cameraSurface = Surface(cameraSurfaceTexture)
        faceMeshArPass.init()
        faceMeshWireframeOverlay.init()
    }

    private fun initEglSharedFaceMesh(faceMesh: FaceMesh, w: Int, h: Int) {
        usesFaceMeshCameraInput = true
        surfaceWidth = w
        surfaceHeight = h
        val recordableAttr = intArrayOf(EGLExt.EGL_RECORDABLE_ANDROID, 1)
        val em = EglManager(faceMesh.getGlContext(), recordableAttr)
        faceMeshEglManager = em
        eglContext = em.egl14Context
        eglDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        eglConfig = null
        eglSurface = EGL14.EGL_NO_SURFACE
        outputTexture.setDefaultBufferSize(w, h)
        outputSurface = Surface(outputTexture)
        val win = em.createWindowSurface(outputTexture)
        khrWindowSurface = win
        em.makeCurrent(win, win)
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        beautyOes = BeautyHandles.create(buildProgram(VERTEX_SHADER, FRAGMENT_SHADER))
        beautyRgb = BeautyHandles.create(buildProgram(VERTEX_SHADER, FRAGMENT_SHADER_RGB))
        cameraTextureId = 0
        cameraSurfaceTexture = null
        cameraSurface = null
        faceMeshArPass.init()
        faceMeshWireframeOverlay.init()
    }

    private fun makeCurrentMainSurface() {
        val em = faceMeshEglManager
        val khr = khrWindowSurface
        if (em != null && khr != null) {
            em.makeCurrent(khr, khr)
        } else if (eglDisplay != EGL14.EGL_NO_DISPLAY && eglSurface != EGL14.EGL_NO_SURFACE &&
            eglContext != EGL14.EGL_NO_CONTEXT
        ) {
            EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)
        }
    }

    private fun swapMainSurfaceBuffers() {
        val em = faceMeshEglManager
        val khr = khrWindowSurface
        if (em != null && khr != null) {
            em.egl.eglSwapBuffers(em.eglDisplay, khr)
        } else {
            EGL14.eglSwapBuffers(eglDisplay, eglSurface)
        }
    }

    private var lastFaceMeshPipeTexId: Int = 0
    private val lastFaceMeshStMatrix = FloatArray(16)

    private fun runPipelineFaceMeshInput(tf: TextureFrame) {
        val em = faceMeshEglManager ?: return
        val win = khrWindowSurface ?: return
        em.makeCurrent(win, win)
        Matrix.setIdentityM(stMatrix, 0)
        if (cameraInputImageRotated) {
            Matrix.translateM(stMatrix, 0, 0.5f, 0.5f, 0f)
            Matrix.rotateM(stMatrix, 0, 90f, 0f, 0f, 1f)
            Matrix.translateM(stMatrix, 0, -0.5f, -0.5f, 0f)
        }
        applyBackCameraOesTextureRotate180To(stMatrix)
        Matrix.multiplyMM(combinedTexMat, 0, userTexMatrix, 0, stMatrix, 0)
        if (!Matrix.invertM(invCombinedTexMat, 0, combinedTexMat, 0)) {
            Matrix.setIdentityM(invCombinedTexMat, 0)
        }
        System.arraycopy(stMatrix, 0, lastFaceMeshStMatrix, 0, 16)
        lastFaceMeshPipeTexId = tf.textureName
        // MediaPipe Graph 输出的 TextureFrame 在多数设备上为 GL_TEXTURE_2D，用 beautyRgb 采样；
        // 若误当作 EXTERNAL_OES 绑定，整屏美颜采样失败 → 全黑（仅 AR 不依赖该纹理时仍可见）。
        lastComposedUsedAnalysisRgb = true
        val nowNs = System.nanoTime()
        currentLandmarks = mediaPipeTracker?.latestFull() ?: kalmanFilter?.predict(nowNs)
        uploadPortraitSegMaskTexture()
        uploadSubjectMaskTexture()
        GLES20.glViewport(0, 0, surfaceWidth, surfaceHeight)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        drawScene(surfaceWidth, surfaceHeight, useAnalysisRgb = true, cameraPipeRgbTexId = tf.textureName)
        deliverSnapshotAndBurst()
        swapMainSurfaceBuffers()
        drawEncoderPassIfAny()
    }

    private fun runPipelineFaceMeshRedrawNoNewTexture() {
        val em = faceMeshEglManager ?: return
        val win = khrWindowSurface ?: return
        if (lastFaceMeshPipeTexId == 0) return
        em.makeCurrent(win, win)
        System.arraycopy(lastFaceMeshStMatrix, 0, stMatrix, 0, 16)
        Matrix.multiplyMM(combinedTexMat, 0, userTexMatrix, 0, stMatrix, 0)
        if (!Matrix.invertM(invCombinedTexMat, 0, combinedTexMat, 0)) {
            Matrix.setIdentityM(invCombinedTexMat, 0)
        }
        val nowNs = System.nanoTime()
        currentLandmarks = mediaPipeTracker?.latestFull() ?: kalmanFilter?.predict(nowNs)
        uploadPortraitSegMaskTexture()
        uploadSubjectMaskTexture()
        GLES20.glViewport(0, 0, surfaceWidth, surfaceHeight)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        drawScene(surfaceWidth, surfaceHeight, useAnalysisRgb = true, cameraPipeRgbTexId = lastFaceMeshPipeTexId)
        deliverSnapshotAndBurst()
        swapMainSurfaceBuffers()
        drawEncoderPassIfAny()
    }

    private fun deliverSnapshotAndBurst() {
        val snap = pendingSnapshot
        if (snap != null) {
            pendingSnapshot = null
            val result = renderStillSnapshotToJpeg()
            snap(result.first, result.second, result.third)
        }
        if (jpegBurstRemaining > 0) {
            val jpeg = readPixelsToJpeg(surfaceWidth, surfaceHeight)
            val list = jpegBurstList
            if (jpeg != null && list != null) {
                list.add(jpeg)
            }
            jpegBurstRemaining--
            if (jpegBurstRemaining == 0) {
                val cb = jpegBurstCallback
                jpegBurstCallback = null
                val doneList = list?.toList() ?: emptyList()
                jpegBurstList = null
                cb?.invoke(doneList)
            }
        }
    }

    /**
     * 与当前帧 [drawScene] 写入默认 framebuffer 的像素一致（与 [jpegBurstRemaining] 路径相同），
     * 不再二次绘制到竖屏 FBO，避免与 Flutter [FittedBox]/fitWidth 预览构图不一致。
     */
    private fun renderStillSnapshotToJpeg(): Triple<ByteArray?, Int, Int> {
        val bw = surfaceWidth
        val bh = surfaceHeight
        if (bw <= 1 || bh <= 1) return Triple(null, 0, 0)
        makeCurrentMainSurface()
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)
        GLES20.glViewport(0, 0, bw, bh)
        val jpeg = readPixelsToJpeg(bw, bh)
        return Triple(jpeg, bw, bh)
    }

    private fun drawEncoderPassIfAny() {
        val rec = videoRecorder
        val em = faceMeshEglManager
        val kEnc = khrEncoderSurface
        if (rec != null && em != null && kEnc != null && encoderWidth > 0 && encoderHeight > 0) {
            em.makeCurrent(kEnc, kEnc)
            GLES20.glViewport(0, 0, encoderWidth, encoderHeight)
            GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
            if (encoderPreRotateNeg90) {
                System.arraycopy(userTexMatrix, 0, savedUserTexForEncoder, 0, 16)
                Matrix.translateM(userTexMatrix, 0, 0.5f, 0.5f, 0f)
                Matrix.rotateM(userTexMatrix, 0, -90f, 0f, 0f, 1f)
                Matrix.translateM(userTexMatrix, 0, -0.5f, -0.5f, 0f)
                Matrix.multiplyMM(combinedTexMat, 0, userTexMatrix, 0, stMatrix, 0)
                if (!Matrix.invertM(invCombinedTexMat, 0, combinedTexMat, 0)) {
                    Matrix.setIdentityM(invCombinedTexMat, 0)
                }
                drawScene(
                    encoderWidth,
                    encoderHeight,
                    useAnalysisRgb = true,
                    cameraPipeRgbTexId = lastFaceMeshPipeTexId,
                )
                System.arraycopy(savedUserTexForEncoder, 0, userTexMatrix, 0, 16)
                Matrix.multiplyMM(combinedTexMat, 0, userTexMatrix, 0, stMatrix, 0)
                if (!Matrix.invertM(invCombinedTexMat, 0, combinedTexMat, 0)) {
                    Matrix.setIdentityM(invCombinedTexMat, 0)
                }
            } else {
                drawScene(
                    encoderWidth,
                    encoderHeight,
                    useAnalysisRgb = true,
                    cameraPipeRgbTexId = lastFaceMeshPipeTexId,
                )
            }
            val step = (encoderFrameDurationNs.toDouble() * recordPresentationMultiplier.coerceIn(0.25, 4.0)).toLong()
            encoderAccumulatedPresentationNs += step
            em.egl.eglSwapBuffers(em.eglDisplay, kEnc)
            rec.drainOutput()
            val win = khrWindowSurface ?: return
            em.makeCurrent(win, win)
        } else if (encoderEglSurface != EGL14.EGL_NO_SURFACE && encoderEglSurface != null && rec != null &&
            encoderWidth > 0 && encoderHeight > 0
        ) {
            EGL14.eglMakeCurrent(eglDisplay, encoderEglSurface, encoderEglSurface, eglContext)
            GLES20.glViewport(0, 0, encoderWidth, encoderHeight)
            GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
            if (encoderPreRotateNeg90) {
                System.arraycopy(userTexMatrix, 0, savedUserTexForEncoder, 0, 16)
                Matrix.translateM(userTexMatrix, 0, 0.5f, 0.5f, 0f)
                Matrix.rotateM(userTexMatrix, 0, -90f, 0f, 0f, 1f)
                Matrix.translateM(userTexMatrix, 0, -0.5f, -0.5f, 0f)
                Matrix.multiplyMM(combinedTexMat, 0, userTexMatrix, 0, stMatrix, 0)
                if (!Matrix.invertM(invCombinedTexMat, 0, combinedTexMat, 0)) {
                    Matrix.setIdentityM(invCombinedTexMat, 0)
                }
                drawScene(encoderWidth, encoderHeight, lastComposedUsedAnalysisRgb)
                System.arraycopy(savedUserTexForEncoder, 0, userTexMatrix, 0, 16)
                Matrix.multiplyMM(combinedTexMat, 0, userTexMatrix, 0, stMatrix, 0)
                if (!Matrix.invertM(invCombinedTexMat, 0, combinedTexMat, 0)) {
                    Matrix.setIdentityM(invCombinedTexMat, 0)
                }
            } else {
                drawScene(encoderWidth, encoderHeight, lastComposedUsedAnalysisRgb)
            }
            val step = (encoderFrameDurationNs.toDouble() * recordPresentationMultiplier.coerceIn(0.25, 4.0)).toLong()
            encoderAccumulatedPresentationNs += step
            EGLExt.eglPresentationTimeANDROID(eglDisplay, encoderEglSurface!!, encoderAccumulatedPresentationNs)
            EGL14.eglSwapBuffers(eglDisplay, encoderEglSurface!!)
            rec.drainOutput()
            makeCurrentMainSurface()
        }
    }

    private fun updateTransformInternal(deg: Int, @Suppress("UNUSED_PARAMETER") mirror: Boolean) {
        Matrix.setIdentityM(userTexMatrix, 0)
        Matrix.translateM(userTexMatrix, 0, 0.5f, 0.5f, 0f)
        if (deg != 0) Matrix.rotateM(userTexMatrix, 0, deg.toFloat(), 0f, 0f, 1f)
        Matrix.translateM(userTexMatrix, 0, -0.5f, -0.5f, 0f)
    }

    /** [m] becomes [rotate180AroundCenter] * [m] when [applyBackCameraTextureRotate180]. */
    private fun applyBackCameraOesTextureRotate180To(m: FloatArray) {
        if (!applyBackCameraTextureRotate180) return
        Matrix.multiplyMM(stMatrixMulTemp, 0, rotate180AroundCenter, 0, m, 0)
        System.arraycopy(stMatrixMulTemp, 0, m, 0, 16)
    }

    private fun f01(bs: Map<String, Any?>, key: String): Float =
        ((bs[key] as? Number)?.toFloat() ?: 0f).coerceIn(0f, 1f)

    private fun updateEffectsInternal(bs: Map<String, Any?>, fs: Map<String, Any?>) {
        val wh = BeautyFlutterScale.whiteningFromFlutter(bs["whitening"] as? Number)
        val sh = ((bs["sharpen"] as? Number)?.toFloat() ?: 0f).coerceIn(0f, 1f)
        ruddy = ((bs["ruddy"] as? Number)?.toFloat() ?: 0f).coerceIn(0f, 1f)
        bigEye = ((bs["bigEye"] as? Number)?.toFloat() ?: 0f).coerceIn(0f, 1f)
        eyeBrighten = BeautyFlutterScale.eyeBrightenFromFlutter(bs["eyeBrighten"] as? Number)
        slimFace = BeautyFlutterScale.slimFaceFromFlutter(bs["slimFace"] as? Number)
        portraitBlurBeauty = ((bs["portraitBlur"] as? Number)?.toFloat() ?: 0f).coerceIn(0f, 1f)
        smoothing = BeautyFlutterScale.smoothingFromFlutter(bs["smoothing"] as? Number)
        faceNarrow = BeautyFlutterScale.faceNarrowFromFlutter(bs["faceNarrow"] as? Number)
        faceChin = BeautyFlutterScale.faceChinFromFlutter(bs["faceChin"] as? Number)
        faceV = f01(bs, "faceV")
        faceNose = f01(bs, "faceNose")
        faceForeheadAmt = f01(bs, "faceForehead")
        faceMouth = f01(bs, "faceMouth")
        facePhiltrum = f01(bs, "facePhiltrum")
        faceLongNose = f01(bs, "faceLongNose")
        faceEyeSpace = f01(bs, "faceEyeSpace")
        faceSmile = f01(bs, "faceSmile")
        faceCanthus = f01(bs, "faceCanthus")
        // Slider → GL: mid/high values need clear visual feedback (shader also does mid-tone lift).
        brightness = wh * 0.30f
        contrast = 1f + sh * 0.18f
        colorScale[0] = 1f
        colorScale[1] = 1f
        colorScale[2] = 1f
        colorOffset[0] = 0f
        colorOffset[1] = 0f
        colorOffset[2] = 0f
        val inten = ((fs["intensity"] as? Number)?.toFloat() ?: 0f).coerceIn(0f, 1f)
        when ((fs["filterId"] as? String)?.lowercase()) {
            "cool", "lengku" -> blendColor(floatArrayOf(0.95f, 1f, 1.08f), floatArrayOf(0f, 0.015f, 0.047f), inten)
            "warm", "naicha" -> blendColor(floatArrayOf(1.06f, 1f, 0.92f), floatArrayOf(0.039f, 0.015f, -0.016f), inten)
            "fresh", "qingxin" -> blendColor(floatArrayOf(1.02f, 1.04f, 1f), floatArrayOf(0.015f, 0.031f, 0.023f), inten)
            "rixi" -> blendColor(floatArrayOf(1.04f, 1.01f, 0.9f), floatArrayOf(0.047f, 0.023f, -0.031f), inten)
        }
    }

    private fun blendColor(ts: FloatArray, to: FloatArray, i: Float) {
        if (i <= 0f) return
        for (c in 0..2) {
            colorScale[c] = 1f + (ts[c] - 1f) * i
            colorOffset[c] = to[c] * i
        }
    }

    /** Upload latest ML Kit mask to a 2D LUMINANCE texture (unit 1). Skips if portrait blur is off. */
    private fun uploadPortraitSegMaskTexture() {
        val helper = selfieSegmentationHelper
        val pb = when (currentArEffect) {
            "portrait_blur" -> 1f
            else -> portraitBlurBeauty
        }
        if (helper == null || pb <= 0.001f) {
            portraitSegMaskGpuReady = false
            return
        }
        val bytes = helper.latestMaskBytes
        val w = helper.latestMaskWidth
        val h = helper.latestMaskHeight
        if (!helper.hasValidMask || bytes == null || w <= 0 || h <= 0 || bytes.size < w * h) {
            portraitSegMaskGpuReady = false
            return
        }
        if (portraitSegTextureId == 0) {
            val ids = IntArray(1)
            GLES20.glGenTextures(1, ids, 0)
            portraitSegTextureId = ids[0]
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, portraitSegTextureId)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        } else {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, portraitSegTextureId)
        }
        GLES20.glPixelStorei(GLES20.GL_UNPACK_ALIGNMENT, 1)
        GLES20.glTexImage2D(
            GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE,
            w, h, 0,
            GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE,
            ByteBuffer.wrap(bytes),
        )
        portraitSegMaskGpuReady = true
    }

    /** Upload subject foreground mask for green_hair (texture unit 2). */
    private fun uploadSubjectMaskTexture() {
        val helper = subjectSegmentationHelper
        if (currentArEffect != "green_hair" || helper == null) {
            subjectSegMaskGpuReady = false
            return
        }
        val bytes = helper.latestMaskBytes
        val w = helper.latestMaskWidth
        val h = helper.latestMaskHeight
        if (!helper.hasValidMask || bytes == null || w <= 0 || h <= 0 || bytes.size < w * h) {
            subjectSegMaskGpuReady = false
            return
        }
        if (subjectSegTextureId == 0) {
            val ids = IntArray(1)
            GLES20.glGenTextures(1, ids, 0)
            subjectSegTextureId = ids[0]
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, subjectSegTextureId)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        } else {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, subjectSegTextureId)
        }
        GLES20.glPixelStorei(GLES20.GL_UNPACK_ALIGNMENT, 1)
        GLES20.glTexImage2D(
            GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE,
            w, h, 0,
            GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE,
            ByteBuffer.wrap(bytes),
        )
        subjectSegMaskGpuReady = true
    }

    private fun uploadAnalysisSensorArgb(b: Bitmap) {
        if (analysisRgbTexId == 0) {
            val t = IntArray(1)
            GLES20.glGenTextures(1, t, 0)
            analysisRgbTexId = t[0]
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, analysisRgbTexId)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        } else {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, analysisRgbTexId)
        }
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, b, 0)
    }

    /** Consume latest Preview frame into OES (required) and save [SurfaceTexture.getTransformMatrix] for analysis RGB. */
    private fun refreshPreviewTransformMatrixFromOes() {
        if (usesFaceMeshCameraInput) return
        val st = cameraSurfaceTexture ?: return
        val disp = eglDisplay
        val surf = eglSurface
        val ctx = eglContext
        if (disp == EGL14.EGL_NO_DISPLAY || surf == EGL14.EGL_NO_SURFACE || ctx == EGL14.EGL_NO_CONTEXT) return
        EGL14.eglMakeCurrent(disp, surf, surf, ctx)
        try {
            st.updateTexImage()
            st.getTransformMatrix(cachedPreviewStMatrix)
            applyBackCameraOesTextureRotate180To(cachedPreviewStMatrix)
            hasCachedPreviewStMatrix = true
        } catch (_: Exception) {
        }
    }

    /**
     * Fallback when no OES matrix yet: map raw analysis buffer using [ImageInfo.getRotationDegrees] only (approximate).
     * [rotationDeg] = [androidx.camera.core.ImageInfo.getRotationDegrees] (clockwise to upright).
     * Use the same sign as [Matrix.rotateM] (CCW-positive): **-r** made preview upside down vs [getTransformMatrix] expectation.
     */
    private fun setStMatrixForAnalysisBuffer(rotationDeg: Int) {
        Matrix.setIdentityM(stMatrix, 0)
        val r = ((rotationDeg % 360) + 360) % 360
        if (r == 0) return
        Matrix.translateM(stMatrix, 0, 0.5f, 0.5f, 0f)
        Matrix.rotateM(stMatrix, 0, r.toFloat(), 0f, 0f, 1f)
        Matrix.translateM(stMatrix, 0, -0.5f, -0.5f, 0f)
    }

    /**
     * @param analysisSensorArgb same bitmap as [PreparedFaceFrame.sensorArgb]; caller recycles after return.
     *        Ignored when [refreshInput] is false.
     * @param imageInfoRotationDegrees [ImageProxy.imageInfo.rotationDegrees] when [analysisSensorArgb] is non-null.
     * @param refreshInput false = redraw using current GPU textures + [lastComposedUsedAnalysisRgb] (snapshot).
     */
    private fun runOneFrame(
        analysisSensorArgb: Bitmap? = null,
        imageInfoRotationDegrees: Int = 0,
        refreshInput: Boolean = true,
    ) {
        if (usesFaceMeshCameraInput) return
        makeCurrentMainSurface()
        val useAnalysisRgb = when {
            !refreshInput -> lastComposedUsedAnalysisRgb
            analysisSensorArgb != null -> true
            else -> false
        }
        if (refreshInput) {
            if (analysisSensorArgb != null) {
                uploadAnalysisSensorArgb(analysisSensorArgb)
                // Bitmap ≠ OES: same [cachedPreviewStMatrix] mis-aligns 468 pts vs [sensorArgb] pixels.
                setStMatrixForAnalysisBuffer(imageInfoRotationDegrees)
            } else {
                val input = cameraSurfaceTexture ?: return
                input.updateTexImage()
                input.getTransformMatrix(stMatrix)
                applyBackCameraOesTextureRotate180To(stMatrix)
                System.arraycopy(stMatrix, 0, cachedPreviewStMatrix, 0, 16)
                hasCachedPreviewStMatrix = true
            }
            Matrix.multiplyMM(combinedTexMat, 0, userTexMatrix, 0, stMatrix, 0)
        }
        if (!Matrix.invertM(invCombinedTexMat, 0, combinedTexMat, 0)) {
            Matrix.setIdentityM(invCombinedTexMat, 0)
        }
        lastComposedUsedAnalysisRgb = useAnalysisRgb
        // Prefer latest MediaPipe mesh on GL thread so big-eye / mask UVs match raw topology; Kalman is per-axis
        // and blurs structure. Fallback to Kalman when MP has not produced a frame yet or failed.
        val nowNs = System.nanoTime()
        currentLandmarks = mediaPipeTracker?.latestFull() ?: kalmanFilter?.predict(nowNs)
        uploadPortraitSegMaskTexture()
        uploadSubjectMaskTexture()

        GLES20.glViewport(0, 0, surfaceWidth, surfaceHeight)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        drawScene(surfaceWidth, surfaceHeight, useAnalysisRgb)

        deliverSnapshotAndBurst()

        swapMainSurfaceBuffers()

        drawEncoderPassIfAny()
    }

    /**
     * AR mesh / red-dot wireframe should match **MediaPipe** face geometry. [LandmarkKalmanFilter.predict]
     * smooths each coordinate independently and **breaks** rigid local structure (eyes/lips vs preview).
     */
    private fun landmarksForArDraw(nowNs: Long): FaceLandmarks {
        mediaPipeTracker?.latestFull()?.let { return it }
        kalmanFilter?.predict(nowNs)?.let { return it }
        cachedLandmarksForAr?.let { return it }
        return FaceLandmarks.neutralForArEffects()
    }

    /**
     * @param stillCropOverride baseSt 空间裁切矩阵；null 表示单位矩阵（预览 / 全屏仍图）。
     */
    private fun drawScene(
        viewportW: Int,
        viewportH: Int,
        useAnalysisRgb: Boolean,
        cameraPipeRgbTexId: Int = 0,
        stillCropOverride: FloatArray? = null,
    ) {
        val useRgb = useAnalysisRgb || cameraPipeRgbTexId != 0
        val bh = if (useRgb) beautyRgb ?: return else beautyOes ?: return
        // AR 层（眼镜等）常开 GL_BLEND 且未关；若保留到下一帧，美颜全屏四边形会在混合模式下叠成黑屏。
        GLES20.glDisable(GLES20.GL_BLEND)
        // 预览/美颜全屏为 z=0、默认深度比较为 GL_LESS；若 AR（如 glasses_3d）曾打开深度测试，
        // 次帧 0 < 0 失败 → 整屏不画 → 仅清屏黑底 + 仍关闭深度测试的眼镜可见。
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(false)
        val lm = currentLandmarks
        if (lm != null) {
            cachedLandmarksForAr = FaceLandmarks(lm.points.copyOf(), lm.timestampNs, lm.z.copyOf())
        }

        GLES20.glUseProgram(bh.program)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        when {
            cameraPipeRgbTexId != 0 -> GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, cameraPipeRgbTexId)
            useAnalysisRgb -> GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, analysisRgbTexId)
            else -> GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, cameraTextureId)
        }
        if (bh.sampler >= 0) {
            GLES20.glUniform1i(bh.sampler, 0)
        }
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, if (portraitSegTextureId != 0) portraitSegTextureId else 0)
        if (bh.portraitSegMask >= 0) {
            GLES20.glUniform1i(bh.portraitSegMask, 1)
        }
        if (bh.portraitSegReady >= 0) {
            val ready = portraitSegMaskGpuReady && portraitSegTextureId != 0
            GLES20.glUniform1f(bh.portraitSegReady, if (ready) 1f else 0f)
        }
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        vertexBuffer.position(0)
        GLES20.glVertexAttribPointer(bh.position, 2, GLES20.GL_FLOAT, false, 0, vertexBuffer)
        GLES20.glEnableVertexAttribArray(bh.position)
        GLES20.glUniformMatrix4fv(bh.texMatrix, 1, false, stMatrix, 0)
        GLES20.glUniformMatrix4fv(bh.userTexMatrix, 1, false, userTexMatrix, 0)
        val cropMat = stillCropOverride ?: identityStillCrop
        if (bh.stillCrop >= 0) {
            GLES20.glUniformMatrix4fv(bh.stillCrop, 1, false, cropMat, 0)
        }
        GLES20.glUniform1f(bh.brightness, brightness)
        GLES20.glUniform1f(bh.contrast, contrast)
        GLES20.glUniform1f(bh.ruddy, ruddy)
        GLES20.glUniform3fv(bh.colorScale, 1, colorScale, 0)
        GLES20.glUniform3fv(bh.colorOffset, 1, colorOffset, 0)

        // 美颜必须同时满足：(1) 最近一帧检测器认为画面里有人脸（MP 或 ML 回写）；(2) Kalman 在近期被真实测量更新过。
        // 否则仅靠 latestFull 缓存 + predict 外推会把椭圆留在旧位置，美白/磨皮会作用到背景物体上。
        val nowNsBeauty = System.nanoTime()
        val mpReportedFace = mediaPipeTracker?.lastMeshResultHadFace
        val kalmanFresh =
            kalmanFilter?.isMeasurementFresh(nowNsBeauty, 180_000_000L) == true
        val beautyFaceOk = (mpReportedFace != false) && kalmanFresh

        var hasFace = 0f
        var elx = 0.45f
        var ely = 0.45f
        var erx = 0.55f
        var ery = 0.45f
        var fcx = 0.5f
        var fcy = 0.5f
        var fmx = 0.5f
        var fmy = 0.5f
        var fhx = 0.22f
        var fhy = 0.28f
        // 与 portrait_blur 一致：当前帧丢检时用上一帧网格，避免特写/抖动时 lm 为空 → hasFace=0 → 整段美颜被跳过。
        val lmSrc: FaceLandmarks? = when {
            currentArEffect == "portrait_blur" ->
                lm ?: cachedLandmarksForAr ?: FaceLandmarks.neutralForArEffects()
            else -> lm ?: cachedLandmarksForAr
        }
        // 3D 眼镜：与美颜同级的「未明确无脸」(mpReportedFace != false)，但测量时效放宽到 600ms；
        // 不再强制 lastMeshResultHadFace==true（ML 辅助路径、首帧 null 时曾与 beauty 不一致导致永远不画）。
        val glassesArOk =
            currentArEffect == "glasses_3d" &&
                lmSrc != null &&
                kalmanFilter?.hasData == true &&
                (mpReportedFace != false) &&
                kalmanFilter?.isMeasurementFresh(nowNsBeauty, 600_000_000L) == true
        if (lmSrc != null) {
            val left = landmarkToTexUv(lmSrc.x(FaceLandmarks.LEFT_IRIS), lmSrc.y(FaceLandmarks.LEFT_IRIS))
            val right = landmarkToTexUv(lmSrc.x(FaceLandmarks.RIGHT_IRIS), lmSrc.y(FaceLandmarks.RIGHT_IRIS))
            val fc = landmarkToTexUv(lmSrc.x(FaceLandmarks.NOSE_TIP), lmSrc.y(FaceLandmarks.NOSE_TIP))
            elx = left.first
            ely = left.second
            erx = right.first
            ery = right.second
            fcx = fc.first
            fcy = fc.second
            var minU = 1f
            var maxU = 0f
            var minV = 1f
            var maxV = 0f
            for (idx in FaceLandmarks.FACE_OVAL_INDICES) {
                val (u, v) = landmarkToTexUv(lmSrc.x(idx), lmSrc.y(idx))
                minU = kotlin.math.min(minU, u)
                maxU = kotlin.math.max(maxU, u)
                minV = kotlin.math.min(minV, v)
                maxV = kotlin.math.max(maxV, v)
            }
            val padU = (maxU - minU) * 0.06f + 0.02f
            val padV = (maxV - minV) * 0.06f + 0.02f
            minU = (minU - padU).coerceIn(0f, 1f)
            maxU = (maxU + padU).coerceIn(0f, 1f)
            minV = (minV - padV).coerceIn(0f, 1f)
            maxV = (maxV + padV).coerceIn(0f, 1f)
            fmx = (minU + maxU) * 0.5f
            fmy = (minV + maxV) * 0.5f
            val bw = maxU - minU
            val bh = maxV - minV
            // 特写脸占比极大时不收紧半轴，避免椭圆罩不住脸周像素。
            fhx = (bw * 0.5f).coerceIn(0.12f, 0.58f)
            fhy = (bh * 0.5f).coerceIn(0.14f, 0.62f)
            // 仅在实际检出 + 测量新鲜时开 uHasFace；缓存网格仍可参与椭圆供虚化等，但不单独触发美颜。
            if (beautyFaceOk) {
                hasFace = 1f
            }
        }
        var chinU = 0.5f
        var chinV = 0.78f
        var mouthU = 0.5f
        var mouthV = 0.62f
        var foreheadU = 0.5f
        var foreheadV = 0.38f
        var mouthLeftU = 0.42f
        var mouthLeftV = 0.62f
        var mouthRightU = 0.58f
        var mouthRightV = 0.62f
        if (lmSrc != null) {
            val ch = landmarkToTexUv(lmSrc.x(FaceLandmarks.CHIN), lmSrc.y(FaceLandmarks.CHIN))
            chinU = ch.first
            chinV = ch.second
            val ml = landmarkToTexUv(lmSrc.x(FaceLandmarks.LEFT_MOUTH), lmSrc.y(FaceLandmarks.LEFT_MOUTH))
            val mr = landmarkToTexUv(lmSrc.x(FaceLandmarks.RIGHT_MOUTH), lmSrc.y(FaceLandmarks.RIGHT_MOUTH))
            mouthLeftU = ml.first
            mouthLeftV = ml.second
            mouthRightU = mr.first
            mouthRightV = mr.second
            mouthU = (ml.first + mr.first) * 0.5f
            mouthV = (ml.second + mr.second) * 0.5f
            val fh = landmarkToTexUv(lmSrc.x(FaceLandmarks.FOREHEAD), lmSrc.y(FaceLandmarks.FOREHEAD))
            foreheadU = fh.first
            foreheadV = fh.second
        }
        // 无脸网时 **不** 做全屏/大椭圆兜底：否则美白等会作用到背景物体（违背「只美脸」）。丢检时宁可短暂只套滤镜。
        val pb = when (currentArEffect) {
            "portrait_blur" -> 1f
            else -> portraitBlurBeauty
        }
        val targetShieldHx = fhx * 1.16f
        val targetShieldHy = fhy * 1.2f
        if (pb > 0.001f && lmSrc != null) {
            val a = 0.38f
            portraitShieldMx += a * (fmx - portraitShieldMx)
            portraitShieldMy += a * (fmy - portraitShieldMy)
            portraitShieldHx += a * (targetShieldHx - portraitShieldHx)
            portraitShieldHy += a * (targetShieldHy - portraitShieldHy)
        } else {
            portraitShieldMx = fmx
            portraitShieldMy = fmy
            portraitShieldHx = targetShieldHx
            portraitShieldHy = targetShieldHy
        }
        GLES20.glUniform1f(bh.bigEye, bigEye)
        if (bh.eyeBrighten >= 0) {
            GLES20.glUniform1f(bh.eyeBrighten, eyeBrighten)
        }
        GLES20.glUniform1f(bh.slimFace, slimFace)
        GLES20.glUniform1f(bh.portraitBlur, pb)
        if (bh.portraitBlurAr >= 0) {
            GLES20.glUniform1f(bh.portraitBlurAr, if (currentArEffect == "portrait_blur") 1f else 0f)
        }
        GLES20.glUniform2f(bh.eyeLeftUv, elx, ely)
        GLES20.glUniform2f(bh.eyeRightUv, erx, ery)
        GLES20.glUniform2f(bh.faceCenterUv, fcx, fcy)
        GLES20.glUniform1f(bh.hasFace, hasFace)

        GLES20.glUniform2f(bh.faceMaskCenter, fmx, fmy)
        GLES20.glUniform2f(bh.faceMaskHalf, fhx, fhy)
        if (bh.portraitShieldCenter >= 0) {
            GLES20.glUniform2f(bh.portraitShieldCenter, portraitShieldMx, portraitShieldMy)
        }
        if (bh.portraitShieldHalf >= 0) {
            GLES20.glUniform2f(bh.portraitShieldHalf, portraitShieldHx, portraitShieldHy)
        }
        GLES20.glUniform1f(bh.smoothing, smoothing)
        if (bh.chinUv >= 0) GLES20.glUniform2f(bh.chinUv, chinU, chinV)
        if (bh.mouthUv >= 0) GLES20.glUniform2f(bh.mouthUv, mouthU, mouthV)
        if (bh.foreheadUv >= 0) GLES20.glUniform2f(bh.foreheadUv, foreheadU, foreheadV)
        if (bh.mouthLeftUv >= 0) GLES20.glUniform2f(bh.mouthLeftUv, mouthLeftU, mouthLeftV)
        if (bh.mouthRightUv >= 0) GLES20.glUniform2f(bh.mouthRightUv, mouthRightU, mouthRightV)
        if (bh.faceNarrow >= 0) GLES20.glUniform1f(bh.faceNarrow, faceNarrow)
        if (bh.faceChin >= 0) GLES20.glUniform1f(bh.faceChin, faceChin)
        if (bh.faceV >= 0) GLES20.glUniform1f(bh.faceV, faceV)
        if (bh.faceNose >= 0) GLES20.glUniform1f(bh.faceNose, faceNose)
        if (bh.faceForehead >= 0) GLES20.glUniform1f(bh.faceForehead, faceForeheadAmt)
        if (bh.faceMouth >= 0) GLES20.glUniform1f(bh.faceMouth, faceMouth)
        if (bh.facePhiltrum >= 0) GLES20.glUniform1f(bh.facePhiltrum, facePhiltrum)
        if (bh.faceLongNose >= 0) GLES20.glUniform1f(bh.faceLongNose, faceLongNose)
        if (bh.faceEyeSpace >= 0) GLES20.glUniform1f(bh.faceEyeSpace, faceEyeSpace)
        if (bh.faceSmile >= 0) GLES20.glUniform1f(bh.faceSmile, faceSmile)
        if (bh.faceCanthus >= 0) GLES20.glUniform1f(bh.faceCanthus, faceCanthus)

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        val nowNs = System.nanoTime()
        // AR 线框/粒子/网格变形：仅在「当前帧确有检出 + 测量仍新鲜」时绘制（与上方 [beautyFaceOk] / uHasFace 一致）。
        // 若仍用 [landmarksForArDraw] 在丢检后绘制，Kalman 外推 + [cachedLandmarksForAr] 会把线框留在旧位置。
        // [glassesArOk]：仅放宽 glasses_3d，不放宽线框类特效。
        if (beautyFaceOk || glassesArOk) {
            val arLm = landmarksForArDraw(nowNs)
            if (currentArEffect != "portrait_blur") {
                if (FaceMeshArPass.MESH_DEFORM_AR_EFFECTS.contains(currentArEffect)) {
                    val camId = when {
                        cameraPipeRgbTexId != 0 -> cameraPipeRgbTexId
                        useAnalysisRgb -> analysisRgbTexId
                        else -> cameraTextureId
                    }
                    faceMeshArPass.draw(
                        currentArEffect,
                        arLm,
                        camId,
                        ::landmarkToGl,
                        ::landmarkToTexUv,
                        subjectMaskTextureId = subjectSegTextureId,
                        subjectMaskReady = subjectSegMaskGpuReady && currentArEffect == "green_hair",
                        cameraIsExternalOes = !useRgb,
                    )
                }
                if (currentArEffect == "face_mesh_uv") {
                    faceMeshWireframeOverlay.draw(arLm, ::landmarkToGl, viewportW, viewportH)
                }
                activeEffect?.draw(arLm, ::landmarkToGl, viewportW, viewportH)
            }
        }
    }

    private fun readPixelsToJpeg(w: Int, h: Int): ByteArray? {
        if (w <= 0 || h <= 0) return null
        val buf = ByteBuffer.allocateDirect(w * h * 4).order(ByteOrder.nativeOrder())
        GLES20.glReadPixels(0, 0, w, h, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, buf)
        val pixels = IntArray(w * h)
        buf.rewind()
        for (y in 0 until h) {
            for (x in 0 until w) {
                val r = buf.get().toInt() and 0xFF
                val g = buf.get().toInt() and 0xFF
                val b = buf.get().toInt() and 0xFF
                val a = buf.get().toInt() and 0xFF
                pixels[(h - 1 - y) * w + x] = (a shl 24) or (r shl 16) or (g shl 8) or b
            }
        }
        val bmp = Bitmap.createBitmap(pixels, w, h, Bitmap.Config.ARGB_8888)
        val out = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, 92, out)
        bmp.recycle()
        return out.toByteArray()
    }

    private fun switchEffectInternal(name: String) {
        // Glasses / AR effects call glGenBuffers & glCreateProgram in init — must have EGL current
        // (CameraInput 路径用 EglManager，eglSurface 可能为 NO_SURFACE，必须用 [makeCurrentMainSurface]）。
        makeCurrentMainSurface()
        activeEffect?.release()
        activeEffect = null
        if (name != "none" && name != "portrait_blur") {
            if (name !in FaceMeshArPass.MESH_DEFORM_AR_EFFECTS) {
                if (name == "glasses_3d") {
                    val ctx = androidContext?.applicationContext
                    if (ctx != null) {
                        val g = Glasses3dEffect(ctx)
                        g.init()
                        activeEffect = g
                    } else {
                        Log.e(
                            "GlPreviewRenderer",
                            "glasses_3d: androidContext is null — pass Context into GlPreviewRenderer constructor",
                        )
                    }
                } else {
                    val effect = ArEffectRenderer.create(name)
                    effect?.init()
                    activeEffect = effect
                }
            }
        }
    }

    private fun releaseInternal() {
        makeCurrentMainSurface()
        videoRecorder = null
        khrEncoderSurface?.let { enc -> runCatching { faceMeshEglManager?.releaseSurface(enc) } }
        khrEncoderSurface = null
        encoderEglSurface?.let { s ->
            if (eglDisplay != EGL14.EGL_NO_DISPLAY) EGL14.eglDestroySurface(eglDisplay, s)
        }
        encoderEglSurface = null
        eglConfig = null
        activeEffect?.release()
        activeEffect = null
        faceMeshArPass.release()
        faceMeshWireframeOverlay.release()
        pendingSnapshot = null
        jpegBurstRemaining = 0
        jpegBurstList = null
        jpegBurstCallback = null
        encoderAccumulatedPresentationNs = 0L
        runCatching { cameraSurface?.release() }
        cameraSurface = null
        runCatching { cameraSurfaceTexture?.release() }
        cameraSurfaceTexture = null
        val fmEm = faceMeshEglManager
        val kWin = khrWindowSurface
        if (fmEm != null && kWin != null) {
            runCatching { fmEm.makeCurrent(kWin, kWin) }
        } else if (eglDisplay != EGL14.EGL_NO_DISPLAY && eglSurface != EGL14.EGL_NO_SURFACE &&
            eglContext != EGL14.EGL_NO_CONTEXT
        ) {
            EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)
        }
        if (cameraTextureId != 0) GLES20.glDeleteTextures(1, intArrayOf(cameraTextureId), 0)
        cameraTextureId = 0
        if (portraitSegTextureId != 0) GLES20.glDeleteTextures(1, intArrayOf(portraitSegTextureId), 0)
        portraitSegTextureId = 0
        portraitSegMaskGpuReady = false
        if (subjectSegTextureId != 0) GLES20.glDeleteTextures(1, intArrayOf(subjectSegTextureId), 0)
        subjectSegTextureId = 0
        subjectSegMaskGpuReady = false
        currentLandmarks = null
        cachedLandmarksForAr = null
        mediaPipeTracker = null
        synchronized(analysisDisplayLock) {
            coalescedAnalysis?.bitmap?.recycle()
            coalescedAnalysis = null
        }
        synchronized(faceMeshFrameLock) {
            coalescedFaceMeshFrame?.release()
            coalescedFaceMeshFrame = null
        }
        displayedFaceMeshFrame?.release()
        displayedFaceMeshFrame = null
        beautyOes?.program?.let { GLES20.glDeleteProgram(it) }
        beautyOes = null
        beautyRgb?.program?.let { GLES20.glDeleteProgram(it) }
        beautyRgb = null
        if (analysisRgbTexId != 0) GLES20.glDeleteTextures(1, intArrayOf(analysisRgbTexId), 0)
        analysisRgbTexId = 0
        lastComposedUsedAnalysisRgb = false
        hasCachedPreviewStMatrix = false
        lastFaceMeshPipeTexId = 0
        khrWindowSurface?.let { wsr -> runCatching { fmEm?.releaseSurface(wsr) } }
        khrWindowSurface = null
        faceMeshEglManager = null
        usesFaceMeshCameraInput = false
        if (fmEm == null && eglDisplay != EGL14.EGL_NO_DISPLAY) {
            EGL14.eglMakeCurrent(eglDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
            if (eglSurface != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(eglDisplay, eglSurface)
            if (eglContext != EGL14.EGL_NO_CONTEXT) EGL14.eglDestroyContext(eglDisplay, eglContext)
            EGL14.eglTerminate(eglDisplay)
        }
        eglDisplay = EGL14.EGL_NO_DISPLAY
        eglContext = EGL14.EGL_NO_CONTEXT
        eglSurface = EGL14.EGL_NO_SURFACE
        runCatching { outputSurface?.release() }
        outputSurface = null
    }

    private fun buildProgram(vs: String, fs: String): Int {
        val v = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER).also {
            GLES20.glShaderSource(it, vs)
            GLES20.glCompileShader(it)
        }
        val f = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER).also {
            GLES20.glShaderSource(it, fs)
            GLES20.glCompileShader(it)
        }
        return GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, v)
            GLES20.glAttachShader(it, f)
            GLES20.glLinkProgram(it)
            GLES20.glDeleteShader(v)
            GLES20.glDeleteShader(f)
        }
    }

    private fun createExternalTexture(): Int {
        val t = IntArray(1)
        GLES20.glGenTextures(1, t, 0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, t[0])
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        return t[0]
    }

    companion object {
        private val VERTICES = floatArrayOf(-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f)

        private fun allocBuf(a: FloatArray): FloatBuffer =
            ByteBuffer.allocateDirect(a.size * 4).order(ByteOrder.nativeOrder())
                .asFloatBuffer().apply { put(a); position(0) }

        private const val VERTEX_SHADER = """
            precision highp float;
            attribute vec4 aPosition;
            uniform mat4 uTexMatrix;
            uniform mat4 uUserTexMatrix;
            uniform mat4 uStillCrop;
            varying vec2 vTexCoord;
            void main() {
                gl_Position = aPosition;
                vec2 baseSt = (aPosition.xy + 1.0) * 0.5;
                vec4 tc = uUserTexMatrix * uTexMatrix * uStillCrop * vec4(baseSt, 0.0, 1.0);
                float tw = tc.w;
                vTexCoord = (abs(tw) > 1.0e-6) ? (tc.xy / tw) : tc.xy;
            }
        """

        private const val FRAGMENT_SHADER = """
            #extension GL_OES_EGL_image_external : require
            precision highp float;
            varying vec2 vTexCoord;
            uniform samplerExternalOES sTexture;
            uniform float uBrightness;
            uniform float uContrast;
            uniform float uRuddy;
            uniform vec3 uColorScale;
            uniform vec3 uColorOffset;
            uniform float uBigEye;
            uniform float uEyeBrighten;
            uniform float uSlimFace;
            uniform float uPortraitBlur;
            uniform float uPortraitBlurAr;
            uniform vec2 uEyeLeftUv;
            uniform vec2 uEyeRightUv;
            uniform vec2 uFaceCenterUv;
            uniform float uHasFace;
            uniform vec2 uFaceMaskCenter;
            uniform vec2 uFaceMaskHalf;
            uniform vec2 uPortraitShieldCenter;
            uniform vec2 uPortraitShieldHalf;
            uniform float uSmoothing;
            uniform sampler2D uPortraitSegMask;
            uniform float uPortraitSegReady;
            uniform vec2 uChinUv;
            uniform vec2 uMouthUv;
            uniform vec2 uForeheadUv;
            uniform vec2 uMouthLeftUv;
            uniform vec2 uMouthRightUv;
            uniform float uFaceNarrow;
            uniform float uFaceChin;
            uniform float uFaceV;
            uniform float uFaceNose;
            uniform float uFaceForehead;
            uniform float uFaceMouth;
            uniform float uFacePhiltrum;
            uniform float uFaceLongNose;
            uniform float uFaceEyeSpace;
            uniform float uFaceSmile;
            uniform float uFaceCanthus;
            float faceSkinMask(vec2 uv) {
                vec2 h = max(uFaceMaskHalf, vec2(0.02));
                vec2 d = (uv - uFaceMaskCenter) / h;
                float e = dot(d, d);
                return 1.0 - smoothstep(0.28, 2.15, e);
            }
            /** Outside expanded face ellipse (from Java: oval AABB + margin, EMA-smoothed). Not semantic segmentation. */
            float portraitBackgroundBlurWeight(vec2 uv) {
                vec2 h = max(uPortraitShieldHalf, vec2(0.04));
                vec2 d = (uv - uPortraitShieldCenter) / h;
                float e = dot(d, d);
                return smoothstep(1.18, 1.55, e);
            }
            void main() {
                if (uHasFace < 0.5 && uPortraitBlur < 0.001) {
                    vec4 raw = texture2D(sTexture, vTexCoord);
                    vec3 c = raw.rgb * uColorScale + uColorOffset;
                    gl_FragColor = vec4(clamp(c, 0.0, 1.0), raw.a);
                } else {
                vec2 uv = vTexCoord;
                if (uBigEye > 0.001) {
                    float r = 0.11;
                    vec2 dL = uv - uEyeLeftUv;
                    float dl = length(dL);
                    if (dl < r) {
                        float t = (1.0 - dl / r) * uBigEye;
                        uv = uEyeLeftUv + dL * (1.0 - 0.24 * t);
                    }
                    vec2 dR = uv - uEyeRightUv;
                    float dr = length(dR);
                    if (dr < r) {
                        float t = (1.0 - dr / r) * uBigEye;
                        uv = uEyeRightUv + dR * (1.0 - 0.24 * t);
                    }
                }
                // 瘦脸：片元阶段是「显示坐标 → 纹理采样」的反向映射。横向压缩应用
                //   x_disp = c + (x_tex - c) * s （s<1）
                // 故采样应为 x_tex = c + (x_disp - c) / s；误用 * s 会视觉上变宽。
                if (uSlimFace > 0.001) {
                    float dy = abs(uv.y - uFaceCenterUv.y);
                    if (dy < 0.24) {
                        float dx = uv.x - uFaceCenterUv.x;
                        float s = 1.0 - uSlimFace * 0.2 * (1.0 - dy / 0.24);
                        s = max(s, 0.55);
                        uv.x = uFaceCenterUv.x + dx / s;
                    }
                }
                // 瘦脸以下各项：基于关键点的近似 UV 反向映射（与瘦脸同为采样域形变）。
                if (uFaceNarrow > 0.001) {
                    float midY = 0.5 * (uEyeLeftUv.y + uFaceCenterUv.y);
                    float dy = abs(uv.y - midY);
                    if (dy < 0.1) {
                        float dx = uv.x - uFaceCenterUv.x;
                        float w = (1.0 - dy / 0.1) * uFaceNarrow;
                        float s = 1.0 - 0.12 * w;
                        s = max(s, 0.62);
                        uv.x = uFaceCenterUv.x + dx / s;
                    }
                }
                if (uFaceV > 0.001) {
                    if (uv.y > uFaceCenterUv.y && uv.y < uChinUv.y + 0.06) {
                        float band = max(0.05, uChinUv.y - uFaceCenterUv.y);
                        float t = smoothstep(0.0, band, uv.y - uFaceCenterUv.y);
                        float dx = uv.x - uFaceCenterUv.x;
                        float s = 1.0 - uFaceV * 0.14 * t;
                        s = max(s, 0.62);
                        uv.x = uFaceCenterUv.x + dx / s;
                    }
                }
                if (uFaceChin > 0.001) {
                    float dc = length(uv - uChinUv);
                    if (dc < 0.14) {
                        float w = (1.0 - dc / 0.14) * uFaceChin;
                        uv.y -= w * 0.035;
                    }
                }
                // 鼻梁高度：双眼下缘—鼻尖之间、面中线窄带内竖直微调采样（非缩鼻翼）。
                if (uFaceNose > 0.001) {
                    float dxb = abs(uv.x - uFaceCenterUv.x);
                    float yTop = min(uEyeLeftUv.y, uEyeRightUv.y) + 0.015;
                    float yBot = uFaceCenterUv.y;
                    if (dxb < 0.052 && uv.y >= yTop && uv.y <= yBot) {
                        float ym = (yTop + yBot) * 0.5;
                        float halfH = max((yBot - yTop) * 0.5, 0.028);
                        float dy = abs(uv.y - ym);
                        float w = 1.0 - smoothstep(0.0, halfH, dy);
                        w = w * w;
                        uv.y -= w * uFaceNose * 0.048;
                    }
                }
                if (uFaceForehead > 0.001) {
                    float df = length(uv - uForeheadUv);
                    if (df < 0.16) {
                        float w = (1.0 - df / 0.16) * uFaceForehead;
                        uv.y -= w * 0.028;
                    }
                }
                if (uFaceMouth > 0.001) {
                    float dmy = abs(uv.y - uMouthUv.y);
                    if (dmy < 0.06) {
                        float dx = uv.x - uMouthUv.x;
                        float s = 1.0 - 0.1 * uFaceMouth * (1.0 - dmy / 0.06);
                        s = max(s, 0.72);
                        uv.x = uMouthUv.x + dx / s;
                    }
                }
                if (uFacePhiltrum > 0.001) {
                    float dxp = abs(uv.x - uFaceCenterUv.x);
                    if (dxp < 0.04 && uv.y < uMouthUv.y && uv.y > uFaceCenterUv.y) {
                        float s = 1.0 - uFacePhiltrum * 0.2;
                        s = max(s, 0.7);
                        uv.x = uFaceCenterUv.x + (uv.x - uFaceCenterUv.x) / s;
                    }
                }
                if (uFaceLongNose > 0.001) {
                    float dxn = abs(uv.x - uFaceCenterUv.x);
                    if (dxn < 0.05 && uv.y > uEyeLeftUv.y && uv.y < uMouthUv.y) {
                        float m = 1.0 + uFaceLongNose * 0.12;
                        uv.y = uFaceCenterUv.y + (uv.y - uFaceCenterUv.y) / m;
                    }
                }
                if (uFaceEyeSpace > 0.001) {
                    float re = 0.1;
                    vec2 dLe = uv - uEyeLeftUv;
                    if (length(dLe) < re) {
                        float te = (1.0 - length(dLe) / re) * uFaceEyeSpace;
                        uv.x -= te * 0.022;
                    }
                    vec2 dRi = uv - uEyeRightUv;
                    if (length(dRi) < re) {
                        float te2 = (1.0 - length(dRi) / re) * uFaceEyeSpace;
                        uv.x += te2 * 0.022;
                    }
                }
                if (uFaceSmile > 0.001) {
                    float dl = length(uv - uMouthLeftUv);
                    if (dl < 0.08) uv.y -= uFaceSmile * 0.02 * (1.0 - dl / 0.08);
                    float drs = length(uv - uMouthRightUv);
                    if (drs < 0.08) uv.y -= uFaceSmile * 0.02 * (1.0 - drs / 0.08);
                }
                if (uFaceCanthus > 0.001) {
                    float rc = 0.09;
                    vec2 dLc = uv - uEyeLeftUv;
                    if (length(dLc) < rc && dLc.x < 0.0) uv.x -= uFaceCanthus * 0.015 * (1.0 - length(dLc) / rc);
                    vec2 dRc = uv - uEyeRightUv;
                    if (length(dRc) < rc && dRc.x > 0.0) uv.x += uFaceCanthus * 0.015 * (1.0 - length(dRc) / rc);
                }
                uv = clamp(uv, 0.001, 0.999);
                vec4 base = texture2D(sTexture, uv);
                float skinM = faceSkinMask(vTexCoord);
                float lumFace = dot(base.rgb, vec3(0.299, 0.587, 0.114));
                float skinW = smoothstep(0.03, 0.55, lumFace) * (1.0 - smoothstep(0.94, 0.998, lumFace));
                // 仅在椭圆脸区内略抬 skinW，避免背景被全局「保底」；特写过曝时仍主要靠脸区 mask。
                skinW = max(skinW, skinM * 0.38);
                float m = skinM * mix(0.68, 1.0, skinW);
                if (uPortraitSegReady > 0.5) {
                    float fg = texture2D(uPortraitSegMask, vTexCoord).r;
                    m *= mix(0.78, 1.0, smoothstep(0.1, 0.9, fg));
                }
                vec3 rgb = base.rgb;
                if (uSmoothing > 0.001 && m > 0.01) {
                    float rad = 0.008 + uSmoothing * 0.022;
                    vec2 o = vec2(rad, rad);
                    vec2 d = vec2(rad * 0.75, rad * 0.75);
                    vec3 blur = (
                        texture2D(sTexture, clamp(uv + vec2(o.x, 0.0), 0.001, 0.999)).rgb +
                        texture2D(sTexture, clamp(uv - vec2(o.x, 0.0), 0.001, 0.999)).rgb +
                        texture2D(sTexture, clamp(uv + vec2(0.0, o.y), 0.001, 0.999)).rgb +
                        texture2D(sTexture, clamp(uv - vec2(0.0, o.y), 0.001, 0.999)).rgb +
                        texture2D(sTexture, clamp(uv + vec2(d.x, d.y), 0.001, 0.999)).rgb +
                        texture2D(sTexture, clamp(uv - vec2(d.x, d.y), 0.001, 0.999)).rgb +
                        texture2D(sTexture, clamp(uv + vec2(d.x, -d.y), 0.001, 0.999)).rgb +
                        texture2D(sTexture, clamp(uv + vec2(-d.x, d.y), 0.001, 0.999)).rgb +
                        base.rgb
                    ) * 0.1111111;
                    float smMix = min(1.0, uSmoothing * 1.35) * m;
                    rgb = mix(rgb, blur, smMix);
                }
                vec3 beauty = rgb;
                float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
                float midW = mix(1.35, 0.75, smoothstep(0.38, 0.88, lum));
                beauty += vec3(uBrightness * midW);
                beauty.r += uRuddy * 0.11;
                beauty.g -= uRuddy * 0.042;
                beauty.b -= uRuddy * 0.055;
                beauty = (beauty - 0.5) * uContrast + 0.5;
                vec3 afterBeauty = mix(rgb, beauty, m);
                vec3 color = afterBeauty * uColorScale + uColorOffset;
                if (uEyeBrighten > 0.001) {
                    float wl = 1.0 - smoothstep(0.028, 0.11, length(vTexCoord - uEyeLeftUv));
                    float wr = 1.0 - smoothstep(0.028, 0.11, length(vTexCoord - uEyeRightUv));
                    float ew = max(wl, wr);
                    color += vec3(uEyeBrighten * 0.42 * ew);
                }
                vec4 outC = vec4(color, base.a);
                if (uPortraitBlur > 0.001) {
                    float br = mix(0.012, 0.048, uPortraitBlurAr);
                    float br2 = br * 1.82;
                    float k = 0.72;
                    float bgW = portraitBackgroundBlurWeight(vTexCoord);
                    if (uPortraitSegReady > 0.5) {
                        float fg = texture2D(uPortraitSegMask, vTexCoord).r;
                        bgW = 1.0 - smoothstep(0.18, 0.82, fg);
                    }
                    vec4 b = (
                        texture2D(sTexture, clamp(uv + vec2(br, 0.0), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv - vec2(br, 0.0), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(0.0, br), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv - vec2(0.0, br), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(br * k, br * k), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv - vec2(br * k, br * k), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(br * k, -br * k), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(-br * k, br * k), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(br2, 0.0), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv - vec2(br2, 0.0), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(0.0, br2), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv - vec2(0.0, br2), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(br2 * k, br2 * k), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv - vec2(br2 * k, br2 * k), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(br2 * k, -br2 * k), 0.001, 0.999)) +
                        texture2D(sTexture, clamp(uv + vec2(-br2 * k, br2 * k), 0.001, 0.999)) +
                        outC
                    ) * 0.05882353;
                    float mixAmt = min(1.0, bgW * uPortraitBlur * mix(1.0, 1.28, uPortraitBlurAr));
                    outC = mix(outC, b, mixAmt);
                }
                gl_FragColor = vec4(clamp(outC.rgb, 0.0, 1.0), outC.a);
                }
            }
        """

        /** Same body as [FRAGMENT_SHADER] but [sampler2D] for analysis-frame [GL_TEXTURE_2D]. */
        private val FRAGMENT_SHADER_RGB: String = FRAGMENT_SHADER
            .replace(Regex("^\\s*#extension GL_OES_EGL_image_external : require\\s*", RegexOption.MULTILINE), "")
            .replace("uniform samplerExternalOES sTexture;", "uniform sampler2D sTexture;")
    }
}
