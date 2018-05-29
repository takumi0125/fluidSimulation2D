// console.log wrapper
export default (function() {
  if (window.console != null) {
    if (window.console.log.bind != null) {
      return window.console.log.bind(window.console);
    } else {
      return window.console.log;
    }
  } else {
    return window.alert;
  }
})();
