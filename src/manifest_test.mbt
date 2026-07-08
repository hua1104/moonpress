///|
test "build manifest lists emitted files" {
  let result : BuildResult = {
    page_count: 1,
    files: [
      { path: "index.html", content: "<h1>Home</h1>" },
      { path: "search-index.json", content: "[]" },
      { path: "sitemap.xml", content: "<urlset></urlset>" },
    ],
  }
  let manifest = build_manifest(result)
  inspect(
    manifest,
    content="MoonPress Build Manifest\npages: 1\nfiles:\n- index.html\n- search-index.json\n- sitemap.xml\n",
  )
}
