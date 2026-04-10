const fs = require("fs");
const p = __dirname + "/uv_coords.ts";
const t = fs.readFileSync(p, "utf8");
const pairs = [];
const re = /\[([\d.]+),\s*([\d.]+)\]/g;
let m;
while ((m = re.exec(t)) !== null) {
  pairs.push(parseFloat(m[1]), parseFloat(m[2]));
}
if (pairs.length !== 468 * 2) {
  console.error("expected 936 floats, got", pairs.length);
  process.exit(1);
}
let uMin = Infinity,
  uMax = -Infinity,
  vMin = Infinity,
  vMax = -Infinity;
for (let i = 0; i < pairs.length; i += 2) {
  uMin = Math.min(uMin, pairs[i]);
  uMax = Math.max(uMax, pairs[i]);
  vMin = Math.min(vMin, pairs[i + 1]);
  vMax = Math.max(vMax, pairs[i + 1]);
}
const lines = [];
for (let i = 0; i < pairs.length; i += 12) {
  const chunk = pairs.slice(i, i + 12);
  lines.push("        " + chunk.map((n) => n + "f").join(", ") + ",");
}
const out = `package com.example.pixelfree_camera

/**
 * TF.js MediaPipe FaceMesh canonical UV per vertex (468 x 2 floats).
 * Source: https://github.com/tensorflow/tfjs-models/blob/838611c02f51159afdd77469ce67f0e26b7bbb23/face-landmarks-detection/src/mediapipe-facemesh/uv_coords.ts
 */
internal object FaceMeshUv468 {
    const val VERTEX_COUNT = 468

    /** Flat [u0,v0, u1,v1, ...] in template UV space (roughly 0..1). */
    val UV: FloatArray = floatArrayOf(
${lines.join("\n")}
    )

    /** Precomputed bounds of [UV] for linear remap into current face rect in camera texture space. */
    const val CANON_U_MIN = ${uMin}f
    const val CANON_U_MAX = ${uMax}f
    const val CANON_V_MIN = ${vMin}f
    const val CANON_V_MAX = ${vMax}f

    fun u(i: Int): Float = UV[i * 2]
    fun v(i: Int): Float = UV[i * 2 + 1]
}
`;
fs.writeFileSync(
  __dirname + "/../android/src/main/kotlin/com/example/pixelfree_camera/FaceMeshUv468.kt",
  out,
  "utf8"
);
console.log("ok", pairs.length / 2, "uMin", uMin, "bounds ok");
