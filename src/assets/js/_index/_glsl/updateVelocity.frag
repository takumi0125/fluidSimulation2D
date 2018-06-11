precision highp float;

uniform float time;
uniform float velocityTimeScale;
uniform float texPixelRatio;
uniform float viscosity;
uniform float forceRadius;
uniform float forceCoefficient;
uniform vec2 resolution;
uniform sampler2D dataTex;
uniform float spirographVertices;
uniform float spirographRadius1;
uniform float spirographRadius2;
uniform float circleTimeScale;

#pragma glslify: PI             = require('../../_utils/glsl/PI.glsl')
#pragma glslify: map            = require('../../_utils/glsl/map.glsl')
#pragma glslify: samplePressure = require('./samplePressure.glsl')
#pragma glslify: snoise2        = require('glsl-noise/simplex/2d')

const float PI_2 = PI * 0.5;

vec2 getPolygonPos(float t, float radius, float rOffset) {
  float an = 2.0 * PI / spirographVertices;
  float t_an = t / an;
  float an_2 = an * 0.5;
  float c = cos(an_2) / cos(an * (t_an - floor(t_an)) - an_2);
  return vec2(
    radius * cos(t + rOffset) * c,
    radius * sin(t + rOffset) * c
  );
}

vec2 getSpirographPos(float t, float s, float r1, float r2, float rOffset) {
  vec2 polygonPos = getPolygonPos(t, r1, rOffset);
  return vec2(
    polygonPos.x + r2 * cos(t * s),
    polygonPos.y + r2 * sin(t * s)
  ) + resolution * 0.5;
}

void addForce(inout vec2 aforce, float t, float t2, float s, float r1, float r2, vec2 offsetPos, float rOffset) {
  float len, d;
  vec2 pos = (getSpirographPos(t, s, r1, r2, rOffset) + offsetPos) * texPixelRatio;
  vec2 pos2 = (getSpirographPos(t2, s, r1, r2, rOffset) + offsetPos) * texPixelRatio;
  len = length(gl_FragCoord.xy - pos) / forceRadius / texPixelRatio;
  d = clamp(1.0 - len, 0.0, 1.0) * forceCoefficient;
  aforce += d * normalize(pos2 - pos);
}

void addForceGroup(inout vec2 aforce, vec2 offsetPos) {
  float r1 = spirographRadius1;
  float r2 = spirographRadius2;
  float s = circleTimeScale;
  float t, t2, rOffset;

  for(int i = 0; i < 60; i++) {
    t = time * 0.004 * velocityTimeScale + float(i) * PI * 2.0 / 60.0;
    t2 = t + 0.0001 * velocityTimeScale;
    rOffset = PI_2 + time * 0.001 * velocityTimeScale;

    addForce(aforce, t, t2, s, r1      , r2, offsetPos,  rOffset);
    addForce(aforce, t, t2, s, r1 * 2.0, r2, offsetPos, -rOffset);
    addForce(aforce, t, t2, s, r1 * 4.0, r2, offsetPos,  rOffset);
  }
}

void main(){
  vec2 r = resolution * texPixelRatio;
  vec2 uv = gl_FragCoord.xy / r;
  vec4 data = texture2D(dataTex, uv);
  vec2 v = data.xy;

  vec2 offsetX = vec2(1.0, 0.0);
  vec2 offsetY = vec2(0.0, 1.0);

  // 上下左右の圧力
  float pLeft   = samplePressure(dataTex, (gl_FragCoord.xy - offsetX) / r, r);
  float pRight  = samplePressure(dataTex, (gl_FragCoord.xy + offsetX) / r, r);
  float pTop    = samplePressure(dataTex, (gl_FragCoord.xy - offsetY) / r, r);
  float pBottom = samplePressure(dataTex, (gl_FragCoord.xy + offsetY) / r, r);

  // 自動
  vec2 aforce = vec2(0.0);
  addForceGroup(aforce, vec2( 0.0, 0.0));
  addForceGroup(aforce, vec2(-0.4, 0.0) * resolution);
  addForceGroup(aforce, vec2( 0.4, 0.0) * resolution);

  v += vec2(pRight - pLeft, pBottom - pTop) * 0.5;
  v += aforce;
  v *= viscosity;
  gl_FragColor = vec4(v, data.zw);
}
