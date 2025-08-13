async function getSuggestions(query: string): Promise<string[]> {
  if (!query) return [];
  try {
    const response = await fetch(`https://suggestqueries.google.com/complete/search?client=firefox&q=${encodeURIComponent(query)}`);
    if (!response.ok) throw new Error('Network response was not ok');
    const data = await response.json();
    // Only return the top 5 suggestions
    return data[1]?.slice(0, 5) || [];
  } catch (error) {
    console.error('Error fetching Google suggestions:', error);
    return [];
  }
}

export { getSuggestions };
