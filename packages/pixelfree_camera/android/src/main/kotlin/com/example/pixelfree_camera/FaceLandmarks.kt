package com.example.pixelfree_camera

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/** Normalized-image AABB of an eye contour (rim indices), for AR that must align with preview. */
internal data class EyeRegionNorm(val cx: Float, val cy: Float, val halfW: Float, val halfH: Float)

/**
 * Full 478-landmark face data from MediaPipe Solutions FaceMesh (refined mesh with irises, official Java API).
 *
 * [points] stores 478 normalized (x,y) pairs as a flat array of 956 floats:
 *   points[i*2]   = landmark i x (0..1 in sensor image space)
 *   points[i*2+1] = landmark i y (0..1 in sensor image space)
 *
 * [z] 与 MediaPipe [NormalizedLandmark.z] 对齐：相对脸部尺度的深度（米量级标度），用于 3D 线框透视感。
 */
internal class FaceLandmarks(
    val points: FloatArray,
    val timestampNs: Long,
    val z: FloatArray = FloatArray(COUNT),
) {
    companion object {
        const val COUNT = 478
        const val ARRAY_SIZE = COUNT * 2

        const val UPPER_LIP = 0
        const val NOSE_TIP = 1
        const val FOREHEAD = 10
        const val LEFT_EYE_OUTER = 33
        const val LEFT_MOUTH = 61
        const val LEFT_EYE_INNER = 133
        const val CHIN = 152
        const val LEFT_CHEEK = 234
        const val RIGHT_EYE_OUTER = 263
        const val RIGHT_MOUTH = 291
        const val RIGHT_EYE_INNER = 362
        const val RIGHT_CHEEK = 454
        const val LEFT_IRIS = 468
        const val RIGHT_IRIS = 473

        val FACE_OVAL_INDICES = intArrayOf(
            10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288,
            397, 365, 379, 378, 400, 377, 152, 148, 176, 149, 150, 136,
            172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109, 10,
        )

        /** Closed LINE_STRIP: along MediaPipe eye rim (outer → upper lid → inner → lower lid → outer). */
        val LEFT_EYE_INDICES = intArrayOf(
            33, 246, 161, 160, 159, 158, 157, 173, 155, 154, 153, 145, 144, 163, 7, 33,
        )
        val RIGHT_EYE_INDICES = intArrayOf(
            362, 398, 384, 385, 386, 387, 388, 466, 263, 249, 390, 373, 374, 380, 381, 382, 362,
        )
        val LIPS_INDICES = intArrayOf(
            61, 146, 91, 181, 84, 17, 314, 405, 321, 375, 291,
            409, 270, 269, 267, 0, 37, 39, 40, 185, 61,
        )

        /** Full face mesh (TF.js `TRIANGULATION`, ~880 triangles, indices 0–467). See [FaceMeshTesselation468]. */
        val MESH_TRIANGLES: IntArray
            get() = FaceMeshTesselation468.TRIANGLE_INDICES

        /**
         * Stable normalized layout when no face is tracked — keeps AR overlays/particles visible
         * after the user leaves the frame or before first detection.
         */
        /**
         * Face Landmarker may return **468** landmarks (no iris). Indices 468–477 stay 0 → laser/写轮眼等
         * 会跑到画面角上。用眼睑轮廓 AABB 中心填充虹膜环，与 [eyeRegionFromContour] 一致。
         */
        fun patchIrisLandmarksIfAbsent(pts: FloatArray) {
            if (pts.size < ARRAY_SIZE) return
            val fl = FaceLandmarks(pts, 0L)
            fun ringMissing(startIdx: Int): Boolean {
                for (i in 0 until 5) {
                    val ii = startIdx + i
                    if (kotlin.math.abs(pts[ii * 2]) > 1e-5f || kotlin.math.abs(pts[ii * 2 + 1]) > 1e-5f) {
                        return false
                    }
                }
                return true
            }
            if (ringMissing(468)) {
                val r = fl.eyeRegionFromContour(LEFT_EYE_INDICES)
                for (i in 468..472) {
                    pts[i * 2] = r.cx
                    pts[i * 2 + 1] = r.cy
                }
            }
            if (ringMissing(473)) {
                val r = fl.eyeRegionFromContour(RIGHT_EYE_INDICES)
                for (i in 473..477) {
                    pts[i * 2] = r.cx
                    pts[i * 2 + 1] = r.cy
                }
            }
        }

        fun neutralForArEffects(): FaceLandmarks {
            val pts = FloatArray(ARRAY_SIZE)
            val cx = 0.5f
            val cy = 0.45f
            for (i in 0 until COUNT) {
                pts[i * 2] = cx
                pts[i * 2 + 1] = cy
            }
            val n = FACE_OVAL_INDICES.size
            for (j in 0 until n) {
                val idx = FACE_OVAL_INDICES[j]
                val t = (j.toFloat() / n) * (2f * PI.toFloat())
                pts[idx * 2] = (cx + 0.18f * cos(t)).coerceIn(0.02f, 0.98f)
                pts[idx * 2 + 1] = (cy + 0.22f * sin(t)).coerceIn(0.02f, 0.98f)
            }
            pts[NOSE_TIP * 2] = cx
            pts[NOSE_TIP * 2 + 1] = (cy + 0.05f).coerceIn(0.02f, 0.98f)
            pts[FOREHEAD * 2] = cx
            pts[FOREHEAD * 2 + 1] = (cy - 0.18f).coerceIn(0.02f, 0.98f)
            pts[CHIN * 2] = cx
            pts[CHIN * 2 + 1] = (cy + 0.20f).coerceIn(0.02f, 0.98f)
            pts[LEFT_CHEEK * 2] = (cx - 0.14f).coerceIn(0.02f, 0.98f)
            pts[LEFT_CHEEK * 2 + 1] = (cy + 0.02f).coerceIn(0.02f, 0.98f)
            pts[RIGHT_CHEEK * 2] = (cx + 0.14f).coerceIn(0.02f, 0.98f)
            pts[RIGHT_CHEEK * 2 + 1] = (cy + 0.02f).coerceIn(0.02f, 0.98f)
            pts[LEFT_IRIS * 2] = (cx - 0.07f).coerceIn(0.02f, 0.98f)
            pts[LEFT_IRIS * 2 + 1] = (cy - 0.05f).coerceIn(0.02f, 0.98f)
            pts[RIGHT_IRIS * 2] = (cx + 0.07f).coerceIn(0.02f, 0.98f)
            pts[RIGHT_IRIS * 2 + 1] = (cy - 0.05f).coerceIn(0.02f, 0.98f)
            pts[UPPER_LIP * 2] = cx
            pts[UPPER_LIP * 2 + 1] = (cy + 0.08f).coerceIn(0.02f, 0.98f)
            return FaceLandmarks(pts, 0L)
        }
    }

    fun x(index: Int): Float = points[index * 2]
    fun y(index: Int): Float = points[index * 2 + 1]
    fun z(index: Int): Float = if (index in z.indices) z[index] else 0f

    /** Average of MediaPipe left-iris ring (468–472); stabilizes center vs single index. */
    fun leftIrisCenterNorm(): Pair<Float, Float> {
        var sx = 0f
        var sy = 0f
        for (i in 468..472) {
            sx += x(i)
            sy += y(i)
        }
        if (sx < 1e-4f && sy < 1e-4f) {
            val r = eyeRegionFromContour(LEFT_EYE_INDICES)
            return Pair(r.cx, r.cy)
        }
        return Pair(sx / 5f, sy / 5f)
    }

    /** Average of right-iris ring (473–477). */
    fun rightIrisCenterNorm(): Pair<Float, Float> {
        var sx = 0f
        var sy = 0f
        for (i in 473..477) {
            sx += x(i)
            sy += y(i)
        }
        if (sx < 1e-4f && sy < 1e-4f) {
            val r = eyeRegionFromContour(RIGHT_EYE_INDICES)
            return Pair(r.cx, r.cy)
        }
        return Pair(sx / 5f, sy / 5f)
    }

    /**
     * Center and half-size of eye in normalized image coords from closed contour indices.
     * Prefer this over raw iris indices (468/473) for screen alignment with [landmarkToTexUv].
     */
    fun eyeRegionFromContour(indices: IntArray): EyeRegionNorm {
        var minX = 1f
        var maxX = 0f
        var minY = 1f
        var maxY = 0f
        val n = indices.size
        val end = if (n >= 2 && indices[0] == indices[n - 1]) n - 1 else n
        for (i in 0 until end) {
            val idx = indices[i]
            val xi = x(idx)
            val yi = y(idx)
            minX = min(minX, xi)
            maxX = max(maxX, xi)
            minY = min(minY, yi)
            maxY = max(maxY, yi)
        }
        val bw = (maxX - minX).coerceAtLeast(1e-4f)
        val bh = (maxY - minY).coerceAtLeast(1e-4f)
        return EyeRegionNorm(
            cx = (minX + maxX) * 0.5f,
            cy = (minY + maxY) * 0.5f,
            halfW = bw * 0.5f,
            halfH = bh * 0.5f,
        )
    }

    /**
     * One overlay per anatomical eye: **position** = detected iris (468–472 / 473–477 average),
     * **size** = eyelid contour AABB — so the glow sits on each eye and scales with the opening.
     */
    fun eyeRegionForLaser(leftEye: Boolean): EyeRegionNorm {
        val contour = eyeRegionFromContour(
            if (leftEye) LEFT_EYE_INDICES else RIGHT_EYE_INDICES,
        )
        val (ix, iy) = if (leftEye) leftIrisCenterNorm() else rightIrisCenterNorm()
        // If iris coords are garbage vs eyelid box (e.g. stale zeros), stick to contour center.
        val d = kotlin.math.hypot(ix - contour.cx, iy - contour.cy)
        val irisOk = d < 0.22f && ix in 0.02f..0.98f && iy in 0.02f..0.98f
        return EyeRegionNorm(
            cx = if (irisOk) ix else contour.cx,
            cy = if (irisOk) iy else contour.cy,
            halfW = contour.halfW,
            halfH = contour.halfH,
        )
    }

    fun noseTip() = Pair(x(NOSE_TIP), y(NOSE_TIP))
    fun forehead() = Pair(x(FOREHEAD), y(FOREHEAD))
    fun chin() = Pair(x(CHIN), y(CHIN))
    fun leftIris() = Pair(x(LEFT_IRIS), y(LEFT_IRIS))
    fun rightIris() = Pair(x(RIGHT_IRIS), y(RIGHT_IRIS))
    fun leftCheek() = Pair(x(LEFT_CHEEK), y(LEFT_CHEEK))
    fun rightCheek() = Pair(x(RIGHT_CHEEK), y(RIGHT_CHEEK))
    fun upperLip() = Pair(x(UPPER_LIP), y(UPPER_LIP))

    fun eyeCenter(): Pair<Float, Float> {
        val (lx, ly) = leftIrisCenterNorm()
        val (rx, ry) = rightIrisCenterNorm()
        return Pair((lx + rx) * 0.5f, (ly + ry) * 0.5f)
    }

    fun faceCenter(): Pair<Float, Float> {
        val lx = x(LEFT_CHEEK); val rx = x(RIGHT_CHEEK)
        val ty = y(FOREHEAD); val by = y(CHIN)
        return Pair((lx + rx) * 0.5f, (ty + by) * 0.5f)
    }

    fun faceWidth(): Float = kotlin.math.abs(x(RIGHT_CHEEK) - x(LEFT_CHEEK))
    fun faceHeight(): Float = kotlin.math.abs(y(CHIN) - y(FOREHEAD))

    fun toLegacyOverlay(): FaceOverlay {
        val (cx, cy) = faceCenter()
        val (ex, ey) = eyeCenter()
        return FaceOverlay(
            centerX = cx, centerY = cy,
            faceWidth = (faceWidth() * 1.35f).coerceIn(0.05f, 1f),
            faceHeight = (faceHeight() * 1.15f).coerceIn(0.05f, 1f),
            eyeCenterX = ex, eyeCenterY = ey,
            headTopX = x(FOREHEAD), headTopY = y(FOREHEAD),
        )
    }
}
