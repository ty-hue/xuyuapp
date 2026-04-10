package com.example.pixelfree_camera

import android.graphics.Bitmap
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.PointF
import android.graphics.Rect
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetector
import com.google.mlkit.vision.face.FaceDetectorOptions
import com.google.mlkit.vision.face.FaceLandmark
import java.util.concurrent.TimeUnit
import kotlin.math.min

internal data class FaceOverlay(
    val centerX: Float,
    val centerY: Float,
    val faceWidth: Float,
    val faceHeight: Float,
    val eyeCenterX: Float,
    val eyeCenterY: Float,
    val headTopX: Float,
    val headTopY: Float,
    val rollDegrees: Float = 0f,
)

internal class FaceTracker(
    private val onOverlay: (FaceOverlay) -> Unit = {}
) {
    private val detector: FaceDetector = FaceDetection.getClient(
        FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
            .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
            .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
            .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
            .build()
    )

    @Volatile
    private var latestOverlay: FaceOverlay? = null

    fun latest(): FaceOverlay? = latestOverlay

    fun release() {
        runCatching { detector.close() }
    }

    /**
     * Same upright bitmap + inverse-to-buffer as MediaPipe ([PreparedFaceFrame]).
     * ML Kit sees [PreparedFaceFrame.rotated] with rotation **0**; overlay is remapped to buffer-normalized
     * space for [SyntheticFaceLandmarks] / GL.
     */
    fun processPreparedSync(prepared: PreparedFaceFrame): FaceOverlay? {
        val inputImage = InputImage.fromBitmap(prepared.rotated, 0)
        val faces: List<Face> = try {
            Tasks.await(detector.process(inputImage), 120, TimeUnit.MILLISECONDS)
        } catch (_: Exception) {
            return null
        }
        val uprightNorm = mapFace(
            faces.firstOrNull(),
            prepared.rotated.width.coerceAtLeast(1),
            prepared.rotated.height.coerceAtLeast(1),
            0,
        ) ?: return null
        val mapped = uprightNorm.remapUprightNormToBufferCore(
            prepared.bufferW,
            prepared.bufferH,
            prepared.mpW,
            prepared.mpH,
            prepared.uprightCanvasLeft,
            prepared.uprightCanvasTop,
            prepared.uprightToBufferInv,
        )
        latestOverlay = mapped
        onOverlay(mapped)
        return mapped
    }

    /**
     * ML Kit on **YUV/NV21** + same upright→buffer remap as MediaPipe. Often more reliable than
     * [processPreparedSync] (`fromBitmap(rotated)`) on some devices.
     */
    fun processSyncRemappedToBuffer(
        image: android.media.Image,
        previewRotationDegrees: Int,
        prepared: PreparedFaceFrame,
    ): FaceOverlay? {
        val det = uprightDetectFromMediaImage(image, previewRotationDegrees) ?: return null
        val upright = det.overlay.rescaleUprightNormIfNeeded(
            det.uprightW,
            det.uprightH,
            prepared.mpW,
            prepared.mpH,
        )
        val mapped = upright.remapUprightNormToBufferCore(
            prepared.bufferW,
            prepared.bufferH,
            prepared.mpW,
            prepared.mpH,
            prepared.uprightCanvasLeft,
            prepared.uprightCanvasTop,
            prepared.uprightToBufferInv,
        )
        latestOverlay = mapped
        onOverlay(mapped)
        return mapped
    }

    /**
     * Fallback when [PreparedFaceFrame.fromImageProxy] is null (e.g. exotic analysis format).
     * Coordinates are **InputImage upright** only — does not match GL buffer.
     */
    fun processSync(image: android.media.Image, previewRotationDegrees: Int): FaceOverlay? {
        val mapped = uprightDetectFromMediaImage(image, previewRotationDegrees)?.overlay ?: return null
        latestOverlay = mapped
        onOverlay(mapped)
        return mapped
    }

    private data class UprightDetect(val overlay: FaceOverlay, val uprightW: Int, val uprightH: Int)

    private fun uprightDetectFromMediaImage(image: android.media.Image, previewRotationDegrees: Int): UprightDetect? {
        val rot = ((previewRotationDegrees % 360) + 360) % 360
        val inputImage: InputImage = when {
            image.format == ImageFormat.YUV_420_888 && image.planes.size >= 3 -> {
                try {
                    InputImage.fromMediaImage(image, rot)
                } catch (_: Exception) {
                    val nv21 = yuv420888ToNv21(image)
                    InputImage.fromByteArray(
                        nv21, image.width, image.height, rot, InputImage.IMAGE_FORMAT_NV21,
                    )
                }
            }
            image.planes.isNotEmpty() && image.planes[0].pixelStride == 4 -> {
                val bmp = rgba8888ImageToBitmap(image) ?: return null
                try {
                    InputImage.fromBitmap(bmp, rot)
                } finally {
                    bmp.recycle()
                }
            }
            else -> return null
        }
        val faces: List<Face> = try {
            Tasks.await(detector.process(inputImage), 150, TimeUnit.MILLISECONDS)
        } catch (_: Exception) {
            return null
        }
        val o = mapFace(faces.firstOrNull(), inputImage.width, inputImage.height, 0) ?: return null
        return UprightDetect(o, inputImage.width, inputImage.height)
    }

    /** ML Kit [InputImage] size may differ by 1px from [PreparedFaceFrame.rotated]; align norm before remap. */
    private fun FaceOverlay.rescaleUprightNormIfNeeded(sw: Int, sh: Int, dw: Int, dh: Int): FaceOverlay {
        if (sw == dw && sh == dh) return this
        val sx = sw.toFloat() / dw.toFloat()
        val sy = sh.toFloat() / dh.toFloat()
        return copy(
            centerX = (centerX * sx).coerceIn(0f, 1f),
            centerY = (centerY * sy).coerceIn(0f, 1f),
            faceWidth = (faceWidth * sx).coerceIn(0.05f, 1f),
            faceHeight = (faceHeight * sy).coerceIn(0.05f, 1f),
            eyeCenterX = (eyeCenterX * sx).coerceIn(0f, 1f),
            eyeCenterY = (eyeCenterY * sy).coerceIn(0f, 1f),
            headTopX = (headTopX * sx).coerceIn(0f, 1f),
            headTopY = (headTopY * sy).coerceIn(0f, 1f),
        )
    }

    /** CameraX [ImageAnalysis] RGBA: single plane, 4 bytes per pixel (R,G,B,A). */
    private fun rgba8888ImageToBitmap(image: android.media.Image): Bitmap? {
        val w = image.width
        val h = image.height
        if (w <= 0 || h <= 0) return null
        val plane = image.planes.getOrNull(0) ?: return null
        if (plane.pixelStride != 4) return null
        val rowStride = plane.rowStride
        val buf = plane.buffer.duplicate()
        buf.clear()
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        if (rowStride == w * 4) {
            return try {
                bmp.copyPixelsFromBuffer(buf)
                bmp
            } catch (_: Exception) {
                bmp.recycle()
                null
            }
        }
        return try {
            val pixels = IntArray(w * h)
            for (row in 0 until h) {
                var offset = row * rowStride
                for (col in 0 until w) {
                    val r = buf.get(offset).toInt() and 0xFF
                    val g = buf.get(offset + 1).toInt() and 0xFF
                    val b = buf.get(offset + 2).toInt() and 0xFF
                    val a = buf.get(offset + 3).toInt() and 0xFF
                    pixels[row * w + col] = (a shl 24) or (r shl 16) or (g shl 8) or b
                    offset += 4
                }
            }
            bmp.setPixels(pixels, 0, w, 0, 0, w, h)
            bmp
        } catch (_: Exception) {
            bmp.recycle()
            null
        }
    }

    private fun yuv420888ToNv21(image: android.media.Image): ByteArray {
        val width = image.width
        val height = image.height
        val yuv = ByteArray(width * height * 3 / 2)
        var offset = 0

        val yPlane = image.planes[0]
        val yBuffer = yPlane.buffer.duplicate()
        val yRowStride = yPlane.rowStride
        val yPixelStride = yPlane.pixelStride
        val yRow = ByteArray(yRowStride)
        for (row in 0 until height) {
            val rowStart = row * yRowStride
            yBuffer.position(rowStart)
            yBuffer.get(yRow, 0, min(yRowStride, yBuffer.remaining()))
            var col = 0
            while (col < width) {
                yuv[offset++] = yRow[col * yPixelStride]
                col++
            }
        }

        val uPlane = image.planes[1]
        val vPlane = image.planes[2]
        val uBuffer = uPlane.buffer.duplicate()
        val vBuffer = vPlane.buffer.duplicate()
        val uRowStride = uPlane.rowStride
        val vRowStride = vPlane.rowStride
        val uPixelStride = uPlane.pixelStride
        val vPixelStride = vPlane.pixelStride
        val uRow = ByteArray(uRowStride)
        val vRow = ByteArray(vRowStride)

        for (row in 0 until height / 2) {
            val uRowStart = row * uRowStride
            val vRowStart = row * vRowStride
            uBuffer.position(uRowStart)
            vBuffer.position(vRowStart)
            uBuffer.get(uRow, 0, min(uRowStride, uBuffer.remaining()))
            vBuffer.get(vRow, 0, min(vRowStride, vBuffer.remaining()))
            var col = 0
            while (col < width / 2) {
                yuv[offset++] = vRow[col * vPixelStride]
                yuv[offset++] = uRow[col * uPixelStride]
                col++
            }
        }
        return yuv
    }

    private fun mapFace(face: Face?, frameWidth: Int, frameHeight: Int, previewRotationDegrees: Int): FaceOverlay? {
        if (face == null) return null
        val box: Rect = face.boundingBox

        val cx = box.exactCenterX().coerceIn(0f, frameWidth.toFloat())
        val cy = box.exactCenterY().coerceIn(0f, frameHeight.toFloat())
        val width = box.width().toFloat().coerceAtLeast(1f)
        val height = box.height().toFloat().coerceAtLeast(1f)

        val leftEye = face.getLandmark(FaceLandmark.LEFT_EYE)?.position
        val rightEye = face.getLandmark(FaceLandmark.RIGHT_EYE)?.position
        val eyeCenter = when {
            leftEye != null && rightEye != null -> PointF((leftEye.x + rightEye.x) * 0.5f, (leftEye.y + rightEye.y) * 0.5f)
            leftEye != null -> leftEye
            rightEye != null -> rightEye
            else -> PointF(cx, cy - height * 0.18f)
        }
        val headTop = PointF(cx, cy - height * 0.62f)

        return FaceOverlay(
            centerX = (cx / frameWidth).coerceIn(0f, 1f),
            centerY = (cy / frameHeight).coerceIn(0f, 1f),
            faceWidth = (width / frameWidth).coerceIn(0.05f, 1f),
            faceHeight = (height / frameHeight).coerceIn(0.05f, 1f),
            eyeCenterX = (eyeCenter.x / frameWidth).coerceIn(0f, 1f),
            eyeCenterY = (eyeCenter.y / frameHeight).coerceIn(0f, 1f),
            headTopX = (headTop.x / frameWidth).coerceIn(0f, 1f),
            headTopY = (headTop.y / frameHeight).coerceIn(0f, 1f),
        )
    }

    /** Upright normalized → buffer normalized; matches [Bitmap.createBitmap] canvas `translate(-L,-T)·matrix`. */
    private fun FaceOverlay.remapUprightNormToBufferCore(
        bufferW: Int,
        bufferH: Int,
        mpW: Int,
        mpH: Int,
        uprightCanvasLeft: Float,
        uprightCanvasTop: Float,
        uprightToBufferInv: Matrix,
    ): FaceOverlay {
        fun m(nx: Float, ny: Float): Pair<Float, Float> {
            val px = floatArrayOf(nx * mpW + uprightCanvasLeft, ny * mpH + uprightCanvasTop)
            uprightToBufferInv.mapPoints(px)
            val bx = px[0] / bufferW + LandmarkSpaceTuning.BUFFER_NORM_BIAS_X
            val by = px[1] / bufferH + LandmarkSpaceTuning.BUFFER_NORM_BIAS_Y
            return bx.coerceIn(0f, 1f) to by.coerceIn(0f, 1f)
        }
        val (cx, cy) = m(centerX, centerY)
        val (ex, ey) = m(eyeCenterX, eyeCenterY)
        val (hx, hy) = m(headTopX, headTopY)
        val bw = (faceWidth * mpW / bufferW).coerceIn(0.04f, 1f)
        val bh = (faceHeight * mpH / bufferH).coerceIn(0.04f, 1f)
        return copy(
            centerX = cx,
            centerY = cy,
            eyeCenterX = ex,
            eyeCenterY = ey,
            headTopX = hx,
            headTopY = hy,
            faceWidth = bw,
            faceHeight = bh,
        )
    }
}
