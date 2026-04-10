package com.example.pixelfree_camera

import kotlin.math.cos
import kotlin.math.max
import kotlin.math.sin

/**
 * Builds a coarse [FaceLandmarks] from ML Kit [FaceOverlay] so Kalman + AR can run
 * before MediaPipe is ready, or if MediaPipe fails to load.
 */
internal object SyntheticFaceLandmarks {

    fun fromOverlay(o: FaceOverlay): FaceLandmarks {
        val pts = FloatArray(FaceLandmarks.ARRAY_SIZE)
        val cx = o.centerX
        val cy = o.centerY
        val fw = o.faceWidth.coerceAtLeast(0.08f)
        val fh = o.faceHeight.coerceAtLeast(0.08f)
        val rx = fw * 0.48f
        val ry = fh * 0.52f

        val oval = FaceLandmarks.FACE_OVAL_INDICES
        for (i in oval.indices) {
            val idx = oval[i]
            val angle = (i.toFloat() / oval.size) * (2f * Math.PI.toFloat())
            pts[idx * 2] = (cx + rx * cos(angle)).coerceIn(0.001f, 0.999f)
            pts[idx * 2 + 1] = (cy + ry * sin(angle)).coerceIn(0.001f, 0.999f)
        }

        val lex = (o.eyeCenterX - fw * 0.16f).coerceIn(0f, 1f)
        val rex = (o.eyeCenterX + fw * 0.16f).coerceIn(0f, 1f)
        val ey = o.eyeCenterY
        // MediaPipe-style iris rings (468–472 / 473–477) so [leftIrisCenterNorm]/laser AR match real pipeline.
        val ir = max(fw * 0.02f, 0.004f)
        val pi2 = (2f * Math.PI).toFloat()
        for (j in 0..4) {
            val ang = j / 5f * pi2
            val li = 468 + j
            pts[li * 2] = (lex + ir * cos(ang)).coerceIn(0.001f, 0.999f)
            pts[li * 2 + 1] = (ey + ir * sin(ang)).coerceIn(0.001f, 0.999f)
            val ri = 473 + j
            pts[ri * 2] = (rex + ir * cos(ang)).coerceIn(0.001f, 0.999f)
            pts[ri * 2 + 1] = (ey + ir * sin(ang)).coerceIn(0.001f, 0.999f)
        }

        pts[FaceLandmarks.FOREHEAD * 2] = o.headTopX
        pts[FaceLandmarks.FOREHEAD * 2 + 1] = o.headTopY
        pts[FaceLandmarks.CHIN * 2] = cx
        pts[FaceLandmarks.CHIN * 2 + 1] = (cy + fh * 0.42f).coerceIn(0f, 1f)

        pts[FaceLandmarks.LEFT_CHEEK * 2] = (cx - fw * 0.38f).coerceIn(0f, 1f)
        pts[FaceLandmarks.LEFT_CHEEK * 2 + 1] = cy
        pts[FaceLandmarks.RIGHT_CHEEK * 2] = (cx + fw * 0.38f).coerceIn(0f, 1f)
        pts[FaceLandmarks.RIGHT_CHEEK * 2 + 1] = cy

        pts[FaceLandmarks.NOSE_TIP * 2] = cx
        pts[FaceLandmarks.NOSE_TIP * 2 + 1] = (cy + fh * 0.08f).coerceIn(0f, 1f)
        pts[FaceLandmarks.UPPER_LIP * 2] = cx
        pts[FaceLandmarks.UPPER_LIP * 2 + 1] = (cy + fh * 0.22f).coerceIn(0f, 1f)

        val ler = fw * 0.12f
        val leftEyeIdx = FaceLandmarks.LEFT_EYE_INDICES
        for (i in leftEyeIdx.indices) {
            val idx = leftEyeIdx[i]
            val angle = (i.toFloat() / leftEyeIdx.size) * (2f * Math.PI.toFloat())
            pts[idx * 2] = (lex + ler * cos(angle)).coerceIn(0f, 1f)
            pts[idx * 2 + 1] = (ey + ler * 0.7f * sin(angle)).coerceIn(0f, 1f)
        }
        val rer = fw * 0.12f
        val rightEyeIdx = FaceLandmarks.RIGHT_EYE_INDICES
        for (i in rightEyeIdx.indices) {
            val idx = rightEyeIdx[i]
            val angle = (i.toFloat() / rightEyeIdx.size) * (2f * Math.PI.toFloat())
            pts[idx * 2] = (rex + rer * cos(angle)).coerceIn(0f, 1f)
            pts[idx * 2 + 1] = (ey + rer * 0.7f * sin(angle)).coerceIn(0f, 1f)
        }

        val mouthY = cy + fh * 0.25f
        val lipIdx = FaceLandmarks.LIPS_INDICES
        val mr = fw * 0.18f
        for (i in lipIdx.indices) {
            val idx = lipIdx[i]
            val angle = (i.toFloat() / lipIdx.size) * (2f * Math.PI.toFloat())
            pts[idx * 2] = (cx + mr * cos(angle)).coerceIn(0f, 1f)
            pts[idx * 2 + 1] = (mouthY + mr * 0.35f * sin(angle)).coerceIn(0f, 1f)
        }

        return FaceLandmarks(pts, System.nanoTime())
    }
}
