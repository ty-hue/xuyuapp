const fs = require("fs");
const p =
  "c:/Users/Administrator/Desktop/new_note/03flutter_note/xuyu/pixelfree_camera/android/src/main/kotlin/com/example/pixelfree_camera/FaceMeshTesselation468.kt";
const lines = fs.readFileSync(p, "utf8").split(/\r?\n/);
const rest = lines.slice(9);
const header = [
  "package com.example.pixelfree_camera",
  "",
  "import java.util.LinkedHashSet",
  "",
  "/**",
  " * TF.js facemesh TRIANGULATION (468 verts). Source:",
  " * https://github.com/tensorflow/tfjs-models/blob/838611c02f51159afdd77469ce67f0e26b7bbb23/facemesh/demo/triangulation.js",
  " * Do not mix with older canonical_face_model.obj tessellation.",
  " */",
  "",
];
fs.writeFileSync(p, header.concat(rest).join("\n"), "utf8");
console.log("ok");
