package com.example.pixelfree_camera

import android.opengl.GLES20
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

/**
 * Draws a semi-transparent colored overlay on the lip region using face landmark positions.
 * Uses a triangle-fan from the centroid of the outer lip contour.
 */
internal class LipColorEffect {

    private var program = 0
    private var aPosition = -1
    private var uColor = -1

    private val vertBuf: FloatBuffer =
        ByteBuffer.allocateDirect(MAX_VERTS * 2 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()

    fun init() {
        val vs = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER).also {
            GLES20.glShaderSource(it, VERT)
            GLES20.glCompileShader(it)
        }
        val fs = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER).also {
            GLES20.glShaderSource(it, FRAG)
            GLES20.glCompileShader(it)
        }
        program = GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, vs)
            GLES20.glAttachShader(it, fs)
            GLES20.glLinkProgram(it)
            GLES20.glDeleteShader(vs)
            GLES20.glDeleteShader(fs)
        }
        aPosition = GLES20.glGetAttribLocation(program, "aPosition")
        uColor = GLES20.glGetUniformLocation(program, "uColor")
    }

    /**
     * @param landmarks current face landmarks
     * @param landmarkToGl maps normalized (x,y) to NDC
     * @param argbColor ARGB packed int (e.g. 0x80C83255 for semi-transparent rose red)
     */
    fun draw(
        landmarks: FaceLandmarks,
        landmarkToGl: (Float, Float) -> Pair<Float, Float>,
        argbColor: Int,
    ) {
        if (program == 0) return

        val a = ((argbColor ushr 24) and 0xFF) / 255f
        val r = ((argbColor ushr 16) and 0xFF) / 255f
        val g = ((argbColor ushr 8) and 0xFF) / 255f
        val b = (argbColor and 0xFF) / 255f

        val n = LIP_OUTER.size
        var cx = 0f
        var cy = 0f
        val glPts = Array(n) { i ->
            val idx = LIP_OUTER[i]
            val (gx, gy) = landmarkToGl(landmarks.x(idx), landmarks.y(idx))
            cx += gx; cy += gy
            Pair(gx, gy)
        }
        cx /= n; cy /= n

        vertBuf.clear()
        var triCount = 0
        for (i in 0 until n) {
            val j = (i + 1) % n
            vertBuf.put(cx); vertBuf.put(cy)
            vertBuf.put(glPts[i].first); vertBuf.put(glPts[i].second)
            vertBuf.put(glPts[j].first); vertBuf.put(glPts[j].second)
            triCount++
        }
        vertBuf.flip()

        GLES20.glEnable(GLES20.GL_BLEND)
        // Separate blend for alpha: keep destination alpha at 1.0 so that
        // glReadPixels → Bitmap premultiplication does not darken the lip
        // region in saved JPEG snapshots.
        GLES20.glBlendFuncSeparate(
            GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA,  // RGB
            GLES20.GL_ZERO, GLES20.GL_ONE,                        // Alpha: keep dst
        )
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)

        GLES20.glUseProgram(program)
        GLES20.glUniform4f(uColor, r, g, b, a)
        GLES20.glVertexAttribPointer(aPosition, 2, GLES20.GL_FLOAT, false, 0, vertBuf)
        GLES20.glEnableVertexAttribArray(aPosition)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, triCount * 3)
        GLES20.glDisableVertexAttribArray(aPosition)
        GLES20.glDisable(GLES20.GL_BLEND)
    }

    fun release() {
        if (program != 0) { GLES20.glDeleteProgram(program); program = 0 }
    }

    companion object {
        private const val MAX_VERTS = 128

        private val LIP_OUTER = intArrayOf(
            61, 146, 91, 181, 84, 17, 314, 405, 321, 375,
            291, 409, 270, 269, 267, 0, 37, 39, 40, 185,
        )

        private const val VERT = """
            attribute vec2 aPosition;
            void main() { gl_Position = vec4(aPosition, 0.0, 1.0); }
        """
        private const val FRAG = """
            precision mediump float;
            uniform vec4 uColor;
            void main() { gl_FragColor = uColor; }
        """
    }
}
