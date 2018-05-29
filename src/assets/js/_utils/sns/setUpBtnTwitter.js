// setUpBtnTwitter
export default function(btn, text, shareURL = '') {
  var url;
  url = 'https://twitter.com/intent/tweet?';
  if (shareURL === '') {
    url += ('text=' + encodeURIComponent(text));
  } else {
    url += ('url=' + encodeURIComponent(shareURL) + '&text=' + encodeURIComponent(text));
  }
  return btn.addEventListener('click', function(e) {
    window.open(url, 'twitterShare', 'width=670,height=400');
    e.preventDefault();
    e.stopImmediatePropagation();
  });
};
f
