export function resolveUrl(input: string): string {
  const trimmed = input.trim();

  if (/^https?:\/\//i.test(trimmed)) {
    return trimmed;
  }

  if (/^file:(\/\/)?/i.test(trimmed) || /^[a-zA-Z]:\\/.test(trimmed)) {
    return `file://${trimmed.replace(/\\/g, '/')}`;
  }

  if (/^\d{1,3}(\.\d{1,3}){3}$/.test(trimmed)) {
    return `http://${trimmed}`;
  }

  if (/^((www\.)?[a-zA-Z0-9-]+\.[a-z]{2,})(\/.*)?$/i.test(trimmed)) {
    return `http://${trimmed}`;
  }

  const encoded = encodeURIComponent(trimmed);
  return `https://www.google.com/search?q=${encoded}`;
}

export function displayUrl(url: string | undefined): string {
  if (!url) return 'Search or Enter URL...';

  try {
    const parsedUrl = new URL(url);
    // Return the hostname and pathname, or just the hostname if no pathname
    return parsedUrl.hostname.replace(/^www\./, '');
  } catch (e) {
    // If URL parsing fails, return the original URL
    return url;
  }
}
