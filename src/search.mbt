///|
pub(all) struct SearchEntry {
  title : String
  route : String
  description : String
  text : String
}

///|
pub fn build_search_index(
  pages : Array[PagePlan],
  sources : Array[PageSource],
) -> String {
  let mut json = "["
  let mut first = true
  for page in pages {
    if first {
      first = false
    } else {
      json = json + ","
    }
    json = json +
      search_entry_json({
        title: page.title,
        route: page.route,
        description: page.description,
        text: compact_text(source_for_path(sources, page.source_path)),
      })
  }
  json + "]"
}

///|
pub fn search_entry_json(entry : SearchEntry) -> String {
  "{" +
  "\"title\":\"" +
  escape_json(entry.title) +
  "\"," +
  "\"route\":\"" +
  escape_json(entry.route) +
  "\"," +
  "\"description\":\"" +
  escape_json(entry.description) +
  "\"," +
  "\"text\":\"" +
  escape_json(entry.text) +
  "\"" +
  "}"
}

///|
pub fn compact_text(input : String) -> String {
  let mut text = ""
  let body = strip_front_matter(input)
  for line in body.split("\n") {
    let cleaned = line.trim().to_owned()
    if cleaned != "" {
      if text != "" {
        text = text + " "
      }
      text = text + cleaned
    }
  }
  text
}

///|
pub fn escape_json(input : String) -> String {
  input
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="\"", new="\\\"")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\r", new="\\r")
  .replace_all(old="\t", new="\\t")
}

///|
fn source_for_path(sources : Array[PageSource], path : String) -> String {
  for source in sources {
    if source.path == path {
      return source.source
    }
  }
  ""
}
