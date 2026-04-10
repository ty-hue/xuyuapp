package com.example.pixelfree_camera

import android.media.Image
import androidx.camera.core.ImageProxy

/**
 * Estimates relative scene brightness [0,1] from YUV_420_888 Y plane (center crop, sparse samples).
 * Used for flash "auto": bright scene → no flash / no screen fill; dark → allow flash.
 */
internal object PreviewSceneLuma {
    /**
     * @return average luma in 0..1, or null if plane data unavailable.
     */
    fun computeLuma01(image: Image): Float? {
        val planes = image.planes
        if (planes.isEmpty()) return null
        val plane = planes[0]
        val buf = plane.buffer.duplicate()
        buf.clear()
        val rowStride = plane.rowStride
        val pixelStride = plane.pixelStride
        val w = image.width
        val h = image.height
        if (w <= 0 || h <= 0) return null

        val x0 = w / 4
        val y0 = h / 4
        val cw = w / 2
        val ch = h / 2
        var sum = 0L
        var count = 0
        var y = y0
        while (y < y0 + ch) {
            var x = x0
            while (x < x0 + cw) {
                val offset = y * rowStride + x * pixelStride
                if (offset < buf.capacity()) {
                    sum += buf.get(offset).toInt() and 0xFF
                    count++
                }
                x += 6
            }
            y += 6
        }
        if (count == 0) return null
        return (sum.toDouble() / (count * 255.0)).toFloat().coerceIn(0f, 1f)
    }

    /** CameraX [ImageAnalysis] RGBA_8888: sparse luminance in center crop (approximate Y from RGB). */
    fun computeLuma01FromRgbaImageProxy(proxy: ImageProxy): Float? {
        val planes = proxy.planes
        if (planes.isEmpty()) return null
        val plane = planes[0]
        val buf = plane.buffer.duplicate()
        buf.rewind()
        val rowStride = plane.rowStride
        val pixelStride = plane.pixelStride
        val w = proxy.width
        val h = proxy.height
        if (w <= 0 || h <= 0 || pixelStride < 4) return null
        val x0 = w / 4
        val y0 = h / 4
        val cw = w / 2
        val ch = h / 2
        var sum = 0.0
        var count = 0
        var y = y0
        while (y < y0 + ch) {
            var x = x0
            while (x < x0 + cw) {
                val offset = y * rowStride + x * pixelStride
                if (offset + 2 < buf.capacity()) {
                    val r = buf.get(offset).toInt() and 0xFF
                    val g = buf.get(offset + 1).toInt() and 0xFF
                    val b = buf.get(offset + 2).toInt() and 0xFF
                    sum += 0.299 * r + 0.587 * g + 0.114 * b
                    count++
                }
                x += 6
            }
            y += 6
        }
        if (count == 0) return null
        return (sum / (count * 255.0)).toFloat().coerceIn(0f, 1f)
    }
}
