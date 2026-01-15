(function () {
  // Very small “it works” script.
  // This keeps the site build-less and safe to host as a pure static origin.
  try {
    var now = new Date();
    var yyyy = String(now.getFullYear());
    var mm = String(now.getMonth() + 1).padStart(2, '0');
    var dd = String(now.getDate()).padStart(2, '0');

    // If there is a time element with the generated date, keep it.
    // Otherwise do nothing.
    var time = document.querySelector('time[datetime]');
    if (time && time.getAttribute('datetime') === '2026-01-15') {
      time.textContent = yyyy + '-' + mm + '-' + dd;
      time.setAttribute('datetime', yyyy + '-' + mm + '-' + dd);
    }
  } catch (e) {
    // no-op
  }
})();
