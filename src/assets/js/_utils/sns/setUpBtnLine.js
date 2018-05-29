// setUpBtnLine
export default function(btn, text, shareURL = '') {
  var url;
  url = 'http://line.me/msg/text/?';
  if (shareURL === '') {
    url += encodeURIComponent(text);
  } else {
    url += (encodeURIComponent(text) + "\n" + encodeURIComponent(shareURL));
  }
  return btn.addEventListener('click', function(e) {
    window.open(url, 'lineShare');
    e.preventDefault();
    e.stopImmediatePropagation();
  });
};
