// setUpBtnFacebook
export default function(btn, shareURL, description = '') {
  var url;
  url = 'https://www.facebook.com/sharer/sharer.php?&display=popup&u=';
  url += encodeURIComponent(shareURL);
  if (description) {
    url += ('&description=' + encodeURIComponent(description));
  }
  return btn.addEventListener('click', function(e) {
    window.open(url, 'facebookShare', 'width=670,height=400');
    e.preventDefault();
    e.stopImmediatePropagation();
  });
};
