// map
export default function(value, inputMin, inputMax, outputMin, outputMax, clamp = true) {
  var p;
  if (clamp === true) {
    if (value < inputMin) {
      return outputMin;
    }
    if (value > inputMax) {
      return outputMax;
    }
  }
  p = (outputMax - outputMin) / (inputMax - inputMin);
  return ((value - inputMin) * p) + outputMin;
};
