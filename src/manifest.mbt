pub fn build_manifest(result : BuildResult) -> String {
  let mut text = "MoonPress Build Manifest\n"
  text = text + "pages: " + result.page_count.to_string() + "\n"
  text = text + "files:\n"
  for file in result.files {
    text = text + "- " + file.path + "\n"
  }
  text
}

