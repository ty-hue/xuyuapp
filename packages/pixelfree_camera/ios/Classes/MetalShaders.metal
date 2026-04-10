#include <metal_stdlib>
using namespace metal;

struct VertexOut {
  float4 position [[position]];
  float2 uv;
};

vertex VertexOut beauty_vs(uint vid [[vertex_id]]) {
  const float2 pos[4] = { {-1,-1}, {1,-1}, {-1,1}, {1,1} };
  const float2 uv[4] = { {0,1}, {1,1}, {0,0}, {1,0} };
  VertexOut o;
  o.position = float4(pos[vid], 0, 1);
  o.uv = uv[vid];
  return o;
}

fragment float4 beauty_fs(
  VertexOut in [[stage_in]],
  texture2d<float> tex [[texture(0)]],
  constant float &uBrightness [[buffer(0)]],
  constant float &uSmoothing [[buffer(1)]],
  constant float2 &uFaceCenter [[buffer(2)]],
  constant float2 &uFaceHalf [[buffer(3)]],
  constant float &uHasFace [[buffer(4)]]
) {
  constexpr sampler s(coord::normalized, filter::linear, address::clamp_to_edge);
  float2 uv = in.uv;
  float4 base = tex.sample(s, uv);
  float skinM = 0;
  if (uHasFace > 0.5) {
    float2 h = max(uFaceHalf, float2(0.02));
    float2 d = (uv - uFaceCenter) / h;
    float e = dot(d, d);
    skinM = 1.0 - smoothstep(0.28f, 2.15f, e);
  }
  float lum = dot(base.rgb, float3(0.299, 0.587, 0.114));
  float skinW = smoothstep(0.03, 0.55, lum) * (1.0 - smoothstep(0.94, 0.998, lum));
  float m = skinM * mix(0.68, 1.0, skinW);
  float3 rgb = base.rgb;
  if (uSmoothing > 0.001 && m > 0.01) {
    float rad = 0.008 + uSmoothing * 0.022;
    float3 blur = (
      tex.sample(s, clamp(uv + float2(rad,0), 0.001, 0.999)).rgb +
      tex.sample(s, clamp(uv - float2(rad,0), 0.001, 0.999)).rgb +
      tex.sample(s, clamp(uv + float2(0,rad), 0.001, 0.999)).rgb +
      tex.sample(s, clamp(uv - float2(0,rad), 0.001, 0.999)).rgb +
      base.rgb
    ) * 0.2;
    rgb = mix(rgb, blur, min(1.0, uSmoothing * 1.35) * m);
  }
  float3 beauty = rgb;
  float midW = mix(1.35, 0.75, smoothstep(0.38, 0.88, lum));
  beauty += float3(uBrightness * midW);
  beauty = clamp(beauty, 0.0, 1.0);
  float3 outRgb = mix(rgb, beauty, m);
  return float4(outRgb, base.a);
}
