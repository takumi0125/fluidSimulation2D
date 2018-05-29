precision highp float;

uniform float texPixelRatio;
uniform vec2 resolution;
uniform sampler2D dataTex;
uniform sampler2D texture;

#pragma glslify: sampleTexture = require('./sampleTexture.glsl')

void main(){
  vec2 r = resolution * texPixelRatio;
  vec2 v = texture2D(dataTex, gl_FragCoord.xy / r).xy;
  gl_FragColor = sampleTexture(texture, (gl_FragCoord.xy - v) / r, r);
}
