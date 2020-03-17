precision highp float;

uniform float texPixelRatio;
uniform float devicePixelRatio;
uniform vec2 resolution;
uniform vec2 texResolution;
uniform sampler2D tex;

#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')
#pragma glslify: map     = require('../../_utils/glsl/map.glsl')
#pragma glslify: hsv2rgb = require('../../_utils/glsl/hsv2rgb.glsl')

void main(){
  float offsetT =  0.0;
  float uvT = gl_FragCoord.y / texResolution.x / texPixelRatio;
  vec2 uv = vec2(
    gl_FragCoord.x / texResolution.x / texPixelRatio - resolution.x * 0.5,
    uvT + offsetT
  );
  uv.x += (step(1.0, mod(float(uvT + offsetT), 2.0)) * uv.x / resolution.x);
  float noiseValue = snoise2(uv * 1.4);

  vec4 color = texture2D(tex, uv);
  color.r = 1.0 - color.a;
  color.g = 1.0 - color.a;
  color.b = 1.0 - color.a;
  color.a = 1.0;
  vec4 addColor = vec4(hsv2rgb(vec3(
    map(noiseValue, -1.0, 1.0, 0.1, 0.4, true),
    map(noiseValue, -1.0, 1.0, 0.0, 0.1, true),
    map(noiseValue, -1.0, 1.0, 0.0, 0.1, true)
  )), 1.0);

  gl_FragColor = color + addColor;
}
