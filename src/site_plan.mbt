pub(all) struct PageSource {
  path : String
  source : String
}

pub(all) struct PagePlan {
  source_path : String
  route : String
  output_path : String
  title : String
  description : String
  order : Int
  lang : String
  draft : Bool
}

pub fn plan_page(path : String, source : String) -> PagePlan {
  let title = read_title(source)
  let lang = read_lang(source)
  let route_path = source_path_for_route(path, lang)
  {
    source_path: path,
    route: normalize_route(route_path),
    output_path: route_to_output_path(normalize_route(route_path)),
    title: if title == "" { fallback_title(path) } else { title },
    description: read_description(source),
    order: read_order(source),
    lang,
    draft: read_draft(source),
  }
}

pub fn collect_pages(sources : Array[PageSource]) -> Array[PagePlan] {
  let pages : Array[PagePlan] = []
  for source in sources {
    let page = plan_page(source.path, source.source)
    if !page.draft {
      pages.push(page)
    }
  }
  pages.mut_view().sort_by(compare_page_plan)
  pages
}

pub fn collect_pages_for_lang(
  sources : Array[PageSource],
  lang : String
) -> Array[PagePlan] {
  let pages : Array[PagePlan] = []
  for source in sources {
    let page = plan_page(source.path, source.source)
    if !page.draft && page.lang == lang {
      pages.push(page)
    }
  }
  pages.mut_view().sort_by(compare_page_plan)
  pages
}

fn compare_page_plan(a : PagePlan, b : PagePlan) -> Int {
  let order_cmp = a.order.compare(b.order)
  if order_cmp != 0 {
    order_cmp
  } else {
    a.route.compare(b.route)
  }
}

fn fallback_title(path : String) -> String {
  let route = normalize_route(path)
  if route == "/" {
    "Home"
  } else {
    let parts = route.split("/")
    let mut title = ""
    for part in parts {
      let text = part.trim().to_owned()
      if text != "" {
        title = text
      }
    }
    if title == "" { "Untitled" } else { title }
  }
}

fn source_path_for_route(path : String, lang : String) -> String {
  let prefix = lang + "/"
  if lang != "en" && path.has_prefix(prefix) {
    path[prefix.length():].to_owned()
  } else {
    path
  }
}
