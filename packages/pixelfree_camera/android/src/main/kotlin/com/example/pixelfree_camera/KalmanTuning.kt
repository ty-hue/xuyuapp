package com.example.pixelfree_camera

/** Shared tuning for landmark smoothing (Android Kotlin + iOS Swift). */
internal object KalmanTuning {
    const val POS_GAIN = 0.88f
    const val VEL_GAIN = 0.56f
}

/**
 * Optional nudge in buffer-normalized space after upright→buffer remap. Prefer fixing rotation / `SurfaceTexture`
 * homogeneous coords first (see beauty vertex shader `tc.xy / tc.w`); non-zero bias can hide the real error.
 */
internal object LandmarkSpaceTuning {
    const val BUFFER_NORM_BIAS_X = 0f
    const val BUFFER_NORM_BIAS_Y = 0f
    /**
     * Optional render-only nudge (buffer-normalized). Prefer **raw MediaPipe** mesh ([GlPreviewRenderer] AR path)
     * before re-tuning; non-zero values distort global shape.
     */
    const val RENDER_LANDMARK_SHIFT_BUF_X = 0f
    const val RENDER_LANDMARK_SHIFT_BUF_Y = 0f
}
