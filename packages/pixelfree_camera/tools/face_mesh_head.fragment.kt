package com.example.pixelfree_camera

import java.util.LinkedHashSet

/**
 * TensorFlow.js facemesh `TRIANGULATION`（468 顶点），与掘金/Web 示例一致。
 * 来源：https://github.com/tensorflow/tfjs-models/blob/838611c02f51159afdd77469ce67f0e26b7bbb23/facemesh/demo/triangulation.js
 * 勿与旧版 canonical_face_model.obj 三角表混用，否则与 Face Landmarker 点序不配时会整脸乱线。
 */
internal object FaceMeshTesselation468 {
    val TRIANGLE_INDICES: IntArray = intArrayOf(
