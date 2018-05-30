precision highp float;

uniform float time;
uniform float devicePixelRatio;
uniform float texPixelRatio;
uniform vec2 resolution;
uniform sampler2D dataTex;
uniform sampler2D outputImgTex;

#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')
#pragma glslify: map     = require('../../_utils/glsl/map.glsl')
#pragma glslify: hsv2rgb = require('../../_utils/glsl/hsv2rgb.glsl')
#pragma glslify: sampleVelocity = require('./sampleVelocity.glsl')


vec2 bilerpVelocity(sampler2D tex, vec2 p, vec2 resolution) {
  vec4 ij; // i0, j0, i1, j1
  ij.xy = floor(p - 0.5) + 0.5;
  ij.zw = ij.xy + 1.0;

  vec4 uv = ij / resolution.xyxy;
  vec2 d11 = sampleVelocity(tex, uv.xy, resolution);
  vec2 d21 = sampleVelocity(tex, uv.zy, resolution);
  vec2 d12 = sampleVelocity(tex, uv.xw, resolution);
  vec2 d22 = sampleVelocity(tex, uv.zw, resolution);

  vec2 a = p - ij.xy;

  return mix(mix(d11, d21, a.x), mix(d12, d22, a.x), a.y);
}

vec4 bilerpColor(sampler2D tex, vec2 p, vec2 resolution) {
  vec4 ij; // i0, j0, i1, j1
  ij.xy = floor(p - 0.5) + 0.5;
  ij.zw = ij.xy + 1.0;

  vec4 uv = ij / resolution.xyxy;
  vec3 d11 = texture2D(tex, uv.xy).rgb;
  vec3 d21 = texture2D(tex, uv.zy).rgb;
  vec3 d12 = texture2D(tex, uv.xw).rgb;
  vec3 d22 = texture2D(tex, uv.zw).rgb;

  vec2 a = p - ij.xy;

  return vec4(mix(mix(d11, d21, a.x), mix(d12, d22, a.x), a.y), 1.0);
}

const float h1 = 0.1;
const float h2 = 0.3;
const float s1 = 0.0;
const float s2 = 0.6;
const float v1 = 0.8;
const float v2 = 0.9;

void main(){
  vec2 r = resolution * devicePixelRatio;
  vec2 uv = gl_FragCoord.xy / r;

  vec4 data = texture2D(dataTex, uv);
  vec2 velocity = data.xy;
  float pressure = data.z;
  float vLength = length(velocity);

  vec4 color2 = vec4(hsv2rgb(vec3(
    map(vLength * 0.3, 0.0, 1.0, h1, h2, true) + time * 0.0001,
    map(pressure * 0.3, 0.0, 1.0, s1, s2, true),
    map(1.0 - vLength * pressure * 0.3, 0.0, 1.0, v1, v2, true)
  )), 1.0);

  vec2 p = gl_FragCoord.xy - sampleVelocity(dataTex, uv, r) * 40.0;
  vec4 color = bilerpColor(outputImgTex, p, r);

  gl_FragColor = color * color2;
}
