package com.example.pixelfree_camera

import android.media.Image
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions
import java.nio.FloatBuffer
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * ML Kit **Subject Segmentation** — foreground confidence vs background (Play services unbundled model).
 * Used with [FaceMeshArPass] `green_hair` to reduce tint on background pixels (mesh-only is ambiguous at the hairline).
 *
 * Docs: [Subject segmentation](https://developers.google.com/ml-kit/vision/subject-segmentation/android)
 */
internal class SubjectSegmentationHelper {

    private val segmenter = SubjectSegmentation.getClient(
        SubjectSegmenterOptions.Builder()
            .enableForegroundConfidenceMask()
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

    fun processFrame(image: Image, rotationDegrees: Int) {
        if (!busy.compareAndSet(false, true)) return
        try {
            val inputImage = try {
                InputImage.fromMediaImage(image, rotationDegrees)
            } catch (_: Exception) {
                return
            }
            val mw = inputImage.width
            val mh = inputImage.height
            val result = try {
                Tasks.await(segmenter.process(inputImage), 320, TimeUnit.MILLISECONDS)
            } catch (_: Exception) {
                hasValidMask = false
                return
            }
            convertForegroundMaskToLuminanceBytes(result.foregroundConfidenceMask, mw, mh)
        } finally {
            busy.set(false)
        }
    }

    private fun convertForegroundMaskToLuminanceBytes(mask: FloatBuffer?, imgW: Int, imgH: Int) {
        if (mask == null || imgW <= 0 || imgH <= 0) {
            hasValidMask = false
            return
        }
        val buf = mask.duplicate()
        buf.rewind()
        val n = imgW * imgH
        if (buf.remaining() < n) {
            hasValidMask = false
            return
        }
        val bytes = ByteArray(n)
        for (i in 0 until n) {
            val f = buf.get()
            bytes[i] = (f.coerceIn(0f, 1f) * 255f).toInt().toByte()
        }
        latestMaskBytes = bytes
        latestMaskWidth = imgW
        latestMaskHeight = imgH
        hasValidMask = true
    }

    fun release() {
        runCatching { segmenter.close() }
        latestMaskBytes = null
        hasValidMask = false
    }
}
