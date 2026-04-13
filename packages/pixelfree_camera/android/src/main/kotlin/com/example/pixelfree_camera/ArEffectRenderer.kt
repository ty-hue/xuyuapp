package com.example.pixelfree_camera

import android.opengl.GLES20
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/**
 * Base class for all AR effect renderers.
 * Each effect draws on top of the camera quad using predicted face landmarks.
 */
internal abstract class ArEffectRenderer {
    abstract fun init()
    abstract fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int)
    abstract fun release()

    protected fun buildProgram(vs: String, fs: String): Int {
        val v = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER).also {
            GLES20.glShaderSource(it, vs); GLES20.glCompileShader(it)
        }
        val f = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER).also {
            GLES20.glShaderSource(it, fs); GLES20.glCompileShader(it)
        }
        return GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, v); GLES20.glAttachShader(it, f)
            GLES20.glLinkProgram(it)
            GLES20.glDeleteShader(v); GLES20.glDeleteShader(f)
        }
    }

    protected fun allocBuf(data: FloatArray): FloatBuffer =
        ByteBuffer.allocateDirect(data.size * 4).order(ByteOrder.nativeOrder())
            .asFloatBuffer().apply { put(data); position(0) }

    companion object {
        val AVAILABLE_EFFECTS = listOf(
            "none",
            "face_landmarks",  // 468 red dots — MediaPipe-style landmark debug (indices 0..467)
            "face_mesh",       // Wireframe only (2D/NDC lines)
            "face_mesh_uv",    // TF.js UV atlas + camera tex (FaceMeshArPass) + wireframe overlay
            "face_paint",      // Color face mask / face paint
            "big_eye",         // Big eye deformation
            "slim_face",       // Slim face deformation
            "heart_particles", // Heart particles from face
            "star_particles",  // Star particles falling
            "laser_eyes",      // Laser beams from irises
            "rainbow_tears",   // Rainbow streaks from eyes
            "dense_beard",     // Bushy beard on jaw
            "sharingan_eyes",  // Anime Mangekyō-style iris overlay
            "green_hair",      // Green tint on hair / top of head
            "puffy_face",      // Inflated / chubby cheeks
            "pig_nose",        // Cartoon pig snout on nose tip
        )

        fun create(name: String): ArEffectRenderer? = when (name) {
            "face_landmarks" -> FaceLandmarks468PointsEffect()
            "face_mesh" -> FaceMeshEffect()
            // face_paint, dense_beard, green_hair, puffy_face → [FaceMeshArPass] mesh + camera texture
            "laser_eyes" -> LaserEyesEffect()
            "heart_particles" -> HeartParticleEffect()
            "star_particles" -> StarParticleEffect()
            "rainbow_tears" -> RainbowTearsEffect()
            "sharingan_eyes" -> SharinganEyesEffect()
            "pig_nose" -> PigNoseEffect()
            else -> null
        }

        /** NDC ellipse triangle fan for AR overlays (center + rim + close). */
        fun ellipseFanNd(cx: Float, cy: Float, rx: Float, ry: Float, n: Int): FloatArray {
            val out = FloatArray((n + 2) * 2)
            out[0] = cx
            out[1] = cy
            val step = (2.0 * PI / n).toFloat()
            for (i in 0 until n) {
                val t = step * i
                out[(i + 1) * 2] = cx + rx * cos(t)
                out[(i + 1) * 2 + 1] = cy + ry * sin(t)
            }
            out[(n + 1) * 2] = out[2]
            out[(n + 1) * 2 + 1] = out[3]
            return out
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Effect 1: Face Mesh — Neon wireframe overlay on the face
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class FaceMeshEffect : ArEffectRenderer() {
    private var program = 0
    private var posHandle = 0
    private var colorHandle = 0

    override fun init() {
        program = buildProgram(MESH_VS, MESH_FS)
        posHandle = GLES20.glGetAttribLocation(program, "aPosition")
        colorHandle = GLES20.glGetUniformLocation(program, "uColor")
    }

    /**
     * TF.js `TRIANGULATION` 去重边 + GL_LINES；顶点 NDC 与全屏预览 `vTexCoord` 一致（见 [GlPreviewRenderer.landmarkToGl]）。
     *
     * 只用缓冲归一化 (x,y)→NDC；[FaceLandmarks] 里的 **z 不参与绘制**，因此这是贴在当前帧纹理上的 **2D 网格**，
     * 不是带透视投影的刚性 3D 面具。左右转头（大 yaw）时，模型仍在「图像平面」上贴合，和真实 3D 透视会有视觉差。
     */
    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glLineWidth(1.5f)

        val lines = FaceMeshTesselation468.WIREFRAME_LINE_INDICES
        val verts = FloatArray(lines.size * 2)
        for (i in lines.indices) {
            val idx = lines[i]
            val (gx, gy) = toGl(landmarks.x(idx), landmarks.y(idx))
            verts[i * 2] = gx
            verts[i * 2 + 1] = gy
        }
        val buf = allocBuf(verts)
        GLES20.glUniform4f(colorHandle, 0.2f, 0.78f, 1f, 0.72f)
        GLES20.glVertexAttribPointer(posHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
        GLES20.glEnableVertexAttribArray(posHandle)
        GLES20.glDrawArrays(GLES20.GL_LINES, 0, lines.size)

        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (program != 0) GLES20.glDeleteProgram(program); program = 0
    }

    companion object {
        private const val MESH_VS = """
            attribute vec2 aPosition;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
            }
        """
        private const val MESH_FS = """
            precision mediump float;
            uniform vec4 uColor;
            void main() {
                gl_FragColor = uColor;
            }
        """
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Face mesh vertices 0..467 as red points (tutorial-style landmark overlay)
// (2D only — z unused; see [FaceMeshEffect.draw] KDoc.)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class FaceLandmarks468PointsEffect : ArEffectRenderer() {
    private var program = 0
    private var posHandle = 0
    private var colorHandle = 0
    private var pointSizeHandle = 0

    override fun init() {
        program = buildProgram(LM468_VS, LM468_FS)
        posHandle = GLES20.glGetAttribLocation(program, "aPosition")
        colorHandle = GLES20.glGetUniformLocation(program, "uColor")
        pointSizeHandle = GLES20.glGetUniformLocation(program, "uPointSize")
    }

    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        val vw = viewW.coerceAtLeast(1)
        val vh = viewH.coerceAtLeast(1)
        val verts = FloatArray(FACE_MESH_VERTS * 2)
        for (i in 0 until FACE_MESH_VERTS) {
            val (gx, gy) = toGl(landmarks.x(i), landmarks.y(i))
            verts[i * 2] = gx
            verts[i * 2 + 1] = gy
        }
        val buf = allocBuf(verts)
        // Larger sprites so 468 vertices read as dense field (many cheek/forehead points sit close in screen space).
        val ptPx = max(5f, min(vw, vh) * 0.018f).coerceAtMost(22f)

        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glUniform4f(colorHandle, 1f, 0.08f, 0.12f, 0.92f)
        GLES20.glUniform1f(pointSizeHandle, ptPx)
        GLES20.glVertexAttribPointer(posHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
        GLES20.glEnableVertexAttribArray(posHandle)
        GLES20.glDrawArrays(GLES20.GL_POINTS, 0, FACE_MESH_VERTS)
        GLES20.glDisableVertexAttribArray(posHandle)
        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (program != 0) GLES20.glDeleteProgram(program)
        program = 0
    }

    companion object {
        /** MediaPipe face mesh topology uses 468 vertices (0..467); iris/refine adds more indices in [FaceLandmarks]. */
        private const val FACE_MESH_VERTS = 468

        private const val LM468_VS = """
            attribute vec2 aPosition;
            uniform float uPointSize;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                gl_PointSize = uPointSize;
            }
        """
        private const val LM468_FS = """
            precision mediump float;
            uniform vec4 uColor;
            void main() {
                vec2 q = gl_PointCoord * 2.0 - 1.0;
                float d = length(q);
                if (d > 1.0) discard;
                float a = uColor.a * (1.0 - smoothstep(0.75, 1.0, d));
                gl_FragColor = vec4(uColor.rgb, a);
            }
        """
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Effect 2: Laser Eyes
// Product: two detections (left/right iris rings) → two glows; each centered on that eye’s coords,
// sized from eyelid contour so it covers the opening; every frame uses latest landmark mesh.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class LaserEyesEffect : ArEffectRenderer() {
    private var bulbProgram = 0
    private var bulbPosHandle = 0
    private var bulbCenterHandle = 0
    private var bulbRadiusHandle = 0
    private var bulbTimeHandle = 0
    private var bulbAlphaMulHandle = 0

    private var beamProgram = 0
    private var beamPosHandle = 0
    private var beamAttHandle = 0
    private var beamTimeHandle = 0
    private var beamBoostHandle = 0

    private var startTimeMs = 0L

    override fun init() {
        bulbProgram = buildProgram(BULB_VS, BULB_FS)
        bulbPosHandle = GLES20.glGetAttribLocation(bulbProgram, "aPosition")
        bulbCenterHandle = GLES20.glGetUniformLocation(bulbProgram, "uCenter")
        bulbRadiusHandle = GLES20.glGetUniformLocation(bulbProgram, "uRadius")
        bulbTimeHandle = GLES20.glGetUniformLocation(bulbProgram, "uTime")
        bulbAlphaMulHandle = GLES20.glGetUniformLocation(bulbProgram, "uAlphaMul")

        beamProgram = buildProgram(LASER_VS, LASER_FS)
        beamPosHandle = GLES20.glGetAttribLocation(beamProgram, "aPosition")
        beamAttHandle = GLES20.glGetAttribLocation(beamProgram, "aBeam")
        beamTimeHandle = GLES20.glGetUniformLocation(beamProgram, "uTime")
        beamBoostHandle = GLES20.glGetUniformLocation(beamProgram, "uGlowBoost")
        startTimeMs = System.currentTimeMillis()
    }

    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        val time = ((System.currentTimeMillis() - startTimeMs) % 10000) / 1000f
        val aw = viewW.coerceAtLeast(1).toFloat()
        val ah = viewH.coerceAtLeast(1).toFloat()

        val (nx, ny) = toGl(landmarks.x(FaceLandmarks.NOSE_TIP), landmarks.y(FaceLandmarks.NOSE_TIP))

        val leftRegion = landmarks.eyeRegionForLaser(leftEye = true)
        val rightRegion = landmarks.eyeRegionForLaser(leftEye = false)
        val eyeRegions = listOf(leftRegion, rightRegion)

        GLES20.glEnable(GLES20.GL_BLEND)

        // 1) Eye “bulbs” + bloom: hide real eyes (high alpha center), soft pink rim
        GLES20.glUseProgram(bulbProgram)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        if (bulbTimeHandle >= 0) GLES20.glUniform1f(bulbTimeHandle, time)

        for (region in eyeRegions) {
            val (cx, cy) = toGl(region.cx, region.cy)
            // Pixel radius from eye bbox; NDC radii must satisfy rx*aw ≈ ry*ah or the disk becomes a tall bar on portrait screens.
            // Radius from eyelid bbox so the disk covers the open eye; bloom rings extend past rim.
            val rPx = (0.78f * max(region.halfW * aw, region.halfH * ah)).coerceIn(16f, ah * 0.28f)
            val rx = 2f * rPx / aw
            val ry = 2f * rPx / ah

            val bloom = listOf(
                Pair(1.32f, 0.42f),
                Pair(1.08f, 0.78f),
                Pair(1f, 1f),
            )
            for ((scale, alphaMul) in bloom) {
                val fan = ellipseFan(cx, cy, rx * scale, ry * scale, 48)
                val buf = allocBuf(fan)
                GLES20.glUniform2f(bulbCenterHandle, cx, cy)
                GLES20.glUniform2f(bulbRadiusHandle, rx * scale, ry * scale)
                if (bulbAlphaMulHandle >= 0) GLES20.glUniform1f(bulbAlphaMulHandle, alphaMul)
                GLES20.glVertexAttribPointer(bulbPosHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
                GLES20.glEnableVertexAttribArray(bulbPosHandle)
                GLES20.glDrawArrays(GLES20.GL_TRIANGLE_FAN, 0, fan.size / 2)
                GLES20.glDisableVertexAttribArray(bulbPosHandle)
            }
        }

        // 2) Beams: nose → iris direction (left / up-left, right / up-right), additive glow
        GLES20.glUseProgram(beamProgram)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE)
        if (beamTimeHandle >= 0) GLES20.glUniform1f(beamTimeHandle, time)

        val beamLen = 1.42f
        // Wider in NDC so the beam isn’t a hairline after aspect; scaled ~ with viewport.
        val awf = max(aw, 1f)
        val ahf = max(ah, 1f)
        val wScale = 2f * ahf / (awf + ahf)
        val passes = listOf(
            Triple(0.038f * wScale, 0.12f * wScale, 0.32f),
            Triple(0.022f * wScale, 0.07f * wScale, 0.72f),
            Triple(0.013f * wScale, 0.042f * wScale, 1.05f),
        )

        for (region in eyeRegions) {
            val (ex, ey) = toGl(region.cx, region.cy)
            var bx = ex - nx
            var by = ey - ny
            val bl = hypot(bx, by).coerceAtLeast(1e-5f)
            bx /= bl
            by /= bl
            val px = -by
            val py = bx

            for ((w0, w1, boost) in passes) {
                val (pos, beam) = beamQuadSplit(ex, ey, bx, by, px, py, beamLen, w0, w1)
                val posBuf = allocBuf(pos)
                val beamBuf = allocBuf(beam)
                GLES20.glVertexAttribPointer(beamPosHandle, 2, GLES20.GL_FLOAT, false, 0, posBuf)
                GLES20.glEnableVertexAttribArray(beamPosHandle)
                if (beamAttHandle >= 0) {
                    GLES20.glVertexAttribPointer(beamAttHandle, 2, GLES20.GL_FLOAT, false, 0, beamBuf)
                    GLES20.glEnableVertexAttribArray(beamAttHandle)
                }
                if (beamBoostHandle >= 0) GLES20.glUniform1f(beamBoostHandle, boost)
                GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
                if (beamAttHandle >= 0) GLES20.glDisableVertexAttribArray(beamAttHandle)
                GLES20.glDisableVertexAttribArray(beamPosHandle)
            }
        }

        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (bulbProgram != 0) GLES20.glDeleteProgram(bulbProgram)
        bulbProgram = 0
        if (beamProgram != 0) GLES20.glDeleteProgram(beamProgram)
        beamProgram = 0
    }

    companion object {
        private fun ellipseFan(cx: Float, cy: Float, rx: Float, ry: Float, n: Int): FloatArray {
            val out = FloatArray((n + 2) * 2)
            out[0] = cx
            out[1] = cy
            val step = (2.0 * PI / n).toFloat()
            for (i in 0 until n) {
                val t = step * i
                out[(i + 1) * 2] = cx + rx * cos(t)
                out[(i + 1) * 2 + 1] = cy + ry * sin(t)
            }
            out[(n + 1) * 2] = out[2]
            out[(n + 1) * 2 + 1] = out[3]
            return out
        }

        private fun beamQuadSplit(
            ex: Float, ey: Float,
            dx: Float, dy: Float,
            px: Float, py: Float,
            len: Float,
            w0: Float, w1: Float,
        ): Pair<FloatArray, FloatArray> {
            val ex2 = ex + dx * len
            val ey2 = ey + dy * len
            val pos = floatArrayOf(
                ex - px * w0, ey - py * w0,
                ex + px * w0, ey + py * w0,
                ex2 - px * w1, ey2 - py * w1,
                ex2 + px * w1, ey2 + py * w1,
            )
            val beam = floatArrayOf(-1f, 0f, 1f, 0f, -1f, 1f, 1f, 1f)
            return Pair(pos, beam)
        }

        private const val BULB_VS = """
            attribute vec2 aPosition;
            uniform vec2 uCenter;
            uniform vec2 uRadius;
            varying vec2 vRel;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                vRel = vec2(
                    (aPosition.x - uCenter.x) / max(uRadius.x, 0.0005),
                    (aPosition.y - uCenter.y) / max(uRadius.y, 0.0005)
                );
            }
        """
        private const val BULB_FS = """
            precision mediump float;
            varying vec2 vRel;
            uniform float uTime;
            uniform float uAlphaMul;
            void main() {
                float e = length(vRel);
                float pulse = 0.92 + 0.08 * sin(uTime * 10.0);
                float mid = smoothstep(0.35, 0.78, e);
                vec3 c0 = vec3(1.0, 1.0, 0.96);
                vec3 c1 = vec3(1.0, 0.82, 0.35);
                vec3 c2 = vec3(1.0, 0.45, 0.42);
                vec3 col = mix(c0, c1, smoothstep(0.12, 0.52, e));
                col = mix(col, c2, mid);
                float a = (1.0 - smoothstep(0.4, 1.02, e)) * 0.98;
                gl_FragColor = vec4(col * pulse, a * uAlphaMul);
            }
        """

        private const val LASER_VS = """
            attribute vec2 aPosition;
            attribute vec2 aBeam;
            varying vec2 vBeam;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                vBeam = aBeam;
            }
        """
        private const val LASER_FS = """
            precision mediump float;
            varying vec2 vBeam;
            uniform float uTime;
            uniform float uGlowBoost;
            void main() {
                float ax = abs(vBeam.x);
                float along = vBeam.y;
                float pulse = 0.9 + 0.1 * sin(uTime * 16.0);
                float edge = pow(max(0.0, 1.0 - ax), 3.5);
                float coreLine = smoothstep(0.45, 0.0, ax) * smoothstep(0.2, 0.0, along);
                float lenFade = 1.0 - smoothstep(0.68, 1.0, along);
                vec3 white = vec3(1.0, 1.0, 0.95);
                vec3 yellow = vec3(1.0, 0.72, 0.15);
                vec3 orange = vec3(1.0, 0.38, 0.12);
                vec3 pink = vec3(1.0, 0.28, 0.42);
                float t = ax;
                vec3 col = mix(white, yellow, smoothstep(0.0, 0.22, t));
                col = mix(col, orange, smoothstep(0.22, 0.55, t));
                col = mix(col, pink, smoothstep(0.55, 1.0, t));
                col *= pulse * uGlowBoost;
                col += white * coreLine * 0.85 * uGlowBoost;
                float alpha = edge * lenFade * (0.4 + 0.6 * edge) * uGlowBoost;
                alpha = min(1.0, alpha + coreLine * 0.9 * uGlowBoost);
                gl_FragColor = vec4(col, clamp(alpha, 0.0, 1.0));
            }
        """
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Effect 4: Heart Particles — Hearts rising from face
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class HeartParticleEffect : ArEffectRenderer() {
    private var program = 0
    private var posHandle = 0
    private var colorHandle = 0
    private var pointSizeHandle = 0
    private var startTimeMs = 0L
    private val particleCount = 20
    private val particleSeeds = FloatArray(particleCount * 3).also { arr ->
        val rng = java.util.Random(42)
        for (i in arr.indices) arr[i] = rng.nextFloat()
    }

    override fun init() {
        program = buildProgram(PARTICLE_VS, PARTICLE_FS)
        posHandle = GLES20.glGetAttribLocation(program, "aPosition")
        colorHandle = GLES20.glGetUniformLocation(program, "uColor")
        pointSizeHandle = GLES20.glGetUniformLocation(program, "uPointSize")
        startTimeMs = System.currentTimeMillis()
    }

    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)

        val time = ((System.currentTimeMillis() - startTimeMs) % 8000) / 1000f
        val (faceCx, faceCy) = toGl(landmarks.x(FaceLandmarks.NOSE_TIP), landmarks.y(FaceLandmarks.NOSE_TIP))
        val faceW = landmarks.faceWidth()

        val verts = FloatArray(particleCount * 2)
        for (i in 0 until particleCount) {
            val seed0 = particleSeeds[i * 3]
            val seed1 = particleSeeds[i * 3 + 1]
            val seed2 = particleSeeds[i * 3 + 2]
            val phase = (time + seed0 * 8f) % 4f
            val t = phase / 4f
            val x = faceCx + (seed1 - 0.5f) * faceW * 3f + kotlin.math.sin((time + seed0 * 10f).toDouble()).toFloat() * 0.08f
            val y = faceCy + t * 1.5f
            verts[i * 2] = x; verts[i * 2 + 1] = y
        }
        val buf = allocBuf(verts)

        GLES20.glUniform4f(colorHandle, 1f, 0.2f, 0.4f, 0.85f)
        GLES20.glUniform1f(pointSizeHandle, 24f)
        GLES20.glVertexAttribPointer(posHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
        GLES20.glEnableVertexAttribArray(posHandle)
        GLES20.glDrawArrays(GLES20.GL_POINTS, 0, particleCount)

        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (program != 0) GLES20.glDeleteProgram(program); program = 0
    }

    companion object {
        private const val PARTICLE_VS = """
            attribute vec2 aPosition;
            uniform float uPointSize;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                gl_PointSize = uPointSize;
            }
        """
        private const val PARTICLE_FS = """
            precision mediump float;
            uniform vec4 uColor;
            void main() {
                vec2 p = gl_PointCoord * 2.0 - 1.0;
                // Heart shape SDF
                float x = p.x;
                float y = -p.y + 0.3;
                float a = x * x + y * y - 1.0;
                float heart = a * a * a - x * x * y * y * y;
                if (heart > 0.0) discard;
                gl_FragColor = uColor;
            }
        """
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Star Particles — Diamonds / stars drifting upward
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class StarParticleEffect : ArEffectRenderer() {
    private var program = 0
    private var posHandle = 0
    private var colorHandle = 0
    private var pointSizeHandle = 0
    private var startTimeMs = 0L
    private val particleCount = 28
    private val particleSeeds = FloatArray(particleCount * 3).also { arr ->
        val rng = java.util.Random(7)
        for (i in arr.indices) arr[i] = rng.nextFloat()
    }

    override fun init() {
        program = buildProgram(STAR_PARTICLE_VS, STAR_PARTICLE_FS)
        posHandle = GLES20.glGetAttribLocation(program, "aPosition")
        colorHandle = GLES20.glGetUniformLocation(program, "uColor")
        pointSizeHandle = GLES20.glGetUniformLocation(program, "uPointSize")
        startTimeMs = System.currentTimeMillis()
    }

    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)

        val time = ((System.currentTimeMillis() - startTimeMs) % 10000) / 1000f
        val (faceCx, faceCy) = toGl(landmarks.x(FaceLandmarks.NOSE_TIP), landmarks.y(FaceLandmarks.NOSE_TIP))
        val faceW = landmarks.faceWidth()

        val verts = FloatArray(particleCount * 2)
        for (i in 0 until particleCount) {
            val seed0 = particleSeeds[i * 3]
            val seed1 = particleSeeds[i * 3 + 1]
            val phase = (time * 1.2f + seed0 * 10f) % 5f
            val t = phase / 5f
            val x = faceCx + (seed1 - 0.5f) * faceW * 2.8f + kotlin.math.cos((time * 2f + i).toDouble()).toFloat() * 0.06f
            val y = faceCy - 0.2f + t * 1.8f
            verts[i * 2] = x
            verts[i * 2 + 1] = y
        }
        val buf = allocBuf(verts)

        GLES20.glUniform4f(colorHandle, 1f, 0.95f, 0.35f, 0.88f)
        GLES20.glUniform1f(pointSizeHandle, 20f)
        GLES20.glVertexAttribPointer(posHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
        GLES20.glEnableVertexAttribArray(posHandle)
        GLES20.glDrawArrays(GLES20.GL_POINTS, 0, particleCount)

        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (program != 0) GLES20.glDeleteProgram(program)
        program = 0
    }

    companion object {
        private const val STAR_PARTICLE_VS = """
            attribute vec2 aPosition;
            uniform float uPointSize;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                gl_PointSize = uPointSize;
            }
        """
        private const val STAR_PARTICLE_FS = """
            precision mediump float;
            uniform vec4 uColor;
            void main() {
                vec2 p = gl_PointCoord * 2.0 - 1.0;
                if (abs(p.x) + abs(p.y) > 0.92) discard;
                gl_FragColor = uColor;
            }
        """
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Effect 5: Rainbow Tears — Colorful streaks flowing from eyes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class RainbowTearsEffect : ArEffectRenderer() {
    private var program = 0
    private var posHandle = 0
    private var colorHandle = 0
    private var startTimeMs = 0L

    override fun init() {
        program = buildProgram(TEAR_VS, TEAR_FS)
        posHandle = GLES20.glGetAttribLocation(program, "aPosition")
        colorHandle = GLES20.glGetUniformLocation(program, "uColor")
        startTimeMs = System.currentTimeMillis()
    }

    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)

        val time = ((System.currentTimeMillis() - startTimeMs) % 10000) / 1000f
        val faceH = landmarks.faceHeight()

        val rainbowColors = arrayOf(
            floatArrayOf(1f, 0f, 0f, 0.7f),
            floatArrayOf(1f, 0.5f, 0f, 0.7f),
            floatArrayOf(1f, 1f, 0f, 0.7f),
            floatArrayOf(0f, 1f, 0f, 0.7f),
            floatArrayOf(0f, 0.5f, 1f, 0.7f),
            floatArrayOf(0.3f, 0f, 1f, 0.7f),
        )

        val leftEye = landmarks.leftIrisCenterNorm()
        val rightEye = landmarks.rightIrisCenterNorm()
        for ((exn, eyn) in listOf(leftEye, rightEye)) {
            val (ex, ey) = toGl(exn, eyn)

            for (stripIdx in rainbowColors.indices) {
                val stripOffset = (stripIdx - rainbowColors.size / 2f) * 0.012f
                val numSegments = 12
                val verts = FloatArray(numSegments * 2)
                for (s in 0 until numSegments) {
                    val t = s.toFloat() / (numSegments - 1)
                    val flow = (time * 0.5f + t) % 1f
                    verts[s * 2] = ex + stripOffset + kotlin.math.sin((t * 3f + time).toDouble()).toFloat() * 0.01f
                    verts[s * 2 + 1] = ey - t * faceH * 2f
                }
                val buf = allocBuf(verts)
                val c = rainbowColors[stripIdx]
                GLES20.glUniform4fv(colorHandle, 1, c, 0)
                GLES20.glLineWidth(4f)
                GLES20.glVertexAttribPointer(posHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
                GLES20.glEnableVertexAttribArray(posHandle)
                GLES20.glDrawArrays(GLES20.GL_LINE_STRIP, 0, numSegments)
            }
        }

        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (program != 0) GLES20.glDeleteProgram(program); program = 0
    }

    companion object {
        private const val TEAR_VS = """
            attribute vec2 aPosition;
            void main() { gl_Position = vec4(aPosition, 0.0, 1.0); }
        """
        private const val TEAR_FS = """
            precision mediump float;
            uniform vec4 uColor;
            void main() { gl_FragColor = uColor; }
        """
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Sharingan-style iris overlay (three tomoe + rings, rotates)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class SharinganEyesEffect : ArEffectRenderer() {
    private var program = 0
    private var posHandle = 0
    private var centerHandle = 0
    private var radiusHandle = 0
    private var timeHandle = 0
    private var startTimeMs = 0L

    override fun init() {
        program = buildProgram(SH_VS, SH_FS)
        posHandle = GLES20.glGetAttribLocation(program, "aPosition")
        centerHandle = GLES20.glGetUniformLocation(program, "uCenter")
        radiusHandle = GLES20.glGetUniformLocation(program, "uRadius")
        timeHandle = GLES20.glGetUniformLocation(program, "uTime")
        startTimeMs = System.currentTimeMillis()
    }

    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        val aw = viewW.coerceAtLeast(1).toFloat()
        val ah = viewH.coerceAtLeast(1).toFloat()
        val time = ((System.currentTimeMillis() - startTimeMs) % 100_000L) / 1000f

        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        if (timeHandle >= 0) GLES20.glUniform1f(timeHandle, time)

        for (left in listOf(true, false)) {
            val region = landmarks.eyeRegionForLaser(left)
            val (cx, cy) = toGl(region.cx, region.cy)
            val rPx = (0.62f * max(region.halfW * aw, region.halfH * ah)).coerceIn(10f, ah * 0.11f)
            val rx = 2f * rPx / aw
            val ry = 2f * rPx / ah
            val fan = ArEffectRenderer.ellipseFanNd(cx, cy, rx, ry, 36)
            val buf = allocBuf(fan)
            GLES20.glUniform2f(centerHandle, cx, cy)
            GLES20.glUniform2f(radiusHandle, rx, ry)
            GLES20.glVertexAttribPointer(posHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
            GLES20.glEnableVertexAttribArray(posHandle)
            GLES20.glDrawArrays(GLES20.GL_TRIANGLE_FAN, 0, fan.size / 2)
            GLES20.glDisableVertexAttribArray(posHandle)
        }
        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (program != 0) GLES20.glDeleteProgram(program)
        program = 0
    }

    companion object {
        private const val SH_VS = """
            attribute vec2 aPosition;
            uniform vec2 uCenter;
            uniform vec2 uRadius;
            varying vec2 vRel;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                vRel = vec2(
                    (aPosition.x - uCenter.x) / max(uRadius.x, 0.0005),
                    (aPosition.y - uCenter.y) / max(uRadius.y, 0.0005)
                );
            }
        """
        private const val SH_FS = """
            precision mediump float;
            varying vec2 vRel;
            uniform float uTime;
            void main() {
                float r = length(vRel);
                if (r > 1.0) discard;
                float a = atan(vRel.y, vRel.x);
                vec3 red = vec3(0.78, 0.02, 0.05);
                vec3 blk = vec3(0.03);
                vec3 col = red;
                if (r > 0.88) col = blk;
                else if (r < 0.16) col = blk;
                else if (r > 0.66 && r < 0.78) col = blk;
                float rot = a + uTime * 2.1;
                vec2 c0 = vec2(cos(rot), sin(rot)) * 0.54;
                vec2 c1 = vec2(cos(rot - 2.094), sin(rot - 2.094)) * 0.54;
                vec2 c2 = vec2(cos(rot + 2.094), sin(rot + 2.094)) * 0.54;
                if (length(vRel - c0) < 0.24) col = blk;
                if (length(vRel - c1) < 0.24) col = blk;
                if (length(vRel - c2) < 0.24) col = blk;
                float edge = 1.0 - smoothstep(0.9, 1.0, r);
                gl_FragColor = vec4(col, edge * 0.92);
            }
        """
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pig nose — snout + nostrils on nose tip
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

internal class PigNoseEffect : ArEffectRenderer() {
    private var program = 0
    private var posHandle = 0
    private var centerHandle = 0
    private var radiusHandle = 0

    override fun init() {
        program = buildProgram(PIG_VS, PIG_FS)
        posHandle = GLES20.glGetAttribLocation(program, "aPosition")
        centerHandle = GLES20.glGetUniformLocation(program, "uCenter")
        radiusHandle = GLES20.glGetUniformLocation(program, "uRadius")
    }

    override fun draw(landmarks: FaceLandmarks, toGl: (Float, Float) -> Pair<Float, Float>, viewW: Int, viewH: Int) {
        val aw = viewW.coerceAtLeast(1).toFloat()
        val ah = viewH.coerceAtLeast(1).toFloat()
        val fw = landmarks.faceWidth()
        val (cx, cy) = toGl(landmarks.x(FaceLandmarks.NOSE_TIP), landmarks.y(FaceLandmarks.NOSE_TIP))
        val rPx = (fw * aw * 0.11f).coerceIn(14f, 95f)
        val rx = 2f * rPx / aw
        val ry = 2f * rPx * 0.95f / ah
        val fan = ArEffectRenderer.ellipseFanNd(cx, cy + ry * 0.08f, rx * 1.15f, ry * 1.2f, 36)
        val buf = allocBuf(fan)

        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glUniform2f(centerHandle, cx, cy + ry * 0.08f)
        GLES20.glUniform2f(radiusHandle, rx * 1.15f, ry * 1.2f)
        GLES20.glVertexAttribPointer(posHandle, 2, GLES20.GL_FLOAT, false, 0, buf)
        GLES20.glEnableVertexAttribArray(posHandle)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_FAN, 0, fan.size / 2)
        GLES20.glDisableVertexAttribArray(posHandle)
        GLES20.glDisable(GLES20.GL_BLEND)
    }

    override fun release() {
        if (program != 0) GLES20.glDeleteProgram(program)
        program = 0
    }

    companion object {
        private const val PIG_VS = """
            attribute vec2 aPosition;
            uniform vec2 uCenter;
            uniform vec2 uRadius;
            varying vec2 vRel;
            void main() {
                gl_Position = vec4(aPosition, 0.0, 1.0);
                vRel = vec2(
                    (aPosition.x - uCenter.x) / max(uRadius.x, 0.0005),
                    (aPosition.y - uCenter.y) / max(uRadius.y, 0.0005)
                );
            }
        """
        private const val PIG_FS = """
            precision mediump float;
            varying vec2 vRel;
            void main() {
                float r = length(vRel);
                if (r > 1.0) discard;
                vec3 pink = vec3(1.0, 0.62, 0.72);
                vec3 dark = vec3(0.12, 0.08, 0.1);
                vec3 col = pink;
                if (r > 0.78) col = mix(pink, vec3(0.95, 0.45, 0.55), smoothstep(0.78, 1.0, r));
                vec2 n1 = vRel - vec2(-0.32, -0.38);
                vec2 n2 = vRel - vec2(0.32, -0.38);
                if (length(n1) < 0.26) col = dark;
                if (length(n2) < 0.26) col = dark;
                if (r < 0.18) col = dark;
                float a = (1.0 - smoothstep(0.82, 1.0, r)) * 0.9;
                gl_FragColor = vec4(col, a);
            }
        """
    }
}

