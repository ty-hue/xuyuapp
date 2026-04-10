package com.example.pixelfree_camera

import android.content.Context
import android.graphics.Bitmap
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.os.SystemClock
import androidx.camera.core.ImageProxy
import com.google.mediapipe.formats.proto.LandmarkProto.NormalizedLandmark
import com.google.mediapipe.framework.TextureFrame
import com.google.mediapipe.solutions.facemesh.FaceMesh
import com.google.mediapipe.solutions.facemesh.FaceMeshOptions
import com.google.mediapipe.solutions.facemesh.FaceMeshResult

/**
 * MediaPipe **Solutions** [FaceMesh] (official `facemesh` demo).
 *
 * **Preferred live path:** [com.google.mediapipe.solutioncore.CameraInput] + [FaceMesh.send] [com.google.mediapipe.framework.TextureFrame]
 * with [FaceMesh.getGlContext] shared into [GlPreviewRenderer] via [com.google.mediapipe.glutil.EglManager] —
 * landmark normalized space matches the displayed camera texture (official behaviour).
 *
 * **Fallback:** [detectFromPrepared] uses Bitmap + [InverseGeom] when CameraInput is unavailable (no [android.app.Activity]).
 */
internal class MediaPipeFaceTracker private constructor(
    val faceMesh: FaceMesh,
    val kalman: LandmarkKalmanFilter,
) {

    var onFaceOverlayUpdate: ((FaceOverlay) -> Unit)? = null

    /** When true, [FaceMeshResult] updates landmarks in texture-normalized space and triggers [onFaceMeshGlFrame]. */
    @Volatile
    var textureInputMode: Boolean = false

    /**
     * GPU preview: input [TextureFrame] from [FaceMeshResult.acquireInputTextureFrame] (must be taken **inside**
     * the result listener — [com.google.mediapipe.solutioncore.OutputHandler] clears packets after the callback).
     * Consumer [GlPreviewRenderer] calls [TextureFrame.release] after drawing.
     */
    var onFaceMeshGlFrame: ((TextureFrame) -> Unit)? = null

    @Volatile
    private var latestLandmarks: FaceLandmarks? = null

    @Volatile
    private var latestOverlay: FaceOverlay? = null

    /**
     * Result of the **last** FaceMesh pipeline callback: at least one face in the image.
     * `null` before first result. Used to disable beauty when the stream shows no face (stale
     * [latestLandmarks] can linger for several frames; Kalman [predict] can still extrapolate).
     */
    @Volatile
    var lastMeshResultHadFace: Boolean? = null
        private set

    @Volatile
    private var lastPipelineResult: FaceMeshResult? = null

    private var consecutiveEmptyResults = 0

    /** Monotonic timestamp for [FaceMesh.send]; MediaPipe expects strictly increasing values (microseconds). */
    private var lastSendTimestampUs = 0L

    private data class InverseGeom(
        val bufferW: Int,
        val bufferH: Int,
        val detW: Int,
        val detH: Int,
        val landmarkInferScale: Float,
        val uprightCanvasLeft: Float,
        val uprightCanvasTop: Float,
        val uprightToBufferInv: Matrix,
    )

    fun latest(): FaceOverlay? = latestOverlay
    fun latestFull(): FaceLandmarks? = latestLandmarks

    fun predictNow(): FaceLandmarks? = kalman.predict(System.nanoTime())

    /** ML Kit (or other) supplied a face mesh this frame while MediaPipe had no face — allow beauty to track it. */
    fun markAuxiliaryFaceMeasurement() {
        lastMeshResultHadFace = true
    }

    private fun nextMonotonicTimestampUs(): Long {
        var t = SystemClock.elapsedRealtimeNanos() / 1000L
        if (t <= lastSendTimestampUs) t = lastSendTimestampUs + 1L
        lastSendTimestampUs = t
        return t
    }

    init {
        faceMesh.setResultListener { result ->
            lastPipelineResult = result
            if (textureInputMode) {
                applyTextureSpaceLandmarks(result)
                val tf = try {
                    result.acquireInputTextureFrame()
                } catch (_: Throwable) {
                    null
                }
                if (tf != null) {
                    val cb = onFaceMeshGlFrame
                    if (cb != null) cb.invoke(tf) else tf.release()
                }
            }
        }
        faceMesh.setErrorListener { _, e ->
            if (e != null) {
                registerMissNoFace()
            }
        }
    }

    /**
     * Official Face Mesh on [prepared.rotated] (caller [PreparedFaceFrame.recycle]s).
     * @return true if a face was found (Kalman updated).
     */
    fun detectFromPrepared(prepared: PreparedFaceFrame): Boolean {
        val geom = InverseGeom(
            prepared.bufferW,
            prepared.bufferH,
            prepared.rotated.width.coerceAtLeast(1),
            prepared.rotated.height.coerceAtLeast(1),
            prepared.landmarkInferScale.coerceIn(0.05f, 1f),
            prepared.uprightCanvasLeft,
            prepared.uprightCanvasTop,
            prepared.uprightToBufferInv,
        )
        val tsUs = nextMonotonicTimestampUs()
        lastPipelineResult = null
        return try {
            faceMesh.send(prepared.rotated, tsUs)
            faceMesh.waitUntilIdle()
            val result = lastPipelineResult
            if (result != null) {
                applyLandmarksFromResult(result, geom)
            } else {
                registerMissNoFace()
                false
            }
        } catch (_: Exception) {
            registerMissNoFace()
            false
        }
    }

    fun detectFromImageProxy(imageProxy: ImageProxy, isFrontCamera: Boolean): Boolean {
        val p = PreparedFaceFrame.fromImageProxy(imageProxy, isFrontCamera) ?: return false
        try {
            return detectFromPrepared(p)
        } finally {
            p.recycle()
        }
    }

    private fun registerMissNoFace() {
        lastMeshResultHadFace = false
        consecutiveEmptyResults++
        if (consecutiveEmptyResults >= EMPTY_FRAMES_BEFORE_RESET) {
            kalman.reset()
            consecutiveEmptyResults = 0
            latestLandmarks = null
            latestOverlay = null
        }
    }

    /**
     * Landmarks are already normalized to the **same** image as [FaceMeshResult.getCachedInputTextureFrame]
     * (official CameraInput / TextureFrame path).
     */
    private fun applyTextureSpaceLandmarks(result: FaceMeshResult): Boolean {
        val faces = result.multiFaceLandmarks()
        if (faces.isEmpty()) {
            registerMissNoFace()
            return false
        }
        consecutiveEmptyResults = 0
        lastMeshResultHadFace = true
        val lmList = faces[0].landmarkList
        val pts = FloatArray(FaceLandmarks.ARRAY_SIZE)
        val zArr = FloatArray(FaceLandmarks.COUNT)
        val n = kotlin.math.min(lmList.size, FaceLandmarks.COUNT)
        for (i in 0 until n) {
            val lm: NormalizedLandmark = lmList[i]
            pts[i * 2] = (lm.getX() + LandmarkSpaceTuning.BUFFER_NORM_BIAS_X).coerceIn(0f, 1f)
            pts[i * 2 + 1] = (lm.getY() + LandmarkSpaceTuning.BUFFER_NORM_BIAS_Y).coerceIn(0f, 1f)
            zArr[i] = lm.getZ()
        }
        FaceLandmarks.patchIrisLandmarksIfAbsent(pts)
        val landmarks = FaceLandmarks(pts, System.nanoTime(), zArr)
        kalman.update(landmarks)
        latestLandmarks = landmarks
        val overlay = landmarks.toLegacyOverlay()
        latestOverlay = overlay
        onFaceOverlayUpdate?.invoke(overlay)
        return true
    }

    private fun applyLandmarksFromResult(result: FaceMeshResult, invG: InverseGeom): Boolean {
        val faces = result.multiFaceLandmarks()
        if (faces.isEmpty()) {
            registerMissNoFace()
            return false
        }
        consecutiveEmptyResults = 0
        lastMeshResultHadFace = true
        val lmList = faces[0].landmarkList
        val pts = FloatArray(FaceLandmarks.ARRAY_SIZE)
        val zArr = FloatArray(FaceLandmarks.COUNT)
        val invScale = 1f / invG.landmarkInferScale.coerceAtLeast(1e-4f)
        val n = kotlin.math.min(lmList.size, FaceLandmarks.COUNT)
        for (i in 0 until n) {
            val lm: NormalizedLandmark = lmList[i]
            val nx = lm.getX()
            val ny = lm.getY()
            val px = floatArrayOf(
                nx * invG.detW * invScale + invG.uprightCanvasLeft,
                ny * invG.detH * invScale + invG.uprightCanvasTop,
            )
            invG.uprightToBufferInv.mapPoints(px)
            pts[i * 2] = (px[0] / invG.bufferW + LandmarkSpaceTuning.BUFFER_NORM_BIAS_X).coerceIn(0f, 1f)
            pts[i * 2 + 1] = (px[1] / invG.bufferH + LandmarkSpaceTuning.BUFFER_NORM_BIAS_Y).coerceIn(0f, 1f)
            zArr[i] = lm.getZ()
        }
        FaceLandmarks.patchIrisLandmarksIfAbsent(pts)
        val landmarks = FaceLandmarks(pts, System.nanoTime(), zArr)
        kalman.update(landmarks)
        latestLandmarks = landmarks
        val overlay = landmarks.toLegacyOverlay()
        latestOverlay = overlay
        onFaceOverlayUpdate?.invoke(overlay)
        return true
    }

    fun release() {
        onFaceOverlayUpdate = null
        onFaceMeshGlFrame = null
        textureInputMode = false
        runCatching { faceMesh.close() }
    }

    companion object {
        private const val EMPTY_FRAMES_BEFORE_RESET = 18

        /**
         * Same options as official [com.google.mediapipe.examples.facemesh.MainActivity] streaming pipeline
         * (`setStaticImageMode(false)`, `setRefineLandmarks(true)`, `setRunOnGpu(true)`).
         */
        fun create(context: Context, kalman: LandmarkKalmanFilter): MediaPipeFaceTracker? {
            return try {
                val opts = FaceMeshOptions.builder()
                    .setStaticImageMode(false)
                    .setMaxNumFaces(1)
                    .setRefineLandmarks(true)
                    .setRunOnGpu(true)
                    .setMinDetectionConfidence(0.5f)
                    .setMinTrackingConfidence(0.5f)
                    .build()
                val mesh = FaceMesh(context, opts)
                MediaPipeFaceTracker(mesh, kalman)
            } catch (_: Exception) {
                null
            }
        }

        fun createSync(context: Context): MediaPipeFaceTracker? =
            create(context, LandmarkKalmanFilter())

        /** YUV_420_888 → ARGB; also used by [PreparedFaceFrame] YUV fallback. */
        internal fun imageToBitmap(image: android.media.Image): Bitmap? = try {
            val w = image.width
            val h = image.height
            val yPlane = image.planes[0]
            val uPlane = image.planes[1]
            val vPlane = image.planes[2]
            val yBuf = yPlane.buffer.duplicate()
            val uBuf = uPlane.buffer.duplicate()
            val vBuf = vPlane.buffer.duplicate()
            val yArr = ByteArray(yBuf.remaining()).also { yBuf.get(it) }
            val uArr = ByteArray(uBuf.remaining()).also { uBuf.get(it) }
            val vArr = ByteArray(vBuf.remaining()).also { vBuf.get(it) }
            val yStride = yPlane.rowStride
            val uvStride = uPlane.rowStride
            val uvPixel = uPlane.pixelStride
            val px = IntArray(w * h)
            for (row in 0 until h) {
                val yOff = row * yStride
                val uvOff = (row shr 1) * uvStride
                for (col in 0 until w) {
                    val yIdx = yOff + col
                    val uvIdx = uvOff + (col shr 1) * uvPixel
                    if (yIdx >= yArr.size || uvIdx >= uArr.size || uvIdx >= vArr.size) continue
                    val yy = (yArr[yIdx].toInt() and 0xFF) - 16
                    val uu = (uArr[uvIdx].toInt() and 0xFF) - 128
                    val vv = (vArr[uvIdx].toInt() and 0xFF) - 128
                    val r = ((298 * yy + 409 * vv + 128) shr 8).coerceIn(0, 255)
                    val g = ((298 * yy - 100 * uu - 208 * vv + 128) shr 8).coerceIn(0, 255)
                    val b = ((298 * yy + 516 * uu + 128) shr 8).coerceIn(0, 255)
                    px[row * w + col] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
                }
            }
            Bitmap.createBitmap(px, w, h, Bitmap.Config.ARGB_8888)
        } catch (_: Exception) {
            null
        }
    }
}
