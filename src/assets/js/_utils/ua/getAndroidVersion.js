// getAndroidVersion
export default (function() {
  var v;
  v = navigator.appVersion.match(/Android (\d+).(\d+).?(\d+)?;/);
  return [parseInt(v[1], 10), parseInt(v[2], 10), parseInt(v[3] || 0, 10)];
})();
