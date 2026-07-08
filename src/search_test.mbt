///|
test "compact text removes front matter and blank lines" {
  inspect(
    compact_text("---\ntitle: Home\n---\n# Home\n\nWelcome."),
    content="# Home Welcome.",
  )
}

///|
test "build search index escapes json strings" {
  let pages = collect_pages([
    {
      path: "index.md",
      source: "---\ntitle: Use \"MoonPress\"\ndescription: A <site>\n---\n# Home",
    },
  ])
  let json = build_search_index(pages, [
    {
      path: "index.md",
      source: "---\ntitle: Use \"MoonPress\"\ndescription: A <site>\n---\n# Home",
    },
  ])
  inspect(
    json,
    content="[{\"title\":\"Use \\\"MoonPress\\\"\",\"route\":\"/\",\"description\":\"A <site>\",\"text\":\"# Home\"}]",
  )
}
