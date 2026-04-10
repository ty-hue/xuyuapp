package com.example.pixelfree_camera

import android.content.Context
import android.graphics.Bitmap
import android.opengl.GLES20
import android.opengl.GLUtils
import android.opengl.Matrix
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.PI

/**
 * GLB 眼镜：多 primitive / 多材质分片绘制；CPU 在 [init] 解析；GPU 在首次 [draw] 上传。
 */
internal class Glasses3dEffect(
    private val appContext: Context,
) : ArEffectRenderer() {

    private var program = 0
    private var aPos = 0
    private var aNrm = 0
    private var aUv = 0
    private var uMvp = 0
    private var uRot = 0
    private var uTex = 0
    private var uHasTex = 0
    private var uBaseColor = 0
    private var uLightWorld = 0

    private var pendingParts: List<GlbMeshPart>? = null
    private val gpuParts = mutableListOf<GpuPart>()

    /** 解析完成 */
    private var cpuReady = false
    /** GPU 已上传 */
    private var gpuReady = false

    private val mvp = FloatArray(16)
    private val matScl = FloatArray(16)
    /** 双眼连线 + 屏内法向 构造的正交基：镜腿沿左右耳方向（屏内水平），不再竖直戳向额头。 */
    private val matFace = FloatArray(16)
    private val matPitch = FloatArray(16)
    private val matT = FloatArray(16)
    private val matTmp = FloatArray(16)
    private val matComb = FloatArray(16)
    private val matRotNorm = FloatArray(16)
    private val matRx = FloatArray(16)
    private val matRy = FloatArray(16)
    private val matRz = FloatArray(16)
    /** 2D 瞳距矩阵缓存（与 3D 混合或单独使用）。 */
    private val matFace2d = FloatArray(16)
    /** 资源轴向微调（模型空间），在 [matFace] 之后、缩放之前：R_total = R_face * R_extra * S */
    private val matExtra = FloatArray(16)
    private val rot3 = FloatArray(9)
    private val lightWorld = FloatArray(3)

    /** 用于热重载失败后仍能按同一字节重建网格（改 [GPU_LAYOUT_REVISION] 会强制重传 GPU）。 */
    private var cachedGlbBytes: ByteArray? = null
    private var gpuLayoutRevisionApplied = -1

    private data class GpuPart(
        var posVbo: Int,
        var nrmVbo: Int,
        var uvVbo: Int,
        var idxVbo: Int,
        var indexCount: Int,
        var texId: Int,
        val br: Float,
        val bg: Float,
        val bb: Float,
        val ba: Float,
    )

    override fun init() {
        releaseAll()
        val bytes = loadGlbBytesFromAssets() ?: run {
            Log.e(TAG, "Open GLB failed (tried ${ASSET_CANDIDATES.joinToString()})")
            return
        }
        cachedGlbBytes = bytes
        val prepared = prepareMeshFromBytes(bytes) ?: run {
            Log.e(TAG, "GLB prepare failed")
            return
        }
        pendingParts = prepared
        cpuReady = true
        gpuReady = false
        gpuLayoutRevisionApplied = GPU_LAYOUT_REVISION
        Log.i(
            TAG,
            "CPU OK parts=${prepared.size} rev=$GPU_LAYOUT_REVISION meshRx=${GLASSES_MESH_PRE_ROT_X_DEG} tag=$EFFECT_BUILD_TAG",
        )
    }

    /** 解析 → 补全法线/UV → 归一化 → 资源轴向校正（绕 X 旋转，使常见「镜腿沿 +Y」对齐到 +Z）。 */
    private fun prepareMeshFromBytes(bytes: ByteArray): List<GlbMeshPart>? {
        val raw = GlbLoader.loadAllParts(bytes) ?: return null
        val prepared = ArrayList<GlbMeshPart>(raw.size)
        for (p in raw) {
            val n = p.vertexCount
            val nrm = p.normals ?: FloatArray(n * 3).also { arr ->
                var i = 0
                while (i < arr.size) {
                    arr[i] = 0f
                    arr[i + 1] = 0f
                    arr[i + 2] = 1f
                    i += 3
                }
            }
            val uv = p.uvs ?: FloatArray(n * 2) { 0f }
            if (nrm.size != n * 3 || uv.size != n * 2) {
                Log.e(TAG, "Attribute length mismatch in part")
                continue
            }
            if (p.indices.isEmpty()) continue
            prepared.add(
                GlbMeshPart(
                    positions = p.positions,
                    normals = nrm,
                    uvs = uv,
                    indices = p.indices.copyOf(),
                    texture = p.texture,
                    baseColorFactor = p.baseColorFactor.clone(),
                ),
            )
        }
        if (prepared.isEmpty()) return null
        normalizeGlassesMeshPositionsGlobal(prepared, targetHalfExtent = 0.5f)
        // glasses_06 类资源：镜腿多在 **-Z（朝后）**。若再 Rx(+90)，会把 **-Z→+Y**，而 R_face 里 **+Y 是屏内竖直** → 镜腿冲天。**0°** 时 **±Z 仍走第三列深度**，镜腿朝耳后。
        // 若换模后镜腿沿 **+Y** 且冲天，再改回 **90f**。切勿整模 Rz。
        rotateMeshRxDegrees(prepared, GLASSES_MESH_PRE_ROT_X_DEG)
        return prepared
    }

    /** 将顶点/法线绕 **+X** 旋转 `degrees`（度），右手系。+90° 时原 **+Y** 方向转到 **+Z**。 */
    private fun rotateMeshRxDegrees(parts: List<GlbMeshPart>, degrees: Float) {
        if (kotlin.math.abs(degrees) < 0.001f) return
        val rad = degrees * PI.toFloat() / 180f
        val c = cos(rad)
        val s = sin(rad)
        for (p in parts) {
            val pos = p.positions
            val nrm = p.normals ?: continue
            var i = 0
            while (i < pos.size) {
                val x = pos[i]
                val y = pos[i + 1]
                val z = pos[i + 2]
                pos[i] = x
                pos[i + 1] = y * c - z * s
                pos[i + 2] = y * s + z * c
                val nx = nrm[i]
                val ny = nrm[i + 1]
                val nz = nrm[i + 2]
                nrm[i] = nx
                nrm[i + 1] = ny * c - nz * s
                nrm[i + 2] = ny * s + nz * c
                i += 3
            }
        }
    }

    private fun loadGlbBytesFromAssets(): ByteArray? {
        val am = appContext.assets
        for (name in ASSET_CANDIDATES) {
            val b = runCatching { am.open(name).use { it.readBytes() } }.getOrNull()
            if (b != null && b.isNotEmpty()) return b
        }
        return null
    }

    private fun uploadTexture2D(bmp: Bitmap): Int {
        val tid = IntArray(1)
        GLES20.glGenTextures(1, tid, 0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tid[0])
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bmp, 0)
        val w = bmp.width
        val h = bmp.height
        val pot = w > 0 && h > 0 && w and (w - 1) == 0 && h and (h - 1) == 0
        if (pot) {
            GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D)
            GLES20.glTexParameteri(
                GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER,
                GLES20.GL_LINEAR_MIPMAP_LINEAR,
            )
        } else {
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        }
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        return tid[0]
    }

    private fun ensureGpuUpload() {
        if (gpuLayoutRevisionApplied != GPU_LAYOUT_REVISION) {
            releaseGlLocal()
            gpuReady = false
            val b = cachedGlbBytes
            if (b != null) {
                pendingParts = prepareMeshFromBytes(b)
                Log.i(TAG, "rebuilt CPU mesh for GPU_LAYOUT_REVISION=$GPU_LAYOUT_REVISION tag=$EFFECT_BUILD_TAG")
            }
            gpuLayoutRevisionApplied = GPU_LAYOUT_REVISION
        }
        if (gpuReady || !cpuReady) return
        val list = pendingParts ?: return
        GLES20.glGetError()

        for (mesh in list) {
            val pos = mesh.positions
            val nrm = mesh.normals ?: continue
            val uv = mesh.uvs ?: continue
            val idx = mesh.indices
            val ib = ByteBuffer.allocateDirect(idx.size * 2).order(ByteOrder.nativeOrder()).asShortBuffer()
            ib.put(idx)
            ib.position(0)
            val pb = ByteBuffer.allocateDirect(pos.size * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()
            pb.put(pos)
            pb.position(0)
            val nb = ByteBuffer.allocateDirect(nrm.size * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()
            nb.put(nrm)
            nb.position(0)
            val ub = ByteBuffer.allocateDirect(uv.size * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()
            ub.put(uv)
            ub.position(0)

            val vbos = IntArray(4)
            GLES20.glGenBuffers(4, vbos, 0)
            val posVbo = vbos[0]
            val nrmVbo = vbos[1]
            val uvVbo = vbos[2]
            val idxVbo = vbos[3]

            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, posVbo)
            GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, pos.size * 4, pb, GLES20.GL_STATIC_DRAW)
            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, nrmVbo)
            GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, nrm.size * 4, nb, GLES20.GL_STATIC_DRAW)
            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, uvVbo)
            GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, uv.size * 4, ub, GLES20.GL_STATIC_DRAW)
            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)

            GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, idxVbo)
            GLES20.glBufferData(GLES20.GL_ELEMENT_ARRAY_BUFFER, idx.size * 2, ib, GLES20.GL_STATIC_DRAW)
            GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, 0)

            var texId = 0
            val pt = mesh.texture
            if (pt != null && !pt.isRecycled) {
                texId = uploadTexture2D(pt)
                pt.recycle()
            }

            val f = mesh.baseColorFactor
            val br = f.getOrElse(0) { 1f }
            val bg = f.getOrElse(1) { 1f }
            val bb = f.getOrElse(2) { 1f }
            val ba = f.getOrElse(3) { 1f }

            gpuParts.add(
                GpuPart(
                    posVbo = posVbo,
                    nrmVbo = nrmVbo,
                    uvVbo = uvVbo,
                    idxVbo = idxVbo,
                    indexCount = idx.size,
                    texId = texId,
                    br = br,
                    bg = bg,
                    bb = bb,
                    ba = ba,
                ),
            )
        }
        pendingParts = null

        program = buildProgram(VS, FS)
        aPos = GLES20.glGetAttribLocation(program, "aPosition")
        aNrm = GLES20.glGetAttribLocation(program, "aNormal")
        aUv = GLES20.glGetAttribLocation(program, "aUv")
        uMvp = GLES20.glGetUniformLocation(program, "uMVP")
        uRot = GLES20.glGetUniformLocation(program, "uRot")
        uTex = GLES20.glGetUniformLocation(program, "uTex")
        uHasTex = GLES20.glGetUniformLocation(program, "uHasTex")
        uBaseColor = GLES20.glGetUniformLocation(program, "uBaseColor")
        uLightWorld = GLES20.glGetUniformLocation(program, "uLightWorld")

        val ok = program != 0 && gpuParts.isNotEmpty()
        if (ok) {
            gpuReady = true
            Log.i(TAG, "GPU OK: parts=${gpuParts.size} program=$program")
        } else {
            Log.e(TAG, "GPU upload failed")
            releaseGlLocal()
        }
    }

    override fun draw(
        landmarks: FaceLandmarks,
        toGl: (Float, Float) -> Pair<Float, Float>,
        viewW: Int,
        viewH: Int,
    ) {
        if (!cpuReady) return
        ensureGpuUpload()
        if (!gpuReady || gpuParts.isEmpty()) return

        val (lx, ly) = landmarks.leftIrisCenterNorm()
        val (rx, ry) = landmarks.rightIrisCenterNorm()
        val (nx, ny) = landmarks.noseTip()
        val (ex, ey) = landmarks.eyeCenter()
        val ax = ex * (1f - NOSE_BLEND_X) + nx * NOSE_BLEND_X
        // 用眼睑轮廓垂直中心比纯虹膜更贴近「镜片应盖住」的位置。
        val le = landmarks.eyeRegionFromContour(FaceLandmarks.LEFT_EYE_INDICES)
        val re = landmarks.eyeRegionFromContour(FaceLandmarks.RIGHT_EYE_INDICES)
        val eyeMidY = (le.cy + re.cy) * 0.5f
        val (fx, fy) = landmarks.forehead()
        val ay = eyeMidY * (1f - FOREHEAD_BLEND_Y) + fy * FOREHEAD_BLEND_Y

        val (lxNdc, lyNdc) = toGl(lx, ly)
        val (rxNdc, ryNdc) = toGl(rx, ry)
        val (mx, myBase) = toGl(ax, ay)
        val my = myBase + ANCHOR_BIAS_Y_NDC

        val ipdNdc = hypot((rxNdc - lxNdc).toDouble(), (ryNdc - lyNdc).toDouble()).toFloat()
            .coerceAtLeast(0.04f)

        val scale = max(ipdNdc * 2.2f, 0.08f)

        val liz = landmarks.z(FaceLandmarks.LEFT_IRIS)
        val riz = landmarks.z(FaceLandmarks.RIGHT_IRIS)
        val nz = landmarks.z(FaceLandmarks.NOSE_TIP)
        val midZ = (liz + riz) * 0.5f
        // 俯仰过大会让镜腿像「翘起」；系数与上下限略收，更接近参考里镜腿贴头侧的感觉。
        val pitchFromZ = ((nz - midZ) * 110f).coerceIn(-12f, 12f)

        buildFaceAlignedRotation(lxNdc, lyNdc, rxNdc, ryNdc, matFace2d)
        // 侧脸时虹膜在屏上很近，3D 叉积极不稳定 → 只用 2D 瞳距；正脸再叠 MediaPipe z。
        val ipdOkFor3d = ipdNdc >= MIN_IPD_NDC_FOR_3D
        val ok3d = USE_MEDIA_PIPE_3D_FACE_BASIS && ipdOkFor3d &&
            buildFaceRotationFromMediaPipe3d(landmarks, toGl, ipdNdc, matFace)
        if (!ok3d) {
            System.arraycopy(matFace2d, 0, matFace, 0, 16)
        }
        applyModelAxisFix(matFace)
        // 绕 **瞳距轴（第 1 列）** 转 180°：只翻脸平面内的上下+前后，不左右镜像，纠正镜梁/镜片上下颠倒；与模型空间 Rx 二选一，避免叠两次。
        flipFaceUpDownAboutIpdAxisIfNeeded(matFace)

        // 3D 成功时减弱额外 pitch，避免与 3D 基叠加过拧。
        val pitchDeg = if (ok3d) pitchFromZ * PITCH_BLEND_WHEN_3D else pitchFromZ

        Matrix.setIdentityM(matRx, 0)
        Matrix.rotateM(matRx, 0, GLASSES_MODEL_ROT_X_DEG, 1f, 0f, 0f)
        Matrix.setIdentityM(matRy, 0)
        Matrix.rotateM(matRy, 0, GLASSES_MODEL_ROT_Y_DEG, 0f, 1f, 0f)
        Matrix.setIdentityM(matRz, 0)
        Matrix.rotateM(matRz, 0, GLASSES_MODEL_ROT_Z_DEG, 0f, 0f, 1f)
        // R_extra = Ry * Rx * Rz（先 Rz→Rx→Ry 作用在顶点）。**勿用 Rz=180 纠正上下**：会在屏平面内翻面，导致左右转头与眼镜反向。
        Matrix.multiplyMM(matTmp, 0, matRx, 0, matRz, 0)
        Matrix.multiplyMM(matExtra, 0, matRy, 0, matTmp, 0)

        Matrix.setIdentityM(matScl, 0)
        Matrix.scaleM(matScl, 0, scale, scale, scale)
        Matrix.setIdentityM(matPitch, 0)
        Matrix.rotateM(matPitch, 0, pitchDeg, 1f, 0f, 0f)

        // MVP = T * Pitch * R_face * R_extra * S；R_face 第一列 = 瞳距水平，第三列 = 深度（朝耳/入屏）。
        Matrix.multiplyMM(matTmp, 0, matExtra, 0, matScl, 0)
        Matrix.multiplyMM(matComb, 0, matFace, 0, matTmp, 0)
        Matrix.multiplyMM(matTmp, 0, matPitch, 0, matComb, 0)
        Matrix.setIdentityM(matT, 0)
        Matrix.translateM(matT, 0, mx, my, ANCHOR_Z_NDC)
        Matrix.multiplyMM(mvp, 0, matT, 0, matTmp, 0)

        Matrix.multiplyMM(matTmp, 0, matFace, 0, matExtra, 0)
        Matrix.multiplyMM(matRotNorm, 0, matPitch, 0, matTmp, 0)
        rot3[0] = matRotNorm[0]
        rot3[1] = matRotNorm[1]
        rot3[2] = matRotNorm[2]
        rot3[3] = matRotNorm[4]
        rot3[4] = matRotNorm[5]
        rot3[5] = matRotNorm[6]
        rot3[6] = matRotNorm[8]
        rot3[7] = matRotNorm[9]
        rot3[8] = matRotNorm[10]

        var lightX = 0.32f
        var lightY = 0.46f
        var lightZ = 0.82f
        val invLen = 1f / kotlin.math.sqrt((lightX * lightX + lightY * lightY + lightZ * lightZ).toDouble()).toFloat()
        lightX *= invLen
        lightY *= invLen
        lightZ *= invLen
        lightWorld[0] = lightX
        lightWorld[1] = lightY
        lightWorld[2] = lightZ

        GLES20.glUseProgram(program)
        GLES20.glUniformMatrix4fv(uMvp, 1, false, mvp, 0)
        GLES20.glUniformMatrix3fv(uRot, 1, false, rot3, 0)
        GLES20.glUniform3fv(uLightWorld, 1, lightWorld, 0)

        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glDisable(GLES20.GL_CULL_FACE)
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(false)

        for (part in gpuParts) {
            GLES20.glUniform4f(uBaseColor, part.br, part.bg, part.bb, part.ba)
            if (part.texId != 0) {
                GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + BASE_COLOR_TEX_UNIT)
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, part.texId)
                GLES20.glUniform1i(uTex, BASE_COLOR_TEX_UNIT)
                GLES20.glUniform1f(uHasTex, 1f)
            } else {
                GLES20.glUniform1f(uHasTex, 0f)
            }

            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, part.posVbo)
            GLES20.glEnableVertexAttribArray(aPos)
            GLES20.glVertexAttribPointer(aPos, 3, GLES20.GL_FLOAT, false, 0, 0)

            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, part.nrmVbo)
            GLES20.glEnableVertexAttribArray(aNrm)
            GLES20.glVertexAttribPointer(aNrm, 3, GLES20.GL_FLOAT, false, 0, 0)

            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, part.uvVbo)
            GLES20.glEnableVertexAttribArray(aUv)
            GLES20.glVertexAttribPointer(aUv, 2, GLES20.GL_FLOAT, false, 0, 0)

            GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, part.idxVbo)
            GLES20.glDrawElements(GLES20.GL_TRIANGLES, part.indexCount, GLES20.GL_UNSIGNED_SHORT, 0)
        }

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)
        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, 0)
        GLES20.glDisableVertexAttribArray(aPos)
        GLES20.glDisableVertexAttribArray(aNrm)
        GLES20.glDisableVertexAttribArray(aUv)
        GLES20.glDepthMask(false)
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDisable(GLES20.GL_BLEND)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + BASE_COLOR_TEX_UNIT)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
    }

    override fun release() {
        releaseAll()
    }

    private fun releaseAll() {
        pendingParts = null
        cachedGlbBytes = null
        gpuLayoutRevisionApplied = -1
        releaseGlLocal()
        cpuReady = false
        gpuReady = false
    }

    private fun releaseGlLocal() {
        for (p in gpuParts) {
            if (p.posVbo != 0) {
                GLES20.glDeleteBuffers(4, intArrayOf(p.posVbo, p.nrmVbo, p.uvVbo, p.idxVbo), 0)
            }
            if (p.texId != 0) {
                GLES20.glDeleteTextures(1, intArrayOf(p.texId), 0)
            }
        }
        gpuParts.clear()
        if (program != 0) {
            GLES20.glDeleteProgram(program)
            program = 0
        }
    }

    /**
     * **u=(ux,uy)**：左→右瞳距水平方向。
     *
     * - **+X**（瞳距）→ **(ux,uy,0)** 屏内水平。
     * - **+Y**（镜圈竖直、鼻梁方向在框平面内）→ **(-uy,ux,0)**，与瞳距垂直。
     * - **+Z**（镜腿朝耳后、深入场景）→ **(0,0,1)**，主要进 **NDC 深度**；若把 +Z 映到 **(-uy,ux,0)**，正脸时变成 **(0,1,0)**，镜腿全长会画成 **竖直戳向头顶**。
     *
     * cross(col0,col1)=col2，右手系。
     */
    private fun buildFaceAlignedRotation(
        lxNdc: Float,
        lyNdc: Float,
        rxNdc: Float,
        ryNdc: Float,
        out: FloatArray,
    ) {
        val vx = rxNdc - lxNdc
        val vy = ryNdc - lyNdc
        val len = hypot(vx.toDouble(), vy.toDouble()).toFloat().coerceAtLeast(1e-5f)
        val ux = vx / len
        val uy = vy / len
        Matrix.setIdentityM(out, 0)
        out[0] = ux
        out[1] = uy
        out[2] = 0f
        out[4] = -uy
        out[5] = ux
        out[6] = 0f
        out[8] = 0f
        out[9] = 0f
        out[10] = 1f
    }

    /**
     * 用 MediaPipe 虹膜 + 鼻尖的 **(x,y,z)** 在 NDC 空间构造右手标架，使眼镜随头部 **真实 3D 姿态** 倾斜/转头，
     * 镜腿深度轴不再被锁死在屏幕 Z，更接近短视频 App 的贴脸感。
     *
     * - **ex**：左瞳→右瞳（镜圈宽度）
     * - **aux**：双眼中点→鼻尖（朝下）
     * - **ez**：ex×aux，朝外（法线/入屏）；再 **ey**=ez×ex（脸平面内竖直）
     */
    private fun buildFaceRotationFromMediaPipe3d(
        landmarks: FaceLandmarks,
        toGl: (Float, Float) -> Pair<Float, Float>,
        ipdNdc: Float,
        out: FloatArray,
    ): Boolean {
        val (lx, ly) = landmarks.leftIrisCenterNorm()
        val (rx, ry) = landmarks.rightIrisCenterNorm()
        val (nx, ny) = landmarks.noseTip()
        val lz = irisRingMeanZ(landmarks, left = true)
        val rz = irisRingMeanZ(landmarks, left = false)
        val nz = landmarks.z(FaceLandmarks.NOSE_TIP)

        val (lxNdc, lyNdc) = toGl(lx, ly)
        val (rxNdc, ryNdc) = toGl(rx, ry)
        val (nxNdc, nyNdc) = toGl(nx, ny)

        val k = (ipdNdc * MP_Z_TO_NDC_SCALE).coerceIn(MP_Z_SCALE_MIN, MP_Z_SCALE_MAX)

        val lx3 = lxNdc
        val ly3 = lyNdc
        val lz3 = lz * k
        val rx3 = rxNdc
        val ry3 = ryNdc
        val rz3 = rz * k
        val nx3 = nxNdc
        val ny3 = nyNdc
        val nz3 = nz * k

        var ex = rx3 - lx3
        var ey = ry3 - ly3
        var ez = rz3 - lz3
        var elen = sqrt(ex * ex + ey * ey + ez * ez).coerceAtLeast(1e-6f)
        ex /= elen
        ey /= elen
        ez /= elen

        val midx = (lx3 + rx3) * 0.5f
        val midy = (ly3 + ry3) * 0.5f
        val midz = (lz3 + rz3) * 0.5f
        var ax = nx3 - midx
        var ay = ny3 - midy
        var az = nz3 - midz
        var alen = sqrt(ax * ax + ay * ay + az * az).coerceAtLeast(1e-6f)
        ax /= alen
        ay /= alen
        az /= alen

        var zx = ey * az - ez * ay
        var zy = ez * ax - ex * az
        var zz = ex * ay - ey * ax
        var zlen = sqrt(zx * zx + zy * zy + zz * zz)
        if (zlen < 1e-5f) return false
        zx /= zlen
        zy /= zlen
        zz /= zlen
        // 正脸时期望 **ez** 主要沿 NDC +Z（朝相机）；反向则翻面。
        if (zz < 0f) {
            zx = -zx
            zy = -zy
            zz = -zz
        }

        var ux = zy * ez - zz * ey
        var uy = zz * ex - zx * ez
        var uz = zx * ey - zy * ex
        val ulen = sqrt(ux * ux + uy * uy + uz * uz).coerceAtLeast(1e-6f)
        ux /= ulen
        uy /= ulen
        uz /= ulen

        Matrix.setIdentityM(out, 0)
        // 列向量：模型 +X,+Y,+Z → 世界(NDC) 基
        out[0] = ex
        out[1] = ey
        out[2] = ez
        out[4] = ux
        out[5] = uy
        out[6] = uz
        out[8] = zx
        out[9] = zy
        out[10] = zz
        return true
    }

    private fun irisRingMeanZ(landmarks: FaceLandmarks, left: Boolean): Float {
        var s = 0f
        val from = if (left) 468 else 473
        val to = if (left) 472 else 477
        var n = 0
        for (i in from..to) {
            s += landmarks.z(i)
            n++
        }
        return if (n > 0) s / n.toFloat() else landmarks.z(if (left) FaceLandmarks.LEFT_IRIS else FaceLandmarks.RIGHT_IRIS)
    }

    /**
     * 对 R_face 的 **第 2、3 列**（脸平面竖直、深度）取反，等价于绕瞳距水平轴转 180°，
     * 用于 glb 镜梁与镜片相对人脸上下反了，且 **不改变** 左右转头方向（第 1 列不动）。
     */
    private fun flipFaceUpDownAboutIpdAxisIfNeeded(m: FloatArray) {
        if (!FLIP_FACE_UP_DOWN_ABOUT_IPD) return
        m[4] = -m[4]
        m[5] = -m[5]
        m[6] = -m[6]
        m[8] = -m[8]
        m[9] = -m[9]
        m[10] = -m[10]
    }

    /** 少数资源把镜圈宽度做在 **+Z**、镜腿在 **+X**：可改为 true 交换 Y/Z 列试机。 */
    private fun applyModelAxisFix(m: FloatArray) {
        if (!GLASSES_SWAP_MODEL_YZ) return
        val a0 = m[4]
        val a1 = m[5]
        val a2 = m[6]
        m[4] = m[8]
        m[5] = m[9]
        m[6] = m[10]
        m[8] = a0
        m[9] = a1
        m[10] = a2
    }

    companion object {
        private const val TAG = "Glasses3dEffect"
        private const val BASE_COLOR_TEX_UNIT = 3
        const val GLASSES_ASSET_NAME = "glasses_06.glb"

        /** 改网格/锚点/着色器逻辑时递增，旧 GPU VBO 与 program 会丢弃并重传。 */
        private const val GPU_LAYOUT_REVISION = 15
        /** Logcat 搜索此字符串可确认新 native 已打进 APK。 */
        private const val EFFECT_BUILD_TAG = "glasses-ar-2026-04-14-screenshot-fix"

        /**
         * 使用 MediaPipe 虹膜/鼻尖 **z** 构造 **3D 人脸标架**；侧脸时易与 2D 预览错位，可改为 false 只用瞳距旋转。
         */
        private const val USE_MEDIA_PIPE_3D_FACE_BASIS = false

        /**
         * 屏幕瞳距（NDC）低于此值时 **不用 3D 基**（侧脸两眼几乎重合，叉积发散），只保留 2D 瞳距旋转。
         */
        private const val MIN_IPD_NDC_FOR_3D = 0.11f

        /** 将 MediaPipe 归一化 z 放大到与 NDC 同量级，使叉积稳定。 */
        private const val MP_Z_TO_NDC_SCALE = 10f
        private const val MP_Z_SCALE_MIN = 4f
        private const val MP_Z_SCALE_MAX = 28f

        /** 3D 基已含姿态时，对深度俯仰的保留比例。 */
        private const val PITCH_BLEND_WHEN_3D = 0.22f

        /**
         * **0**：镜腿沿 **±Z** 的 glb（当前 glasses_06）— 保持 **Z→深度**，避免 Rx(+90) 把 **-Z 旋成 +Y（竖直）**。
         * **90**：镜腿沿 **+Y** 的导出 — 把 **+Y→+Z** 再进深度列。
         */
        private const val GLASSES_MESH_PRE_ROT_X_DEG = 0f

        /** 水平锚点：略掺鼻尖，避免侧脸时完全偏掉。 */
        private const val NOSE_BLEND_X = 0.06f
        /** 竖直：略掺额头；过大易把眼镜拉到眉弓（录屏里偏上）。 */
        private const val FOREHEAD_BLEND_Y = 0.04f
        /** NDC 竖直微调：负值略下移，让镜梁靠近鼻根/双眼。 */
        private const val ANCHOR_BIAS_Y_NDC = -0.028f
        /** 略向相机前移。 */
        private const val ANCHOR_Z_NDC = -0.02f

        /**
         * 若资源里镜腿沿 **+Y**、法线沿 **+Z**，与当前列约定不一致时设为 true。
         */
        private const val GLASSES_SWAP_MODEL_YZ = false

        /** 模型空间绕 X；与 [FLIP_FACE_UP_DOWN_ABOUT_IPD] 二选一，避免叠两次上下翻。 */
        private const val GLASSES_MODEL_ROT_X_DEG = 0f
        private const val GLASSES_MODEL_ROT_Y_DEG = 0f
        /** 一般保持 **0**；绕屏法向转半圈会破坏与人脸同向的旋转跟踪。 */
        private const val GLASSES_MODEL_ROT_Z_DEG = 0f

        /**
         * 在人脸矩阵上绕瞳距轴翻上下（见 [flipFaceUpDownAboutIpdAxisIfNeeded]）。
         * 若镜梁仍反了，可改为 **false** 并改 [GLASSES_MODEL_ROT_X_DEG] 为 **180** 试机。
         */
        private const val FLIP_FACE_UP_DOWN_ABOUT_IPD = true
        private val ASSET_CANDIDATES = arrayOf(GLASSES_ASSET_NAME)

        private const val VS = """
            uniform mat4 uMVP;
            uniform mat3 uRot;
            attribute vec3 aPosition;
            attribute vec3 aNormal;
            attribute vec2 aUv;
            varying vec2 vUv;
            varying vec3 vNormalW;
            void main() {
              vUv = aUv;
              vNormalW = uRot * aNormal;
              gl_Position = uMVP * vec4(aPosition, 1.0);
            }
        """

        private const val FS = """
            precision mediump float;
            uniform sampler2D uTex;
            uniform float uHasTex;
            uniform vec4 uBaseColor;
            uniform vec3 uLightWorld;
            varying vec2 vUv;
            varying vec3 vNormalW;
            void main() {
              vec3 n = normalize(vNormalW);
              vec4 tex = vec4(1.0);
              if (uHasTex > 0.5) {
                tex = texture2D(uTex, vUv);
              }
              vec4 albedo = vec4(uBaseColor.rgb * tex.rgb, uBaseColor.a * tex.a);
              float ndl = max(dot(n, uLightWorld), 0.0);
              vec3 diffuse = albedo.rgb * (0.18 + 0.82 * ndl);
              vec3 V = vec3(0.0, 0.10, 0.995);
              vec3 H = normalize(uLightWorld + normalize(V));
              float spec = pow(max(dot(n, H), 0.0), 36.0) * 0.42;
              vec3 Vd = normalize(vec3(0.0, 0.11, 0.994));
              float rim = pow(1.0 - max(abs(dot(n, Vd)), 0.0), 2.8) * 0.26;
              vec3 rgb = diffuse + vec3(spec) + vec3(0.92, 0.96, 1.0) * rim;
              gl_FragColor = vec4(rgb, albedo.a);
            }
        """
    }
}
