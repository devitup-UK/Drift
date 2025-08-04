document.addEventListener('mouseover', () => {
  if(e.target.closest('ytd-app')) {
    e.stopImmediatePropagation();
    e.preventDefault();
  }
}, { capture: true, passive: false });
