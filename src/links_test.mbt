///|
test "collect link targets skips fenced code" {
  inspect(
    collect_link_targets(
      "See [guide](./guide.md) and ![img](/assets/a.png).\n```\n[x](./skip.md)\n```\n[ref]: /configuration/\n",
    ).join(" | "),
    content="./guide.md | /assets/a.png | /configuration/",
  )
}

///|
test "check internal links accepts valid targets" {
  let sources : Array[PageSource] = [
    {
      path: "index.md",
      source: "# Home\n\n[Guide](./guide/start.md)\n[zh](/zh/)\n[ext](https://example.com)\n[anchor](#section)\n[asset](/assets/logo.png)\n",
    },
    {
      path: "guide/start.md",
      source: "# Start\n\n[Home](../index.md)\n[abs](/guide/start)\n",
    },
    {
      path: "zh/index.md",
      source: "---\nlang: zh\n---\n# 首页\n\n[首页](/zh/)\n",
    },
  ]
  inspect(check_internal_links(sources, "/").length(), content="0")
}

///|
test "check internal links reports missing markdown and route targets" {
  let sources : Array[PageSource] = [
    {
      path: "index.md",
      source: "# Home\n\n[gone](./missing.md)\n[nowhere](/not-a-page/)\n",
    },
  ]
  inspect(
    check_internal_links(sources, "/").join(" | "),
    content="index.md: broken link ./missing.md | index.md: broken link /not-a-page/",
  )
}

///|
test "check internal links understands base url prefixes and drafts" {
  let sources : Array[PageSource] = [
    {
      path: "index.md",
      source: "# Home\n\n[g](/moonpress/guide/)\n[d](./draft.md)\n",
    },
    { path: "guide.md", source: "# Guide\n" },
    { path: "draft.md", source: "---\ndraft: true\n---\n# Draft\n" },
  ]
  inspect(
    check_internal_links(sources, "/moonpress/").join(" | "),
    content="index.md: broken link ./draft.md",
  )
}

///|
test "collect link targets skips inline code spans" {
  inspect(
    collect_link_targets("`[label](/target)` and [real](./real.md)").join(" | "),
    content="./real.md",
  )
}
