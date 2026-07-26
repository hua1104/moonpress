///|
/// The single runtime bundle shipped with every generated site: the search
/// widget, the theme switch, code block copy buttons, table of contents
/// highlighting, and the local preview live reload client.
pub fn search_script(base_url : String, lang : String) -> String {
  search_widget_script(base_url, lang) + site_runtime_script(base_url, lang)
}

///|
/// Client-side search widget. It is injected into every page and loads the
/// generated `search-index.json` lazily on first interaction.
fn search_widget_script(base_url : String, lang : String) -> String {
  let index_url = with_base_url(
    base_url,
    if lang == "en" {
      "/search-index.json"
    } else {
      "/" + lang + "/search-index.json"
    },
  )
  let placeholder = if lang == "zh" { "搜索文档" } else { "Search docs" }
  let empty = if lang == "zh" { "没有匹配结果" } else { "No results" }
  let template =
    #|(function () {
    #|  var INDEX_URL = "__INDEX_URL__";
    #|  var PLACEHOLDER = "__PLACEHOLDER__";
    #|  var EMPTY = "__EMPTY__";
    #|  var entries = null;
    #|  var loading = null;
    #|
    #|  function loadIndex() {
    #|    if (loading) return loading;
    #|    loading = fetch(INDEX_URL)
    #|      .then(function (res) { return res.ok ? res.json() : []; })
    #|      .then(function (data) { entries = Array.isArray(data) ? data : []; return entries; })
    #|      .catch(function () { entries = []; return entries; });
    #|    return loading;
    #|  }
    #|
    #|  function score(entry, query) {
    #|    var title = (entry.title || "").toLowerCase();
    #|    var description = (entry.description || "").toLowerCase();
    #|    var text = (entry.text || "").toLowerCase();
    #|    if (title.indexOf(query) === 0) return 4;
    #|    if (title.indexOf(query) !== -1) return 3;
    #|    if (description.indexOf(query) !== -1) return 2;
    #|    if (text.indexOf(query) !== -1) return 1;
    #|    return 0;
    #|  }
    #|
    #|  function excerpt(entry, query) {
    #|    var text = entry.text || entry.description || "";
    #|    var at = text.toLowerCase().indexOf(query);
    #|    if (at === -1) return text.slice(0, 120);
    #|    var from = Math.max(0, at - 40);
    #|    return (from > 0 ? "\u2026" : "") + text.slice(from, from + 120);
    #|  }
    #|
    #|  function search(query) {
    #|    var needle = query.trim().toLowerCase();
    #|    if (!needle || !entries) return [];
    #|    return entries
    #|      .map(function (entry) { return { entry: entry, rank: score(entry, needle) }; })
    #|      .filter(function (hit) { return hit.rank > 0; })
    #|      .sort(function (a, b) { return b.rank - a.rank; })
    #|      .slice(0, 10)
    #|      .map(function (hit) { return hit.entry; });
    #|  }
    #|
    #|  function mount() {
    #|    var header = document.querySelector(".mp-header");
    #|    if (!header || document.querySelector(".mp-search")) return;
    #|    var box = document.createElement("div");
    #|    box.className = "mp-search";
    #|    var input = document.createElement("input");
    #|    input.type = "search";
    #|    input.className = "mp-search-input";
    #|    input.setAttribute("aria-label", PLACEHOLDER);
    #|    input.placeholder = PLACEHOLDER;
    #|    var list = document.createElement("ul");
    #|    list.className = "mp-search-results";
    #|    list.hidden = true;
    #|    box.appendChild(input);
    #|    box.appendChild(list);
    #|    header.appendChild(box);
    #|
    #|    function render(results, query) {
    #|      list.textContent = "";
    #|      if (!query.trim()) { list.hidden = true; return; }
    #|      list.hidden = false;
    #|      if (results.length === 0) {
    #|        var none = document.createElement("li");
    #|        none.className = "mp-search-empty";
    #|        none.textContent = EMPTY;
    #|        list.appendChild(none);
    #|        return;
    #|      }
    #|      results.forEach(function (entry) {
    #|        var item = document.createElement("li");
    #|        var link = document.createElement("a");
    #|        link.href = entry.route;
    #|        link.textContent = entry.title;
    #|        var snippet = document.createElement("span");
    #|        snippet.className = "mp-search-excerpt";
    #|        snippet.textContent = excerpt(entry, query.trim().toLowerCase());
    #|        item.appendChild(link);
    #|        item.appendChild(snippet);
    #|        list.appendChild(item);
    #|      });
    #|    }
    #|
    #|    input.addEventListener("focus", loadIndex, { once: true });
    #|    input.addEventListener("input", function () {
    #|      var query = input.value;
    #|      loadIndex().then(function () { render(search(query), query); });
    #|    });
    #|    input.addEventListener("keydown", function (event) {
    #|      if (event.key === "Escape") { input.value = ""; render([], ""); }
    #|    });
    #|    document.addEventListener("click", function (event) {
    #|      if (!box.contains(event.target)) { list.hidden = true; }
    #|    });
    #|  }
    #|
    #|  if (document.readyState === "loading") {
    #|    document.addEventListener("DOMContentLoaded", mount);
    #|  } else {
    #|    mount();
    #|  }
    #|})();
  template
  .replace_all(old="__INDEX_URL__", new=escape_json(index_url))
  .replace_all(old="__PLACEHOLDER__", new=escape_json(placeholder))
  .replace_all(old="__EMPTY__", new=escape_json(empty))
}

///|
/// Progressive enhancements that are independent of the search index: the
/// light/dark theme switch, copy-to-clipboard buttons on fenced code blocks,
/// table of contents highlighting, and the preview live reload client. The
/// live reload client only connects when the page is served from localhost, so
/// deployed sites never open the connection.
fn site_runtime_script(base_url : String, lang : String) -> String {
  let reload_url = with_base_url(base_url, "/__moonpress/reload")
  let copy = if lang == "zh" { "复制" } else { "Copy" }
  let copied = if lang == "zh" { "已复制" } else { "Copied" }
  let dark = if lang == "zh" { "深色模式" } else { "Dark theme" }
  let light = if lang == "zh" { "浅色模式" } else { "Light theme" }
  let template =
    #|
    #|(function () {
    #|  var RELOAD_URL = "__RELOAD_URL__";
    #|  var COPY = "__COPY__";
    #|  var COPIED = "__COPIED__";
    #|  var DARK = "__DARK__";
    #|  var LIGHT = "__LIGHT__";
    #|  var STORAGE_KEY = "moonpress-theme";
    #|
    #|  function storedTheme() {
    #|    try { return localStorage.getItem(STORAGE_KEY); } catch (_) { return null; }
    #|  }
    #|
    #|  function storeTheme(value) {
    #|    try { localStorage.setItem(STORAGE_KEY, value); } catch (_) {}
    #|  }
    #|
    #|  function prefersDark() {
    #|    return typeof matchMedia === "function" &&
    #|      matchMedia("(prefers-color-scheme: dark)").matches;
    #|  }
    #|
    #|  function activeTheme() {
    #|    var stored = storedTheme();
    #|    if (stored === "dark" || stored === "light") return stored;
    #|    return prefersDark() ? "dark" : "light";
    #|  }
    #|
    #|  function applyTheme(theme, button) {
    #|    document.documentElement.setAttribute("data-theme", theme);
    #|    if (button) {
    #|      var next = theme === "dark" ? LIGHT : DARK;
    #|      button.textContent = next;
    #|      button.setAttribute("aria-label", next);
    #|      button.setAttribute("aria-pressed", theme === "dark" ? "true" : "false");
    #|    }
    #|  }
    #|
    #|  function mountTheme() {
    #|    var host = document.querySelector(".mp-lang-switch");
    #|    if (!host || host.querySelector(".mp-theme")) return;
    #|    var button = document.createElement("button");
    #|    button.type = "button";
    #|    button.className = "mp-theme";
    #|    host.insertBefore(button, host.firstChild);
    #|    applyTheme(activeTheme(), button);
    #|    button.addEventListener("click", function () {
    #|      var next = activeTheme() === "dark" ? "light" : "dark";
    #|      storeTheme(next);
    #|      applyTheme(next, button);
    #|    });
    #|  }
    #|
    #|  function mountCopyButtons() {
    #|    var blocks = document.querySelectorAll(".mp-code");
    #|    Array.prototype.forEach.call(blocks, function (block) {
    #|      if (block.querySelector(".mp-copy")) return;
    #|      var code = block.querySelector("code");
    #|      if (!code) return;
    #|      var head = block.querySelector(".mp-code-head");
    #|      if (!head) {
    #|        head = document.createElement("figcaption");
    #|        head.className = "mp-code-head";
    #|        block.insertBefore(head, block.firstChild);
    #|      }
    #|      var button = document.createElement("button");
    #|      button.type = "button";
    #|      button.className = "mp-copy";
    #|      button.textContent = COPY;
    #|      button.setAttribute("aria-label", COPY);
    #|      head.appendChild(button);
    #|      button.addEventListener("click", function () {
    #|        var text = code.textContent || "";
    #|        var done = function () {
    #|          button.textContent = COPIED;
    #|          setTimeout(function () { button.textContent = COPY; }, 1500);
    #|        };
    #|        if (navigator.clipboard && navigator.clipboard.writeText) {
    #|          navigator.clipboard.writeText(text).then(done, function () {});
    #|        } else {
    #|          var area = document.createElement("textarea");
    #|          area.value = text;
    #|          document.body.appendChild(area);
    #|          area.select();
    #|          try { document.execCommand("copy"); done(); } catch (_) {}
    #|          document.body.removeChild(area);
    #|        }
    #|      });
    #|    });
    #|  }
    #|
    #|  function mountToc() {
    #|    var links = document.querySelectorAll(".mp-toc a");
    #|    if (!links.length || typeof IntersectionObserver !== "function") return;
    #|    var byId = {};
    #|    var targets = [];
    #|    Array.prototype.forEach.call(links, function (link) {
    #|      var id = decodeURIComponent((link.getAttribute("href") || "").slice(1));
    #|      var heading = id ? document.getElementById(id) : null;
    #|      if (!heading) return;
    #|      byId[id] = link;
    #|      targets.push(heading);
    #|    });
    #|    if (!targets.length) return;
    #|    var visible = [];
    #|    var observer = new IntersectionObserver(function (records) {
    #|      records.forEach(function (record) {
    #|        var id = record.target.id;
    #|        var at = visible.indexOf(id);
    #|        if (record.isIntersecting && at === -1) visible.push(id);
    #|        if (!record.isIntersecting && at !== -1) visible.splice(at, 1);
    #|      });
    #|      var current = visible[0];
    #|      Array.prototype.forEach.call(links, function (link) {
    #|        link.classList.remove("active");
    #|      });
    #|      if (current && byId[current]) byId[current].classList.add("active");
    #|    }, { rootMargin: "-96px 0px -70% 0px" });
    #|    targets.forEach(function (target) { observer.observe(target); });
    #|  }
    #|
    #|  function mountLiveReload() {
    #|    var host = location.hostname;
    #|    var local = host === "127.0.0.1" || host === "localhost" || host === "[::1]" || host === "::1";
    #|    if (!local || typeof EventSource !== "function") return;
    #|    try {
    #|      var source = new EventSource(RELOAD_URL);
    #|      source.addEventListener("moonpress-reload", function () { location.reload(); });
    #|    } catch (_) {}
    #|  }
    #|
    #|  function mount() {
    #|    mountTheme();
    #|    mountCopyButtons();
    #|    mountToc();
    #|    mountLiveReload();
    #|  }
    #|
    #|  if (document.readyState === "loading") {
    #|    document.addEventListener("DOMContentLoaded", mount);
    #|  } else {
    #|    mount();
    #|  }
    #|})();
  template
  .replace_all(old="__RELOAD_URL__", new=escape_json(reload_url))
  .replace_all(old="__COPY__", new=escape_json(copy))
  .replace_all(old="__COPIED__", new=escape_json(copied))
  .replace_all(old="__DARK__", new=escape_json(dark))
  .replace_all(old="__LIGHT__", new=escape_json(light))
}
