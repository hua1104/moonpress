///|
test "build sitemap lists page urls" {
  let pages = collect_pages([
    { path: "index.md", source: "---\ntitle: Home\norder: 1\n---\n# Home" },
    { path: "guide.md", source: "---\ntitle: Guide\norder: 2\n---\n# Guide" },
  ])
  inspect(
    build_sitemap(pages, "https://example.com/"),
    content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n  <url><loc>https://example.com/</loc></url>\n  <url><loc>https://example.com/guide</loc></url>\n</urlset>\n",
  )
}
