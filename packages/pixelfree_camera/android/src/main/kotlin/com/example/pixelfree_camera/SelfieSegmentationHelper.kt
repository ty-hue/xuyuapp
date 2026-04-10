package com.example.pixelfree_camera

import android.media.Image
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.segmentation.Segmentation
import com.google.mlkit.vision.segmentation.SegmentationMask
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * ML Kit **Selfie Segmentation** — pixel-wise person / background mask (beta API, ~4.5MB model).
 * Used for portrait blur so the whole person stays sharp and only the background blurs.
 *
 * Docs: [Selfie segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation/android)
 */
internal class SelfieSegmentationHelper {

    private val segmenter = Segmentation.getClient(
        SelfieSegmenterOptions.Builder()
            .setDetectorMode(SelfieSegmenterOptions.STREAM_MODE)
            .build(),
    )

    private val busy = AtomicBoolean(false)

    @Volatile
    var latestMaskBytes: ByteArray? = null
        private set

    @Volatile
    var latestMaskWidth: Int = 0
        private set

    @Volatile
    var latestMaskHeight: Int = 0
        private set

    @Volatile
    var hasValidMask: Boolean = false
        private set

    /**
     * Runs on the camera background thread. Drops frames while a previous segmentation is still
     * running (recommended for real-time — see ML Kit perf notes).
     */
    fun processFrame(image: Image, rotationDegrees: Int) {
        if (!busy.compareAndSet(false, true)) return
        try {
            val inputImage = try {
                InputImage.fromMediaImage(image, rotationDegrees)
            } catch (_: Exception) {
                return
            }
            val mask = try {
                Tasks.await(segmenter.process(inputImage), 150, TimeUnit.MILLISECONDS)
            } catch (_: Exception) {
                hasValidMask = false
                return
            }
            convertMaskToLuminanceBytes(mask)
        } finally {
            busy.set(false)
        }
    }

    private fun convertMaskToLuminanceBytes(segmentationMask: SegmentationMask) {
        val w = segmentationMask.width
        val h = segmentationMask.height
        if (w <= 0 || h <= 0) {
            hasValidMask = false
            return
        }
        val buf = segmentationMask.buffer.duplicate()
        buf.order(ByteOrder.nativeOrder())
        buf.rewind()
        val n = w * h
        val bytes = ByteArray(n)
        var i = 0
        while (i < n && buf.remaining() >= 4) {
            val f = buf.float
            bytes[i] = (f.coerceIn(0f, 1f) * 255f).toInt().toByte()
            i++
        }
        latestMaskBytes = bytes
        latestMaskWidth = w
        latestMaskHeight = h
        hasValidMask = true
    }

    fun release() {
        runCatching { segmenter.close() }
        latestMaskBytes = null
        hasValidMask = false
    }
}
