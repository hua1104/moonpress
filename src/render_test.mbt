///|
fn seo_config() -> SiteConfig {
  {
    title: "MoonPress",
    description: "Site description",
    base_url: "/moonpress/",
    author: "hua1104",
    site_url: "https://example.com",
    default_lang: "en",
  }
}

///|
test "canonical url combines site url base url and language" {
  let config = seo_config()
  inspect(
    canonical_url(config, "en", "/guide/start"),
    content="https://example.com/moonpress/guide/start",
  )
  inspect(
    canonical_url(config, "zh", "/guide/start"),
    content="https://example.com/moonpress/zh/guide/start",
  )
  inspect(
    canonical_url(config, "en", "/"),
    content="https://example.com/moonpress/",
  )
  inspect(canonical_url({ ..config, site_url: "" }, "en", "/"), content="")
}

///|
test "page head carries description canonical and hreflang tags" {
  let html = page_shell_with_meta(
    seo_config(),
    {
      title: "Getting Started",
      description: "How to begin",
      lang: "en",
      route: "/guide/start",
      navigation: "",
      footer: "",
      toc: "",
    },
    "<p>body</p>\n",
  )
  inspect(
    html.find("<title>Getting Started | MoonPress</title>") is Some(_),
    content="true",
  )
  inspect(
    html.find("<meta name=\"description\" content=\"How to begin\">") is Some(_),
    content="true",
  )
  inspect(
    html.find(
      "<link rel=\"canonical\" href=\"https://example.com/moonpress/guide/start\">",
    )
    is Some(_),
    content="true",
  )
  inspect(
    html.find(
      "<link rel=\"alternate\" hreflang=\"zh\" href=\"https://example.com/moonpress/zh/guide/start\">",
    )
    is Some(_),
    content="true",
  )
  inspect(
    html.find(
      "<meta property=\"og:title\" content=\"Getting Started | MoonPress\">",
    )
    is Some(_),
    content="true",
  )
  inspect(
    html.find("<meta name=\"author\" content=\"hua1104\">") is Some(_),
    content="true",
  )
}

///|
test "page head falls back to site description and omits canonical" {
  let html = page_shell_with_meta(
    default_config(),
    {
      title: "MoonPress",
      description: "",
      lang: "en",
      route: "/",
      navigation: "",
      footer: "",
      toc: "",
    },
    "",
  )
  inspect(html.find("<title>MoonPress</title>") is Some(_), content="true")
  inspect(
    html.find(
      "<meta name=\"description\" content=\"MoonBit documentation site\">",
    )
    is Some(_),
    content="true",
  )
  inspect(html.find("rel=\"canonical\"") is Some(_), content="false")
  inspect(html.find("<meta name=\"author\"") is Some(_), content="false")
}

///|
test "page head escapes user supplied metadata" {
  let html = page_shell_with_meta(
    { ..default_config(), title: "Docs" },
    {
      title: "\"><script>alert(1)</script>",
      description: "a \"quoted\" value",
      lang: "en",
      route: "/",
      navigation: "",
      footer: "",
      toc: "",
    },
    "",
  )
  inspect(html.find("<script>alert(1)</script>") is Some(_), content="false")
  inspect(
    html.find("content=\"a &quot;quoted&quot; value\"") is Some(_),
    content="true",
  )
}

///|
test "every page links the search bundle" {
  let html = page_shell_with_meta(
    { ..default_config(), base_url: "/moonpress/" },
    {
      title: "Home",
      description: "",
      lang: "en",
      route: "/",
      navigation: "",
      footer: "",
      toc: "",
    },
    "",
  )
  inspect(
    html.find("src=\"/moonpress/assets/moonpress-search.js\"") is Some(_),
    content="true",
  )
}

///|
test "search script targets the localized index" {
  inspect(
    search_script("/moonpress/", "en").find("\"/moonpress/search-index.json\"")
    is Some(_),
    content="true",
  )
  inspect(
    search_script("/moonpress/", "zh").find(
      "\"/moonpress/zh/search-index.json\"",
    )
    is Some(_),
    content="true",
  )
  inspect(
    search_script("/", "zh").find("搜索文档") is Some(_),
    content="true",
  )
}

///|
test "page head declares both color schemes and boots the stored theme" {
  let html = page_shell_with_meta(
    default_config(),
    {
      title: "Home",
      description: "",
      lang: "en",
      route: "/",
      navigation: "",
      footer: "",
      toc: "",
    },
    "",
  )
  inspect(
    html.find("<meta name=\"color-scheme\" content=\"light dark\">") is Some(_),
    content="true",
  )
  inspect(html.find("moonpress-theme") is Some(_), content="true")
  inspect(html.find("data-theme") is Some(_), content="true")
}

///|
test "page shell places the toc in an aside column" {
  let html = page_shell_with_meta(
    default_config(),
    {
      title: "Home",
      description: "",
      lang: "en",
      route: "/",
      navigation: "",
      footer: "",
      toc: "<nav class=\"mp-toc\"></nav>\n",
    },
    "<p>body</p>\n",
  )
  inspect(html.find("<aside class=\"mp-aside\">") is Some(_), content="true")
  inspect(html.find("<div class=\"mp-page\">") is Some(_), content="true")
}

///|
test "site runtime ships theme copy and live reload helpers" {
  let script = search_script("/moonpress/", "en")
  inspect(script.find("mp-theme") is Some(_), content="true")
  inspect(script.find("mp-copy") is Some(_), content="true")
  inspect(
    script.find("\"/moonpress/__moonpress/reload\"") is Some(_),
    content="true",
  )
  let zh = search_script("/", "zh")
  inspect(zh.find("深色模式") is Some(_), content="true")
  inspect(zh.find("复制") is Some(_), content="true")
}
