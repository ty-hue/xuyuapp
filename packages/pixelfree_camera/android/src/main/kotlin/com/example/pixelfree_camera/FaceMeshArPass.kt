package com.example.pixelfree_camera

import android.opengl.GLES11Ext
import android.opengl.GLES20
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.hypot
import kotlin.math.min

/**
 * AR that **follows the MediaPipe face mesh**: each vertex is placed in NDC and samples the live
 * camera texture at the matching UV — tints multiply on triangles (not a flat screen-space sticker).
 *
 * Used for [MESH_DEFORM_AR_EFFECTS]; other effects stay on [ArEffectRenderer] overlays.
 */
internal class FaceMeshArPass {

    private data class MeshHandles(
        val program: Int,
        val pos: Int,
        val tex: Int,
        val sampler: Int,
        val mode: Int,
        val time: Int,
        val subjectMask: Int,
        val subjectReady: Int,
    )

    private var handlesOes: MeshHandles? = null
    private var handlesRgb: MeshHandles? = null
    private var startTimeMs = 0L

    /** Full mesh: 898 tris × 3 verts × 4 floats — rounded up. */
    private val tmpInterleaved = FloatArray(11000)

    fun init() {
        release()
        val pOes = buildProgram(MESH_AR_VS, MESH_AR_FS)
        handlesOes = meshHandles(pOes)
        val pRgb = buildProgram(MESH_AR_VS, MESH_AR_FS_RGB)
        handlesRgb = meshHandles(pRgb)
        startTimeMs = System.currentTimeMillis()
    }

    private fun meshHandles(program: Int) = MeshHandles(
        program = program,
        pos = GLES20.glGetAttribLocation(program, "aPosition"),
        tex = GLES20.glGetAttribLocation(program, "aTexCoord"),
        sampler = GLES20.glGetUniformLocation(program, "sTexture"),
        mode = GLES20.glGetUniformLocation(program, "uMode"),
        time = GLES20.glGetUniformLocation(program, "uTime"),
        subjectMask = GLES20.glGetUniformLocation(program, "uSubjectMask"),
        subjectReady = GLES20.glGetUniformLocation(program, "uSubjectReady"),
    )

    fun release() {
        handlesOes?.let { GLES20.glDeleteProgram(it.program) }
        handlesOes = null
        handlesRgb?.let { GLES20.glDeleteProgram(it.program) }
        handlesRgb = null
    }

    /**
     * @param toGl buffer (x,y) → NDC clip
     * @param toUv buffer (x,y) → texture UV (OES or [GL_TEXTURE_2D] depending on [cameraIsExternalOes])
     * @param cameraIsExternalOes false when sampling [GlPreviewRenderer] analysis RGB texture ([GL_TEXTURE_2D])
     */
    fun draw(
        effect: String,
        landmarks: FaceLandmarks,
        cameraTextureId: Int,
        toGl: (Float, Float) -> Pair<Float, Float>,
        toUv: (Float, Float) -> Pair<Float, Float>,
        subjectMaskTextureId: Int = 0,
        subjectMaskReady: Boolean = false,
        cameraIsExternalOes: Boolean = true,
    ) {
        val h = if (cameraIsExternalOes) handlesOes else handlesRgb
        if (h == null) return
        val tris = FaceMeshTesselation468.TRIANGLE_INDICES
        if (tris.isEmpty()) return

        var n = 0
        val noseY = landmarks.y(FaceLandmarks.NOSE_TIP)
        /** Below nose tip — avoids UPPER_LIP index 0 semantics differing across 468/478 models. */
        val beardFloorY = noseY + 0.02f
        val lcx = landmarks.x(FaceLandmarks.LEFT_CHEEK)
        val lcy = landmarks.y(FaceLandmarks.LEFT_CHEEK)
        val rcx = landmarks.x(FaceLandmarks.RIGHT_CHEEK)
        val rcy = landmarks.y(FaceLandmarks.RIGHT_CHEEK)

        fun pushTri(i0: Int, i1: Int, i2: Int) {
            for (idx in intArrayOf(i0, i1, i2)) {
                val x = landmarks.x(idx)
                val y = landmarks.y(idx)
                val (gx, gy) = toGl(x, y)
                val (u, v) = toUv(x, y)
                if (n + 4 > tmpInterleaved.size) return
                tmpInterleaved[n++] = gx
                tmpInterleaved[n++] = gy
                tmpInterleaved[n++] = u
                tmpInterleaved[n++] = v
            }
        }

        var mode = 0
        when (effect) {
            /**
             * Canonical template UV (TF.js [FaceMeshUv468]) linearly remapped into the current
             * face AABB in camera texture space — same idea as Juejin/Three.js UV + live video.
             */
            "face_mesh_uv" -> {
                mode = 5
                var minU = 1f
                var maxU = 0f
                var minV = 1f
                var maxV = 0f
                for (i in 0 until FaceMeshUv468.VERTEX_COUNT) {
                    val (u, v) = toUv(landmarks.x(i), landmarks.y(i))
                    if (u < minU) minU = u
                    if (u > maxU) maxU = u
                    if (v < minV) minV = v
                    if (v > maxV) maxV = v
                }
                val padU = (maxU - minU) * 0.05f + 0.012f
                val padV = (maxV - minV) * 0.05f + 0.012f
                minU = (minU - padU).coerceIn(0f, 1f)
                maxU = (maxU + padU).coerceIn(0f, 1f)
                minV = (minV - padV).coerceIn(0f, 1f)
                maxV = (maxV + padV).coerceIn(0f, 1f)
                val du = FaceMeshUv468.CANON_U_MAX - FaceMeshUv468.CANON_U_MIN
                val dv = FaceMeshUv468.CANON_V_MAX - FaceMeshUv468.CANON_V_MIN
                val invDu = if (du > 1e-6f) 1f / du else 1f
                val invDv = if (dv > 1e-6f) 1f / dv else 1f
                fun pushTriAtlas(i0: Int, i1: Int, i2: Int) {
                    for (idx in intArrayOf(i0, i1, i2)) {
                        val (gx, gy) = toGl(landmarks.x(idx), landmarks.y(idx))
                        val uc = 1f - FaceMeshUv468.u(idx)
                        val vc = FaceMeshUv468.v(idx)
                        val uN = ((uc - FaceMeshUv468.CANON_U_MIN) * invDu).coerceIn(0f, 1f)
                        val vN = ((vc - FaceMeshUv468.CANON_V_MIN) * invDv).coerceIn(0f, 1f)
                        val texU = minU + uN * (maxU - minU)
                        val texV = minV + vN * (maxV - minV)
                        if (n + 4 > tmpInterleaved.size) return
                        tmpInterleaved[n++] = gx
                        tmpInterleaved[n++] = gy
                        tmpInterleaved[n++] = texU
                        tmpInterleaved[n++] = texV
                    }
                }
                for (t in tris.indices step 3) {
                    pushTriAtlas(tris[t], tris[t + 1], tris[t + 2])
                }
            }
            "face_paint" -> {
                mode = 0
                for (t in tris.indices step 3) {
                    pushTri(tris[t], tris[t + 1], tris[t + 2])
                }
            }
            "green_hair" -> {
                mode = 1
                for (t in tris.indices step 3) {
                    val i0 = tris[t]
                    val i1 = tris[t + 1]
                    val i2 = tris[t + 2]
                    val cy = (landmarks.y(i0) + landmarks.y(i1) + landmarks.y(i2)) / 3f
                    if (cy < noseY - 0.012f) pushTri(i0, i1, i2)
                }
            }
            "dense_beard" -> {
                mode = 2
                for (t in tris.indices step 3) {
                    val i0 = tris[t]
                    val i1 = tris[t + 1]
                    val i2 = tris[t + 2]
                    val cy = (landmarks.y(i0) + landmarks.y(i1) + landmarks.y(i2)) / 3f
                    if (cy > beardFloorY) pushTri(i0, i1, i2)
                }
            }
            "puffy_face" -> {
                mode = 3
                for (t in tris.indices step 3) {
                    val i0 = tris[t]
                    val i1 = tris[t + 1]
                    val i2 = tris[t + 2]
                    val cx = (landmarks.x(i0) + landmarks.x(i1) + landmarks.x(i2)) / 3f
                    val cy = (landmarks.y(i0) + landmarks.y(i1) + landmarks.y(i2)) / 3f
                    val dL = hypot(cx - lcx, cy - lcy)
                    val dR = hypot(cx - rcx, cy - rcy)
                    if (min(dL, dR) < 0.15f) pushTri(i0, i1, i2)
                }
            }
            else -> return
        }

        if (n < 9) return

        val buf = ByteBuffer.allocateDirect(n * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()
        buf.put(tmpInterleaved, 0, n)
        buf.position(0)

        val time = ((System.currentTimeMillis() - startTimeMs) % 200_000L) / 1000f

        GLES20.glUseProgram(h.program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        if (cameraIsExternalOes) {
            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, cameraTextureId)
        } else {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, cameraTextureId)
        }
        if (h.sampler >= 0) GLES20.glUniform1i(h.sampler, 0)
        val subjReady = effect == "green_hair" && subjectMaskReady && subjectMaskTextureId != 0
        GLES20.glActiveTexture(GLES20.GL_TEXTURE2)
        GLES20.glBindTexture(
            GLES20.GL_TEXTURE_2D,
            if (subjReady) subjectMaskTextureId else 0,
        )
        if (h.subjectMask >= 0) GLES20.glUniform1i(h.subjectMask, 2)
        if (h.subjectReady >= 0) {
            GLES20.glUniform1f(h.subjectReady, if (subjReady) 1f else 0f)
        }
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        if (h.mode >= 0) GLES20.glUniform1i(h.mode, mode)
        if (h.time >= 0) GLES20.glUniform1f(h.time, time)

        val stride = 16
        GLES20.glVertexAttribPointer(h.pos, 2, GLES20.GL_FLOAT, false, stride, buf)
        GLES20.glEnableVertexAttribArray(h.pos)
        buf.position(2)
        GLES20.glVertexAttribPointer(h.tex, 2, GLES20.GL_FLOAT, false, stride, buf)
        GLES20.glEnableVertexAttribArray(h.tex)

        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, n / 4)

        GLES20.glDisableVertexAttribArray(h.pos)
        GLES20.glDisableVertexAttribArray(h.tex)
        GLES20.glDisable(GLES20.GL_BLEND)
    }

    private fun buildProgram(vs: String, fs: String): Int {
        val v = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER).also {
            GLES20.glShaderSource(it, vs)
            GLES20.glCompileShader(it)
        }
        val f = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER).also {
            GLES20.glShaderSource(it, fs)
            GLES20.glCompileShader(it)
        }
        return GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, v)
            GLES20.glAttachShader(it, f)
            GLES20.glLinkProgram(it)
            GLES20.glDeleteShader(v)
            GLES20.glDeleteShader(f)
        }
    }

    companion object {
        val MESH_DEFORM_AR_EFFECTS = setOf(
            "face_mesh_uv",
            "face_paint",
            "green_hair",
            "dense_beard",
            "puffy_face",
        )

        private const val MESH_AR_VS = """
            attribute vec2 aPosition;
            attribute vec2 aTexCoord;
            varying vec2 vTexCoord;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                vTexCoord = aTexCoord;
            }
        """
        private const val MESH_AR_FS = """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            varying vec2 vTexCoord;
            uniform samplerExternalOES sTexture;
            uniform sampler2D uSubjectMask;
            uniform float uSubjectReady;
            uniform int uMode;
            uniform float uTime;
            void main() {
                vec4 tex = texture2D(sTexture, vTexCoord);
                if (uMode == 5) {
                    gl_FragColor = vec4(tex.rgb * vec3(0.9, 0.96, 1.04), 0.52);
                } else {
                    vec3 rgb = tex.rgb;
                    if (uMode == 0) {
                        float t = uTime * 0.5;
                        vec3 tint = vec3(
                            0.5 + 0.5 * sin(t),
                            0.5 + 0.5 * sin(t + 2.09),
                            0.5 + 0.5 * sin(t + 4.19)
                        );
                        rgb = mix(rgb, rgb * tint, 0.38);
                    } else if (uMode == 1) {
                        float tintAmt = 0.52;
                        if (uSubjectReady > 0.5) {
                            float sm = texture2D(uSubjectMask, vTexCoord).r;
                            tintAmt *= mix(0.38, 1.0, smoothstep(0.18, 0.72, sm));
                        }
                        rgb = mix(rgb, rgb * vec3(0.32, 1.12, 0.42), tintAmt);
                    } else if (uMode == 2) {
                        vec3 br = vec3(0.22, 0.12, 0.08);
                        rgb = mix(rgb, rgb * br * 2.1, 0.62);
                    } else if (uMode == 3) {
                        vec3 pk = vec3(1.0, 0.78, 0.82);
                        rgb = mix(rgb, mix(rgb, pk, 0.35), 0.42);
                    }
                    gl_FragColor = vec4(rgb, tex.a);
                }
            }
        """
        /** Same as [MESH_AR_FS] but [sampler2D] for analysis-frame [GL_TEXTURE_2D] (time-aligned with landmarks). */
        private const val MESH_AR_FS_RGB = """
            precision mediump float;
            varying vec2 vTexCoord;
            uniform sampler2D sTexture;
            uniform sampler2D uSubjectMask;
            uniform float uSubjectReady;
            uniform int uMode;
            uniform float uTime;
            void main() {
                vec4 tex = texture2D(sTexture, vTexCoord);
                if (uMode == 5) {
                    gl_FragColor = vec4(tex.rgb * vec3(0.9, 0.96, 1.04), 0.52);
                } else {
                    vec3 rgb = tex.rgb;
                    if (uMode == 0) {
                        float t = uTime * 0.5;
                        vec3 tint = vec3(
                            0.5 + 0.5 * sin(t),
                            0.5 + 0.5 * sin(t + 2.09),
                            0.5 + 0.5 * sin(t + 4.19)
                        );
                        rgb = mix(rgb, rgb * tint, 0.38);
                    } else if (uMode == 1) {
                        float tintAmt = 0.52;
                        if (uSubjectReady > 0.5) {
                            float sm = texture2D(uSubjectMask, vTexCoord).r;
                            tintAmt *= mix(0.38, 1.0, smoothstep(0.18, 0.72, sm));
                        }
                        rgb = mix(rgb, rgb * vec3(0.32, 1.12, 0.42), tintAmt);
                    } else if (uMode == 2) {
                        vec3 br = vec3(0.22, 0.12, 0.08);
                        rgb = mix(rgb, rgb * br * 2.1, 0.62);
                    } else if (uMode == 3) {
                        vec3 pk = vec3(1.0, 0.78, 0.82);
                        rgb = mix(rgb, mix(rgb, pk, 0.35), 0.42);
                    }
                    gl_FragColor = vec4(rgb, tex.a);
                }
            }
        """
    }
}
