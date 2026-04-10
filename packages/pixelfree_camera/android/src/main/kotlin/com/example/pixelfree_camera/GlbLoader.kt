package com.example.pixelfree_camera

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import org.json.JSONObject
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.max
import kotlin.math.min

/**
 * Minimal glTF 2.0 **GLB** loader for GLES 2.0: POSITION + optional
 * TEXCOORD_0 + NORMAL, UNSIGNED_SHORT/INT indices, embedded PNG/JPEG baseColor texture.
 * Draco / morph / skin / animations are **not** supported.
 */
internal data class GlbMeshPart(
    val positions: FloatArray,
    val normals: FloatArray?,
    val uvs: FloatArray?,
    val indices: ShortArray,
    val texture: Bitmap?,
    /** glTF pbrMetallicRoughness.baseColorFactor */
    val baseColorFactor: FloatArray,
) {
    val vertexCount: Int get() = positions.size / 3
}

internal object GlbLoader {
    private const val TAG = "GlbLoader"

    /** 每个 primitive 一段几何 + 各自材质（颜色/贴图），眼镜等多材质模型必须用此接口而非合并为单网格。 */
    fun loadAllParts(fileBytes: ByteArray): List<GlbMeshPart>? {
        return runCatching { loadAllPartsInternal(fileBytes) }
            .onFailure { Log.e(TAG, "GLB load failed", it) }
            .getOrNull()
    }

    private fun loadAllPartsInternal(bytes: ByteArray): List<GlbMeshPart>? {
        if (bytes.size < 20) return null
        val bb = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN)
        val magic = bb.int
        if (magic != 0x46546C67) { // "glTF"
            Log.e(TAG, "Not a GLB file")
            return null
        }
        val version = bb.int
        if (version != 2) {
            Log.e(TAG, "Unsupported glTF version $version")
            return null
        }
        val totalLen = bb.int
        if (totalLen > bytes.size) return null

        val jsonChunkLen = bb.int
        val jsonChunkType = bb.int
        if (jsonChunkType != 0x4E4F534A) {
            Log.e(TAG, "Expected JSON chunk")
            return null
        }
        val jsonBytes = ByteArray(jsonChunkLen)
        bb.get(jsonBytes)
        val jsonStr = jsonBytes.toString(Charsets.UTF_8)
        val root = JSONObject(jsonStr)

        if (!bb.hasRemaining()) {
            Log.e(TAG, "Missing BIN chunk")
            return null
        }
        val binChunkLen = bb.int
        val binChunkType = bb.int
        if (binChunkType != 0x004E4942) {
            Log.e(TAG, "Expected BIN chunk")
            return null
        }
        val binStart = bb.position()
        if (binStart + binChunkLen > bytes.size) return null
        val binArray = bytes.copyOfRange(binStart, binStart + binChunkLen)

        val meshes = root.optJSONArray("meshes") ?: return null
        val out = ArrayList<GlbMeshPart>(32)

        for (mi in 0 until meshes.length()) {
            val meshObj = meshes.getJSONObject(mi)
            val primitives = meshObj.optJSONArray("primitives") ?: continue
            for (pi in 0 until primitives.length()) {
                val prim = primitives.getJSONObject(pi)
                if (prim.optJSONObject("extensions")?.has("KHR_draco_mesh_compression") == true) {
                    Log.w(TAG, "Skip Draco primitive")
                    continue
                }
                val mode = prim.optInt("mode", 4)
                if (mode != 4) {
                    Log.w(TAG, "Skip non-triangle primitive mode=$mode")
                    continue
                }
                val chunk = loadOnePrimitive(root, binArray, prim) ?: continue
                out.add(chunk)
            }
        }
        if (out.isEmpty()) {
            Log.w(TAG, "No primitives — trying mesh[0].primitives[0] only")
            return loadFirstPrimitiveOnly(root, binArray)
        }
        Log.i(TAG, "GLB parts=${out.size}")
        return out
    }

    /** Fallback when merge yields nothing (e.g. index type failed on every part). */
    private fun loadFirstPrimitiveOnly(root: JSONObject, binArray: ByteArray): List<GlbMeshPart>? {
        val meshes = root.optJSONArray("meshes") ?: return null
        if (meshes.length() < 1) return null
        val prims = meshes.getJSONObject(0).optJSONArray("primitives") ?: return null
        if (prims.length() < 1) return null
        val prim = prims.getJSONObject(0)
        if (prim.optJSONObject("extensions")?.has("KHR_draco_mesh_compression") == true) return null
        Log.i(TAG, "Loading mesh[0].primitives[0] only")
        val one = loadOnePrimitive(root, binArray, prim) ?: return null
        return listOf(one)
    }

    /** Single triangle-list primitive (mode TRIANGLES). */
    private fun loadOnePrimitive(root: JSONObject, binArray: ByteArray, prim: JSONObject): GlbMeshPart? {
        val attr = prim.getJSONObject("attributes")
        val posAcc = attr.getInt("POSITION")
        val uvAcc = if (attr.has("TEXCOORD_0")) attr.getInt("TEXCOORD_0") else -1
        val nrmAcc = if (attr.has("NORMAL")) attr.getInt("NORMAL") else -1

        val positions = readAccessorFloatVec(root, binArray, posAcc, 3) ?: return null
        val count = positions.size / 3

        val uvs = if (uvAcc >= 0) readAccessorFloatVec(root, binArray, uvAcc, 2)?.let { u ->
            if (u.size == count * 2) u else null
        } else null

        val normals = if (nrmAcc >= 0) readAccessorFloatVec(root, binArray, nrmAcc, 3)?.let { n ->
            if (n.size == count * 3) n else null
        } else null

        val idxAcc = prim.optInt("indices", -1)
        val indices = if (idxAcc >= 0) {
            readIndices(root, binArray, idxAcc) ?: return null
        } else {
            ShortArray(count) { it.toShort() }
        }

        val matIndex = prim.optInt("material", -1)
        val (texBmp, baseColor) = loadMaterial(root, binArray, matIndex)

        return GlbMeshPart(
            positions = positions,
            normals = normals,
            uvs = uvs,
            indices = indices,
            texture = texBmp,
            baseColorFactor = baseColor,
        )
    }

    private fun loadMaterial(root: JSONObject, bin: ByteArray, matIndex: Int): Pair<Bitmap?, FloatArray> {
        val defaultFactor = floatArrayOf(1f, 1f, 1f, 1f)
        if (matIndex < 0) return Pair(null, defaultFactor)
        val materials = root.optJSONArray("materials") ?: return Pair(null, defaultFactor)
        if (matIndex >= materials.length()) return Pair(null, defaultFactor)
        val mat = materials.getJSONObject(matIndex)
        val pbr = mat.optJSONObject("pbrMetallicRoughness") ?: return Pair(null, defaultFactor)
        val fac = pbr.optJSONArray("baseColorFactor")
        val factor = if (fac != null && fac.length() >= 4) {
            floatArrayOf(
                fac.getDouble(0).toFloat(),
                fac.getDouble(1).toFloat(),
                fac.getDouble(2).toFloat(),
                fac.getDouble(3).toFloat(),
            )
        } else {
            defaultFactor.clone()
        }
        val texIdx = pbr.optJSONObject("baseColorTexture")?.optInt("index", -1) ?: -1
        if (texIdx < 0) return Pair(null, factor)
        val textures = root.optJSONArray("textures") ?: return Pair(null, factor)
        if (texIdx >= textures.length()) return Pair(null, factor)
        val src = textures.getJSONObject(texIdx).optInt("source", -1)
        if (src < 0) return Pair(null, factor)
        val images = root.optJSONArray("images") ?: return Pair(null, factor)
        if (src >= images.length()) return Pair(null, factor)
        val image = images.getJSONObject(src)
        val bmp = when {
            image.has("bufferView") -> {
                val bvIndex = image.getInt("bufferView")
                val mime = image.optString("mimeType", "image/png")
                val viewBytes = sliceBufferView(root, bin, bvIndex) ?: return Pair(null, factor)
                BitmapFactory.decodeByteArray(viewBytes, 0, viewBytes.size)
            }
            image.has("uri") -> {
                Log.e(TAG, "External uri images not supported in minimal loader")
                null
            }
            else -> null
        }
        return Pair(bmp, factor)
    }

    private fun sliceBufferView(root: JSONObject, bin: ByteArray, bvIndex: Int): ByteArray? {
        val bvs = root.getJSONArray("bufferViews")
        if (bvIndex >= bvs.length()) return null
        val bv = bvs.getJSONObject(bvIndex)
        val offset = bv.optInt("byteOffset", 0)
        val length = bv.getInt("byteLength")
        val bufIndex = bv.optInt("buffer", 0)
        if (bufIndex != 0) {
            Log.e(TAG, "Only embedded buffer 0 (GLB BIN) is supported")
            return null
        }
        if (offset + length > bin.size) return null
        return bin.copyOfRange(offset, offset + length)
    }

    private fun readAccessorFloatVec(root: JSONObject, bin: ByteArray, accessorIndex: Int, components: Int): FloatArray? {
        val acc = root.getJSONArray("accessors").getJSONObject(accessorIndex)
        val type = acc.getString("type")
        val expected = when (type) {
            "VEC2" -> 2
            "VEC3" -> 3
            else -> return null
        }
        if (expected != components) return null
        val count = acc.getInt("count")
        val compType = acc.getInt("componentType")
        if (compType != 5126) { // FLOAT
            Log.e(TAG, "POSITION/NORMAL/UV must be FLOAT for this loader")
            return null
        }
        val bvIndex = acc.optInt("bufferView", -1)
        if (bvIndex < 0) return null
        val accByteOffset = acc.optInt("byteOffset", 0)
        val bvs = root.getJSONArray("bufferViews")
        val bv = bvs.getJSONObject(bvIndex)
        val bvOffset = bv.optInt("byteOffset", 0)
        val stride = bv.optInt("byteStride", 0).let { if (it == 0) components * 4 else it }
        val base = bvOffset + accByteOffset
        if (base + stride * (count - 1) + components * 4 > bin.size) return null
        val out = FloatArray(count * components)
        val bb = ByteBuffer.wrap(bin).order(ByteOrder.LITTLE_ENDIAN)
        var o = 0
        var pos = base
        for (i in 0 until count) {
            for (c in 0 until components) {
                bb.position(pos + c * 4)
                out[o++] = bb.float
            }
            pos += stride
        }
        return out
    }

    private fun readIndices(root: JSONObject, bin: ByteArray, accessorIndex: Int): ShortArray? {
        val acc = root.getJSONArray("accessors").getJSONObject(accessorIndex)
        val count = acc.getInt("count")
        val compType = acc.getInt("componentType")
        val bvIndex = acc.optInt("bufferView", -1)
        if (bvIndex < 0) return null
        val accByteOffset = acc.optInt("byteOffset", 0)
        val bvs = root.getJSONArray("bufferViews")
        val bv = bvs.getJSONObject(bvIndex)
        val bvOffset = bv.optInt("byteOffset", 0)
        val stride = bv.optInt("byteStride", 0).let { st ->
            when (compType) {
                5121 -> if (st == 0) 1 else st // UNSIGNED_BYTE (common in web exports)
                5123 -> if (st == 0) 2 else st // UNSIGNED_SHORT
                5125 -> if (st == 0) 4 else st // UNSIGNED_INT
                else -> {
                    Log.e(TAG, "Unsupported index componentType=$compType")
                    return null
                }
            }
        }
        val base = bvOffset + accByteOffset
        val out = ShortArray(count)
        val bb = ByteBuffer.wrap(bin).order(ByteOrder.LITTLE_ENDIAN)
        var pos = base
        for (i in 0 until count) {
            val v = when (compType) {
                5121 -> {
                    bb.position(pos)
                    bb.get().toInt() and 0xFF
                }
                5123 -> {
                    bb.position(pos)
                    bb.short.toInt() and 0xFFFF
                }
                5125 -> {
                    bb.position(pos)
                    val vi = bb.int
                    if (vi < 0 || vi > 65535) {
                        Log.e(TAG, "Index $vi does not fit UNSIGNED_SHORT; re-export with 16-bit indices")
                        return null
                    }
                    vi
                }
                else -> return null
            }
            out[i] = v.toShort()
            pos += stride
        }
        return out
    }
}

/** 整副眼镜所有部件共用同一包围盒归一化，避免分片错位。 */
internal fun normalizeGlassesMeshPositionsGlobal(parts: List<GlbMeshPart>, targetHalfExtent: Float = 0.5f) {
    if (parts.isEmpty()) return
    var minX = Float.MAX_VALUE
    var minY = Float.MAX_VALUE
    var minZ = Float.MAX_VALUE
    var maxX = -Float.MAX_VALUE
    var maxY = -Float.MAX_VALUE
    var maxZ = -Float.MAX_VALUE
    for (part in parts) {
        var i = 0
        val pos = part.positions
        while (i < pos.size) {
            val x = pos[i]
            val y = pos[i + 1]
            val z = pos[i + 2]
            minX = min(minX, x)
            minY = min(minY, y)
            minZ = min(minZ, z)
            maxX = max(maxX, x)
            maxY = max(maxY, y)
            maxZ = max(maxZ, z)
            i += 3
        }
    }
    val cx = (minX + maxX) * 0.5f
    val cy = (minY + maxY) * 0.5f
    val cz = (minZ + maxZ) * 0.5f
    var maxDim = max(maxX - minX, max(maxY - minY, maxZ - minZ))
    if (maxDim < 1e-6f) maxDim = 1f
    val s = (targetHalfExtent * 2f) / maxDim
    for (part in parts) {
        val pos = part.positions
        var j = 0
        while (j < pos.size) {
            pos[j] = (pos[j] - cx) * s
            pos[j + 1] = (pos[j + 1] - cy) * s
            pos[j + 2] = (pos[j + 2] - cz) * s
            j += 3
        }
    }
}
