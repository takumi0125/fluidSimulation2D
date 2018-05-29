// zero padding
export default function(num, numDigits) {
  var i, j, ref;
  num = '' + num;
  for (i = j = 0, ref = numDigits; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    num = '0' + num;
  }
  return num.slice(-numDigits);
};
