precision highp float;

uniform float time;
uniform float devicePixelRatio;
uniform vec2 resolution;
uniform sampler2D dataTex;

const float h1 = 0.88;
const float h2 = 0.92;
const float s1 = 0.42;
const float s2 = 0.52;
const float v1 = 0.8;
const float v2 = 0.9;

#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')
#pragma glslify: map     = require('../../_utils/glsl/map.glsl')
#pragma glslify: hsv2rgb = require('../../_utils/glsl/hsv2rgb.glsl')

void main(){
  vec2 uv = gl_FragCoord.xy / resolution.xy / devicePixelRatio;
  vec4 data = texture2D(dataTex, uv);
  vec2 velocity = data.xy;
  float pressure = data.z;

  float n1 = (snoise2(vec2(
    gl_FragCoord.x / devicePixelRatio * 2.0 - time * 0.1,
    gl_FragCoord.y / devicePixelRatio * 2.0
  ) * 0.002) + 1.0) * 0.5;

  float n2 = (snoise2(vec2(
    gl_FragCoord.x / devicePixelRatio * 2.0 - time * 0.2,
    gl_FragCoord.y / devicePixelRatio * 2.0
  ) * 0.01) + 1.0) * 0.5;

  n1 = max(n1, n2);

  float p1 = pressure * length(velocity) * 0.3;
  float p2 = length(velocity) * 0.8 * 0.3;

  vec4 addColor = vec4(
    hsv2rgb(vec3(
      map(n1, 0.0, 1.0, h1, h2, true),
      0.1,
      map(n1, 0.0, 1.0, 0.0, 0.2, true)
    )), 1.0
  ) * 0.1;

  gl_FragColor = vec4(
    hsv2rgb(vec3(
      map(1.0 - p2, 0.0, 1.0, h1, h2, true),
      map(p1, 0.0, 1.0, s1, s2, true),
      map(1.0 - p2, 0.0, 1.0, v1, v2, true)
    )), 1.0
  ) + addColor;
}
