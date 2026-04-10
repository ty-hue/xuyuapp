package com.example.pixelfree_camera

/**
 * MediaPipe / ML Kit run on a **downscaled upright** bitmap when the full upright long side exceeds this.
 * Normalized landmarks are invariant under uniform scale; remap uses [PreparedFaceFrame.landmarkInferScale].
 *
 * 720 balances speed vs. lip/eye stability on modern phones (commercial apps often use 480–640 for preview).
 */
internal object FaceLandmarkInferenceConfig {
    const val MAX_UPRIGHT_LONG_SIDE: Int = 640
}
