const { ipcRenderer } = require('electron');

// preload.js
window.addEventListener('DOMContentLoaded', () => {
  console.log('I was called from a preload script');

  const observer = new MutationObserver(() => {
    checkMedia();
  });

  observer.observe(document.body, { childList: true, subtree: true });

  function notifyMedia(isPlaying) {
    ipcRenderer.sendToHost('media-status', isPlaying ? 'playing' : 'stopped');
  }

  function checkMedia() {
    const videos = Array.from(document.querySelectorAll('video'));

    for (const video of videos) {
      if (
        !video.paused &&
        !video.muted &&
        video.volume > 0 &&
        video.readyState >= 3
      ) {
        // this is a real playback
        notifyMedia(true);
        return;
      }
    }

    // if none meet the criteria
    notifyMedia(false);
  }

  setInterval(checkMedia, 1000); // fallback polling every second
});
