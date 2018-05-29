// checkDeivce (use MobileDetect)
// MobileDetect = require 'mobile-detect'
// node_moduleとしてrequireはビルドが遅いので、HTML側で読み込む
export default function() {
  var html, md;
  md = new MobileDetect(navigator.userAgent);
  html = document.body.parentElement;
  if (md.tablet()) {
    html.classList.add('is-tablet');
  } else if (md.mobile()) {
    html.classList.add('is-mobile');
  } else {
    html.classList.add('is-desktop');
  }
  return md;
};
