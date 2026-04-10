
    )

    /**
     * 去重后的无向边，展平为 [a0,b0,...]，供 GL_LINES。
     */
    val WIREFRAME_LINE_INDICES: IntArray by lazy {
        buildUniqueWireframeEdges(TRIANGLE_INDICES)
    }

    private fun buildUniqueWireframeEdges(tris: IntArray): IntArray {
        val edges = LinkedHashSet<Long>()
        var i = 0
        while (i + 2 < tris.size) {
            val a = tris[i]
            val b = tris[i + 1]
            val c = tris[i + 2]
            fun addEdge(u: Int, v: Int) {
                val lo = minOf(u, v)
                val hi = maxOf(u, v)
                edges.add((lo.toLong() shl 16) or hi.toLong())
            }
            addEdge(a, b)
            addEdge(b, c)
            addEdge(c, a)
            i += 3
        }
        val out = IntArray(edges.size * 2)
        var o = 0
        for (key in edges) {
            val lo = (key shr 16).toInt()
            val hi = (key and 0xFFFFL).toInt()
            out[o++] = lo
            out[o++] = hi
        }
        return out
    }
}
