package com.example.pixelfree_camera

/**
 * Flutter 侧美颜参数为 0..1（滑条 100% = 1.0），映射到与旧版 Flutter 在较低数值时的原生强度一致。
 */
internal object BeautyFlutterScale {
    /** Flutter 1.0 → 旧版 Flutter 传 0.36 时的磨皮强度 */
    const val SMOOTHING_FROM_FLUTTER: Float = 0.36f

    /** Flutter 1.0 → 旧版 Flutter 传 0.55 时的美白强度 */
    const val WHITENING_FROM_FLUTTER: Float = 0.55f

    /**
     * 亮眼：Flutter 滑条 0..1 线性映射到原生；**100% 时原生强度 = 旧版「全范围线性」下约 26/100 的效果**，
     * 避免再按 1.0 直通时过亮、夸张。
     */
    private const val EYE_BRIGHTEN_MAX_NATIVE: Float = 0.26f

    fun smoothingFromFlutter(n: Number?): Float = scale(n, SMOOTHING_FROM_FLUTTER)

    fun whiteningFromFlutter(n: Number?): Float = scale(n, WHITENING_FROM_FLUTTER)

    fun eyeBrightenFromFlutter(n: Number?): Float = scale(n, EYE_BRIGHTEN_MAX_NATIVE)

    /**
     * 瘦脸：Flutter 滑条 0..1 线性映射；**100% 时原生 `uSlimFace` = 0.38**（与旧版「直通约 38/100」相当），
     * 避免再按 1.0 直通时过夸张。
     */
    private const val SLIM_FACE_MAX_NATIVE: Float = 0.38f

    fun slimFaceFromFlutter(n: Number?): Float = scale(n, SLIM_FACE_MAX_NATIVE)

    /**
     * 瘦颧骨：Flutter 0..1 线性映射；**100% 时原生强度 = 旧版「直通约 50/100」**（0.5），避免再按 1.0 直通过夸张。
     */
    private const val FACE_NARROW_MAX_NATIVE: Float = 0.5f

    fun faceNarrowFromFlutter(n: Number?): Float = scale(n, FACE_NARROW_MAX_NATIVE)

    /**
     * 下巴：Flutter 0..1 线性映射；**100% 时原生强度 = 旧版「直通约 30/100」**（0.3），避免再按 1.0 直通过夸张。
     */
    private const val FACE_CHIN_MAX_NATIVE: Float = 0.3f

    fun faceChinFromFlutter(n: Number?): Float = scale(n, FACE_CHIN_MAX_NATIVE)

    private fun scale(n: Number?, factor: Float): Float {
        val v = (n?.toFloat() ?: 0f).coerceIn(0f, 1f)
        return (v * factor).coerceIn(0f, 1f)
    }
}
