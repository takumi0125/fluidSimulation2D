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

const float h1 = 0.1;
const float h2 = 0.6;
const float s1 = 0.0;
const float s2 = 0.6;
const float v1 = 0.8;
const float v2 = 0.9;

void main(){
  vec2 uv1 = gl_FragCoord.xy / resolution.xy / texPixelRatio;
  vec2 uv2 = gl_FragCoord.xy / resolution.xy / devicePixelRatio;

  vec4 data = texture2D(dataTex, uv2);
  vec2 velocity = data.xy;
  float pressure = data.z;

  float p1 = pressure * length(velocity) * 0.3;
  float p2 = length(velocity) * 0.4;

  vec4 color = vec4(hsv2rgb(vec3(
    map(1.0 - p2, 0.0, 1.0, h1, h2, false),
    map(p1, 0.0, 1.0, s1, s2, false),
    map(1.0 - p2, 0.0, 1.0, v1, v2, true)
  )), 1.0);

  gl_FragColor = texture2D(outputImgTex, uv2) * color;
}
