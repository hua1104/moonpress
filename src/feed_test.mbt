///|
test "build feed lists pages with relative links by default" {
  let pages = collect_pages([
    { path: "index.md", source: "---\ntitle: Home\norder: 1\n---\n# Home" },
    {
      path: "guide.md",
      source: "---\ntitle: Guide\ndescription: Start here\norder: 2\n---\n# Guide",
    },
  ])
  let feed = build_feed_for_lang(default_config(), pages, "en")
  inspect(feed.find("<rss version=\"2.0\"") is Some(_), content="true")
  inspect(feed.find("<title>MoonPress</title>") is Some(_), content="true")
  inspect(
    feed.find(
      "<atom:link href=\"/feed.xml\" rel=\"self\" type=\"application/rss+xml\"/>",
    )
    is Some(_),
    content="true",
  )
  inspect(feed.find("<link>/guide</link>") is Some(_), content="true")
  inspect(
    feed.find("<description>Start here</description>") is Some(_),
    content="true",
  )
}

///|
test "build feed uses absolute urls when site url is configured" {
  let config : SiteConfig = {
    ..default_config(),
    base_url: "/moonpress/",
    site_url: "https://example.com",
  }
  let pages = collect_pages_for_lang(
    [{ path: "zh/index.md", source: "---\ntitle: Home\nlang: zh\n---\n# Home" }],
    "zh",
  )
  let feed = build_feed_for_lang(config, pages, "zh")
  inspect(
    feed.find("<link>https://example.com/moonpress/zh/</link>") is Some(_),
    content="true",
  )
  inspect(feed.find("<language>zh</language>") is Some(_), content="true")
}

///|
test "not found page localizes its message and home link" {
  inspect(
    not_found_body(default_config(), "en"),
    content=(
      #|<h1 class="mp-404-title">Page not found</h1>
      #|<p>The page you requested was moved or never existed.</p>
      #|<p><a class="mp-404-home" href="/">Back to home</a></p>
      #|
    ),
  )
  let zh = not_found_body({ ..default_config(), base_url: "/moonpress/" }, "zh")
  inspect(zh.find("页面不存在") is Some(_), content="true")
  inspect(zh.find("href=\"/moonpress/zh/\"") is Some(_), content="true")
  inspect(not_found_title("zh"), content="页面不存在")
}
