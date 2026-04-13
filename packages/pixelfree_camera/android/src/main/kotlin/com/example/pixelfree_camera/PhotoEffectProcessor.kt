package com.example.pixelfree_camera

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import androidx.core.graphics.scale
import java.io.ByteArrayOutputStream
import kotlin.math.max

/**
 * CPU-based image processor for beauty + filter on still captures and video frames.
 * Sticker rendering has been removed — stickers are now handled in Flutter post-capture editor.
 * AR effects are rendered by the GL pipeline and baked into the texture before readback.
 *
 * 全尺寸 12MP+ 解码 + 磨皮缩放 在低端机上单次可 >5s；静态照按长边降采样后再处理。
 */
internal class PhotoEffectProcessor {
    companion object {
        /** 仍保持清晰，但把像素量压到可接受，CPU 磨皮/矩阵与像素数近似线性。 */
        private const val MAX_STILL_LONG_EDGE_PX = 4096
    }

    fun processJpeg(
        jpegBytes: ByteArray,
        beautySettings: Map<String, Any?>,
        filterSettings: Map<String, Any?>,
        faceOverlay: FaceOverlay?,
    ): ByteArray {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return jpegBytes
        val sample = calculateInSampleSize(bounds.outWidth, bounds.outHeight, MAX_STILL_LONG_EDGE_PX)
        val opts = BitmapFactory.Options().apply { inSampleSize = sample }
        val source = BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size, opts) ?: return jpegBytes
        val processed = processBitmap(source, beautySettings, filterSettings, faceOverlay)
        if (processed != source) source.recycle()
        val output = ByteArrayOutputStream()
        processed.compress(Bitmap.CompressFormat.JPEG, 92, output)
        processed.recycle()
        return output.toByteArray()
    }

    private fun calculateInSampleSize(width: Int, height: Int, maxLongEdge: Int): Int {
        var inSampleSize = 1
        val longer = maxOf(width, height)
        while (longer / inSampleSize > maxLongEdge) {
            inSampleSize *= 2
        }
        return inSampleSize
    }

    fun processBitmap(
        source: Bitmap,
        beautySettings: Map<String, Any?>,
        filterSettings: Map<String, Any?>,
        faceOverlay: FaceOverlay?,
    ): Bitmap {
        val original = source.copy(Bitmap.Config.ARGB_8888, true)

        val smoothing = BeautyFlutterScale.smoothingFromFlutter(beautySettings["smoothing"] as? Number)
        val whitening = BeautyFlutterScale.whiteningFromFlutter(beautySettings["whitening"] as? Number)
        val ruddy = (beautySettings["ruddy"] as? Number)?.toFloat() ?: 0f
        val sharpen = (beautySettings["sharpen"] as? Number)?.toFloat() ?: 0f
        val intensity = (filterSettings["intensity"] as? Number)?.toFloat() ?: 0f
        val filterId = filterSettings["filterId"] as? String

        var beautified = original.copy(Bitmap.Config.ARGB_8888, true)
        if (smoothing > 0f) {
            val blurred = soften(beautified, smoothing)
            if (blurred != beautified) { beautified.recycle(); beautified = blurred }
        }

        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
        paint.colorFilter = ColorMatrixColorFilter(
            buildColorMatrix(whitening, ruddy, sharpen, filterId, intensity)
        )

        val colored = Bitmap.createBitmap(beautified.width, beautified.height, Bitmap.Config.ARGB_8888)
        Canvas(colored).drawBitmap(beautified, 0f, 0f, paint)
        beautified.recycle()

        if (faceOverlay == null) {
            original.recycle()
            return colored
        }
        // 同一归一化人脸框在「原图 / 美颜图」上对应同一块区域；不能把整张 colored 缩放到 dst（会整图挤进小脸框）。
        val result = original.copy(Bitmap.Config.ARGB_8888, true)
        val srcRf = faceRect(colored.width, colored.height, faceOverlay)
        val dstRf = faceRect(result.width, result.height, faceOverlay)
        val src = Rect(
            srcRf.left.toInt().coerceIn(0, colored.width - 1),
            srcRf.top.toInt().coerceIn(0, colored.height - 1),
            srcRf.right.toInt().coerceIn(srcRf.left.toInt() + 1, colored.width),
            srcRf.bottom.toInt().coerceIn(srcRf.top.toInt() + 1, colored.height),
        )
        Canvas(result).drawBitmap(colored, src, dstRf, Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG))
        original.recycle(); colored.recycle()
        return result
    }

    private fun faceRect(width: Int, height: Int, faceOverlay: FaceOverlay): RectF {
        val cx = faceOverlay.centerX * width
        val cy = faceOverlay.centerY * height
        val w = (faceOverlay.faceWidth * width * 1.35f).coerceAtLeast(1f)
        val h = (faceOverlay.faceHeight * height * 1.5f).coerceAtLeast(1f)
        return RectF(
            (cx - w / 2f).coerceIn(0f, width.toFloat()),
            (cy - h / 2f).coerceIn(0f, height.toFloat()),
            (cx + w / 2f).coerceIn(0f, width.toFloat()),
            (cy + h / 2f).coerceIn(0f, height.toFloat()),
        )
    }

    private fun soften(bitmap: Bitmap, amount: Float): Bitmap {
        val scaleFactor = 1f - (amount.coerceIn(0f, 1f) * 0.45f)
        val tw = max(1, (bitmap.width * scaleFactor).toInt())
        val th = max(1, (bitmap.height * scaleFactor).toInt())
        val down = bitmap.scale(tw, th, true)
        return down.scale(bitmap.width, bitmap.height, true).also { if (down != bitmap) down.recycle() }
    }

    private fun buildColorMatrix(
        whitening: Float, ruddy: Float, sharpen: Float, filterId: String?, filterIntensity: Float,
    ): ColorMatrix {
        val matrix = ColorMatrix()
        val ws = 1f + whitening.coerceIn(0f, 1f) * 0.18f
        val wo = whitening.coerceIn(0f, 1f) * 18f
        matrix.postConcat(ColorMatrix(floatArrayOf(ws,0f,0f,0f,wo, 0f,ws,0f,0f,wo, 0f,0f,ws,0f,wo, 0f,0f,0f,1f,0f)))
        if (ruddy > 0f) {
            val a = ruddy.coerceIn(0f, 1f)
            matrix.postConcat(ColorMatrix(floatArrayOf(1f+a*0.08f,0f,0f,0f,a*10f, 0f,1f-a*0.03f,0f,0f,a*2f, 0f,0f,1f-a*0.05f,0f,0f, 0f,0f,0f,1f,0f)))
        }
        if (sharpen > 0f) {
            val a = sharpen.coerceIn(0f, 1f); val c = 1f + a * 0.12f; val t = (-0.5f * c + 0.5f) * 255f
            matrix.postConcat(ColorMatrix(floatArrayOf(c,0f,0f,0f,t, 0f,c,0f,0f,t, 0f,0f,c,0f,t, 0f,0f,0f,1f,0f)))
        }
        matrix.postConcat(filterMatrix(filterId, filterIntensity.coerceIn(0f, 1f)))
        return matrix
    }

    private fun filterMatrix(filterId: String?, intensity: Float): ColorMatrix {
        if (filterId.isNullOrBlank() || intensity <= 0f) return ColorMatrix()
        val target = when (filterId.lowercase()) {
            "cool","lengku" -> floatArrayOf(0.95f,0f,0f,0f,0f, 0f,1f,0f,0f,4f, 0f,0f,1.08f,0f,12f, 0f,0f,0f,1f,0f)
            "warm","naicha" -> floatArrayOf(1.06f,0f,0f,0f,10f, 0f,1f,0f,0f,4f, 0f,0f,0.92f,0f,-4f, 0f,0f,0f,1f,0f)
            "fresh","qingxin" -> floatArrayOf(1.02f,0f,0f,0f,4f, 0f,1.04f,0f,0f,8f, 0f,0f,1f,0f,6f, 0f,0f,0f,1f,0f)
            "rixi" -> floatArrayOf(1.04f,0f,0f,0f,12f, 0f,1.01f,0f,0f,6f, 0f,0f,0.9f,0f,-8f, 0f,0f,0f,1f,0f)
            else -> return ColorMatrix()
        }
        val identity = floatArrayOf(1f,0f,0f,0f,0f, 0f,1f,0f,0f,0f, 0f,0f,1f,0f,0f, 0f,0f,0f,1f,0f)
        return ColorMatrix(FloatArray(20) { identity[it] + (target[it] - identity[it]) * intensity })
    }
}
