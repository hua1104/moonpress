///|
pub(all) struct SiteConfig {
  title : String
  description : String
  base_url : String
  author : String
  site_url : String
  default_lang : String
}

///|
pub(all) struct FrontMatter {
  title : String
  description : String
  order : Int
  draft : Bool
}

///|
pub(all) struct Document {
  source_path : String
  route : String
  front_matter : FrontMatter
  body : String
}

///|
pub(all) struct RenderedPage {
  route : String
  title : String
  html : String
}

///|
pub fn default_config() -> SiteConfig {
  {
    title: "MoonPress",
    description: "MoonBit documentation site",
    base_url: "/",
    author: "",
    site_url: "",
    default_lang: "en",
  }
}

///|
pub fn empty_front_matter() -> FrontMatter {
  { title: "", description: "", order: 0, draft: false }
}
