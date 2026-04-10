package com.example.pixelfree_camera

import android.graphics.Bitmap
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.RectF
import androidx.camera.core.ImageProxy
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min

/**
 * One CameraX [ImageProxy] frame prepared **the same way** for MediaPipe and ML Kit:
 * sensor buffer → upright RGB bitmap, then map upright pixels → buffer with the **same** affine as
 * [Bitmap.createBitmap]: Canvas uses `translate(-dstR.left,-top)·matrix`, so inverse is
 * `matrix⁻¹ · (upPx + (left,top))`, **not** `matrix.invert()` alone.
 *
 * [rotated] may be downscaled for inference; [landmarkInferScale] maps detector pixels → full upright.
 */
internal class PreparedFaceFrame(
    val rotated: Bitmap,
    /**
     * Same layout as [ImageProxy] buffer (before rotate/mirror): W×H, matches landmark 0..1 normalization.
     * **Single-pipeline path:** pass to [GlPreviewRenderer.queueAnalysisDisplayFrame] then [recycleRotatedOnly].
     * **Standalone path:** [recycle] frees both [rotated] and [sensorArgb].
     */
    val sensorArgb: Bitmap,
    val bufferW: Int,
    val bufferH: Int,
    /** Unscaled upright bounds width/height (ceiled); used when remapping normalized landmarks. */
    val mpW: Int,
    val mpH: Int,
    /** Uniform scale (≤1) applied for [rotated] detection bitmap vs. [mpW]×[mpH] upright. */
    val landmarkInferScale: Float,
    /** Bounding rect of transformed buffer corners — [Bitmap.createBitmap] canvas shift. */
    val uprightCanvasLeft: Float,
    val uprightCanvasTop: Float,
    /** Inverse of rotate+mirror [Matrix] only (before canvas translate). */
    val uprightToBufferInv: Matrix,
) {
    /** Full teardown (e.g. [MediaPipeFaceTracker.detectFromImageProxy] with no GL handoff). */
    fun recycle() {
        if (!rotated.isRecycled) rotated.recycle()
        if (!sensorArgb.isRecycled) sensorArgb.recycle()
    }

    /** After [sensorArgb] is passed to [GlPreviewRenderer.queueAnalysisDisplayFrame]. */
    fun recycleRotatedOnly() {
        if (!rotated.isRecycled) rotated.recycle()
    }

    companion object {
        fun fromImageProxy(imageProxy: ImageProxy, isFrontCamera: Boolean): PreparedFaceFrame? {
            val rotation = imageProxy.imageInfo.rotationDegrees
            val image = imageProxy.image ?: return null
            val bitmapBuffer = when {
                image.format == ImageFormat.YUV_420_888 ||
                    image.planes.size >= 3 ->
                    MediaPipeFaceTracker.imageToBitmap(image)
                else ->
                    imageProxyToArgbBitmap(imageProxy)
                        ?: MediaPipeFaceTracker.imageToBitmap(image)
            } ?: return null
            val w = bitmapBuffer.width
            val h = bitmapBuffer.height
            if (w <= 0 || h <= 0) {
                bitmapBuffer.recycle()
                return null
            }
            val baseMatrix = Matrix().apply {
                postRotate(rotation.toFloat())
                if (isFrontCamera) {
                    postScale(-1f, 1f, w / 2f, h / 2f)
                }
            }
            val srcBounds = RectF(0f, 0f, w.toFloat(), h.toFloat())
            val dstBase = RectF()
            baseMatrix.mapRect(dstBase, srcBounds)
            val mpW = ceil(dstBase.width().toDouble()).toInt().coerceAtLeast(1)
            val mpH = ceil(dstBase.height().toDouble()).toInt().coerceAtLeast(1)
            val uprightToBufferInv = Matrix()
            if (!baseMatrix.invert(uprightToBufferInv)) {
                bitmapBuffer.recycle()
                return null
            }
            val maxUpright = max(mpW, mpH).toFloat()
            val cap = FaceLandmarkInferenceConfig.MAX_UPRIGHT_LONG_SIDE.toFloat().coerceAtLeast(320f)
            val inferScale = min(1f, cap / maxUpright)
            val detectMatrix = Matrix(baseMatrix)
            if (inferScale < 1f - 1e-5f) {
                detectMatrix.postScale(inferScale, inferScale)
            }
            val rotated = try {
                Bitmap.createBitmap(bitmapBuffer, 0, 0, w, h, detectMatrix, true)
            } catch (_: Exception) {
                bitmapBuffer.recycle()
                return null
            }
            return PreparedFaceFrame(
                rotated = rotated,
                sensorArgb = bitmapBuffer,
                bufferW = w,
                bufferH = h,
                mpW = mpW,
                mpH = mpH,
                landmarkInferScale = inferScale,
                uprightCanvasLeft = dstBase.left,
                uprightCanvasTop = dstBase.top,
                uprightToBufferInv = uprightToBufferInv,
            )
        }

        private fun imageProxyToArgbBitmap(imageProxy: ImageProxy): Bitmap? {
            val w = imageProxy.width
            val h = imageProxy.height
            if (w <= 0 || h <= 0) return null
            val planes = imageProxy.planes
            if (planes.isEmpty()) return null
            val plane = planes[0]
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
    }
}
