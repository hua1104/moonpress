///|
fn config_summary(config : SiteConfig) -> String {
  config.title +
  " | " +
  config.description +
  " | " +
  config.base_url +
  " | " +
  config.author +
  " | " +
  config.site_url +
  " | " +
  config.default_lang
}

///|
test "parse config json overrides known fields" {
  let json =
    #|{
    #|  "title": "MoonBit Docs",
    #|  "description": "Guides and API reference",
    #|  "base_url": "/moonpress/",
    #|  "author": "hua1104",
    #|  "site_url": "https://example.com",
    #|  "default_lang": "zh"
    #|}
  inspect(
    config_summary(parse_config_json(json, default_config())),
    content="MoonBit Docs | Guides and API reference | /moonpress/ | hua1104 | https://example.com | zh",
  )
}

///|
test "parse config json keeps fallbacks for missing fields" {
  inspect(
    config_summary(
      parse_config_json("{\"title\": \"Only Title\"}", default_config()),
    ),
    content="Only Title | MoonBit documentation site | / |  |  | en",
  )
}

///|
test "parse config json tolerates malformed input" {
  inspect(
    config_summary(parse_config_json("", default_config())),
    content="MoonPress | MoonBit documentation site | / |  |  | en",
  )
  inspect(
    config_summary(parse_config_json("not json at all", default_config())),
    content="MoonPress | MoonBit documentation site | / |  |  | en",
  )
  inspect(
    config_summary(
      parse_config_json("{\"title\": \"Unterminated", default_config()),
    ),
    content="MoonPress | MoonBit documentation site | / |  |  | en",
  )
}

///|
test "parse config json handles escapes and unknown keys" {
  let json =
    #|{"title": "A \"quoted\" name", "unknown": 42, "author": "line\nbreak"}
  let config = parse_config_json(json, default_config())
  inspect(config.title, content="A \"quoted\" name")
  inspect(config.author, content="line\nbreak")
  inspect(config.base_url, content="/")
}
