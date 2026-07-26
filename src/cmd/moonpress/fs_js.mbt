///|
extern "js" fn read_markdown_pairs(root : String) -> Array[String] =
  #| function(root) {
  #|   const fs = require("fs");
  #|   const path = require("path");
  #|   const base = path.resolve(process.cwd(), root);
  #|   const result = [];
  #|   function walk(dir) {
  #|     if (!fs.existsSync(dir)) {
  #|       return;
  #|     }
  #|     const entries = fs.readdirSync(dir, { withFileTypes: true });
  #|     entries.sort((a, b) => a.name.localeCompare(b.name));
  #|     for (const entry of entries) {
  #|       const full = path.join(dir, entry.name);
  #|       if (entry.isDirectory()) {
  #|         walk(full);
  #|       } else if (entry.isFile() && entry.name.endsWith(".md")) {
  #|         const rel = path.relative(base, full).replaceAll(path.sep, "/");
  #|         result.push(rel);
  #|         result.push(fs.readFileSync(full, "utf8"));
  #|       }
  #|     }
  #|   }
  #|   walk(base);
  #|   return result;
  #| }

///|
/// Returns the user-supplied CLI arguments, without the runtime and script
/// entries that Node.js places at the front of `process.argv`.
extern "js" fn cli_args() -> Array[String] =
  #| function() {
  #|   return process.argv.slice(2);
  #| }

///|
extern "js" fn read_text_file_raw(path : String) -> String =
  #| function(path) {
  #|   const fs = require("fs");
  #|   const nodePath = require("path");
  #|   const target = nodePath.resolve(process.cwd(), path);
  #|   if (!fs.existsSync(target) || !fs.statSync(target).isFile()) {
  #|     return "\u0000";
  #|   }
  #|   return fs.readFileSync(target, "utf8");
  #| }

///|
fn read_text_file(path : String) -> String? {
  let content = read_text_file_raw(path)
  if content == "\u{0}" {
    None
  } else {
    Some(content)
  }
}

///|
extern "js" fn dir_exists(path : String) -> Bool =
  #| function(path) {
  #|   const fs = require("fs");
  #|   const nodePath = require("path");
  #|   const target = nodePath.resolve(process.cwd(), path);
  #|   return fs.existsSync(target) && fs.statSync(target).isDirectory();
  #| }

///|
extern "js" fn print_error(message : String) -> Unit =
  #| function(message) {
  #|   process.stderr.write("moonpress: " + message + "\n");
  #| }

///|
extern "js" fn exit_with(code : Int) -> Unit =
  #| function(code) {
  #|   process.exit(code);
  #| }

///|
/// Writes a generated file, skipping the write when the file already holds the
/// exact same bytes. Untouched pages keep their modification time, which is
/// what makes `dev` rebuilds cheap for editors and static file servers.
extern "js" fn write_output_file(
  root : String,
  rel : String,
  content : String,
) -> Bool =
  #| function(root, rel, content) {
  #|   const fs = require("fs");
  #|   const path = require("path");
  #|   const out = path.resolve(process.cwd(), root, rel);
  #|   if (fs.existsSync(out)) {
  #|     try {
  #|       if (fs.readFileSync(out, "utf8") === content) {
  #|         return false;
  #|       }
  #|     } catch (_) {}
  #|   }
  #|   fs.mkdirSync(path.dirname(out), { recursive: true });
  #|   fs.writeFileSync(out, content, "utf8");
  #|   return true;
  #| }

///|
/// Removes generated files that are no longer part of the build. Files copied
/// from the documentation `assets/` directory are left alone, and directories
/// that end up empty are removed.
extern "js" fn prune_output_dir(root : String, keep : String) -> Int =
  #| function(root, keep) {
  #|   const fs = require("fs");
  #|   const path = require("path");
  #|   const base = path.resolve(process.cwd(), root);
  #|   if (!fs.existsSync(base)) {
  #|     return 0;
  #|   }
  #|   const wanted = new Set(keep.split("\n").filter(Boolean));
  #|   let removed = 0;
  #|   function walk(dir) {
  #|     let empty = true;
  #|     for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
  #|       const full = path.join(dir, entry.name);
  #|       const rel = path.relative(base, full).split(path.sep).join("/");
  #|       if (entry.isDirectory()) {
  #|         if (entry.name === "assets") {
  #|           empty = false;
  #|           continue;
  #|         }
  #|         if (walk(full)) {
  #|           fs.rmdirSync(full);
  #|         } else {
  #|           empty = false;
  #|         }
  #|       } else if (entry.isFile()) {
  #|         if (wanted.has(rel)) {
  #|           empty = false;
  #|         } else {
  #|           fs.rmSync(full, { force: true });
  #|           removed += 1;
  #|         }
  #|       } else {
  #|         empty = false;
  #|       }
  #|     }
  #|     return empty;
  #|   }
  #|   walk(base);
  #|   return removed;
  #| }

///|
extern "js" fn clean_output_dir(root : String) -> Unit =
  #| function(root) {
  #|   const fs = require("fs");
  #|   const path = require("path");
  #|   const out = path.resolve(process.cwd(), root);
  #|   fs.mkdirSync(out, { recursive: true });
  #|   for (const entry of fs.readdirSync(out)) {
  #|     fs.rmSync(path.join(out, entry), { recursive: true, force: true });
  #|   }
  #| }

///|
extern "js" fn copy_asset_dir(
  input_root : String,
  output_root : String,
) -> Unit =
  #| function(inputRoot, outputRoot) {
  #|   const fs = require("fs");
  #|   const path = require("path");
  #|   const input = path.resolve(process.cwd(), inputRoot, "assets");
  #|   const output = path.resolve(process.cwd(), outputRoot, "assets");
  #|   if (!fs.existsSync(input)) {
  #|     return;
  #|   }
  #|   function copyDir(src, dst) {
  #|     fs.mkdirSync(dst, { recursive: true });
  #|     const entries = fs.readdirSync(src, { withFileTypes: true });
  #|     for (const entry of entries) {
  #|       const from = path.join(src, entry.name);
  #|       const to = path.join(dst, entry.name);
  #|       if (entry.isDirectory()) {
  #|         copyDir(from, to);
  #|       } else if (entry.isFile()) {
  #|         fs.copyFileSync(from, to);
  #|       }
  #|     }
  #|   }
  #|   copyDir(input, output);
  #| }

///|
/// Serves the generated site, watches the documentation directory, rebuilds it
/// on change, and pushes a reload event to every connected preview tab.
extern "js" fn serve_dir(
  root : String,
  port : Int,
  base_url : String,
  watch_dir : String,
  rebuild_args : String,
) -> Unit =
  #| function(root, port, baseUrl, watchDir, rebuildArgs) {
  #|   const fs = require("fs");
  #|   const http = require("http");
  #|   const path = require("path");
  #|   const { spawnSync } = require("child_process");
  #|   const base = path.resolve(process.cwd(), root);
  #|   const types = {
  #|     ".html": "text/html; charset=utf-8",
  #|     ".css": "text/css; charset=utf-8",
  #|     ".js": "text/javascript; charset=utf-8",
  #|     ".json": "application/json; charset=utf-8",
  #|     ".xml": "application/xml; charset=utf-8",
  #|     ".txt": "text/plain; charset=utf-8"
  #|   };
  #|   function basePath(value) {
  #|     let result = value || "/";
  #|     try {
  #|       if (/^https?:\/\//.test(result)) {
  #|         result = new URL(result).pathname;
  #|       }
  #|     } catch (_) {
  #|       result = "/";
  #|     }
  #|     if (!result.startsWith("/")) {
  #|       result = "/" + result;
  #|     }
  #|     while (result.length > 1 && result.endsWith("/")) {
  #|       result = result.slice(0, -1);
  #|     }
  #|     return result;
  #|   }
  #|   const mount = basePath(baseUrl);
  #|   const clients = new Set();
  #|   function broadcastReload() {
  #|     for (const client of clients) {
  #|       try {
  #|         client.write("event: moonpress-reload\ndata: {}\n\n");
  #|       } catch (_) {
  #|         clients.delete(client);
  #|       }
  #|     }
  #|   }
  #|   function rebuild() {
  #|     const args = rebuildArgs.split("\n").filter(Boolean);
  #|     if (args.length === 0) {
  #|       return;
  #|     }
  #|     const result = spawnSync(process.execPath, [process.argv[1], ...args], {
  #|       stdio: ["ignore", "ignore", "inherit"]
  #|     });
  #|     if (result.status === 0) {
  #|       console.log("rebuilt " + root);
  #|       broadcastReload();
  #|     }
  #|   }
  #|   function startWatcher() {
  #|     const target = path.resolve(process.cwd(), watchDir);
  #|     if (!watchDir || !fs.existsSync(target)) {
  #|       return;
  #|     }
  #|     let timer = null;
  #|     try {
  #|       fs.watch(target, { recursive: true }, () => {
  #|         if (timer) {
  #|           clearTimeout(timer);
  #|         }
  #|         timer = setTimeout(() => { timer = null; rebuild(); }, 120);
  #|       });
  #|       console.log("watching " + watchDir);
  #|     } catch (_) {
  #|       console.log("watch is unavailable on this platform; rebuild manually");
  #|     }
  #|   }
  #|   const server = http.createServer((req, res) => {
  #|     let raw = decodeURIComponent((req.url || "/").split("?")[0]);
  #|     if (mount !== "/") {
  #|       if (raw === mount) {
  #|         res.writeHead(302, { "Location": mount + "/" });
  #|         res.end();
  #|         return;
  #|       } else if (raw.startsWith(mount + "/")) {
  #|         raw = raw.slice(mount.length);
  #|       } else {
  #|         res.writeHead(404);
  #|         res.end("Not found");
  #|         return;
  #|       }
  #|     }
  #|     if (raw === "/__moonpress/reload") {
  #|       res.writeHead(200, {
  #|         "Content-Type": "text/event-stream; charset=utf-8",
  #|         "Cache-Control": "no-cache",
  #|         "Connection": "keep-alive"
  #|       });
  #|       res.write("event: moonpress-ready\ndata: {}\n\n");
  #|       clients.add(res);
  #|       req.on("close", () => { clients.delete(res); });
  #|       return;
  #|     }
  #|     let target = path.resolve(base, "." + raw);
  #|     const relative = path.relative(base, target);
  #|     if (relative.startsWith("..") || path.isAbsolute(relative)) {
  #|       res.writeHead(403);
  #|       res.end("Forbidden");
  #|       return;
  #|     }
  #|     if (fs.existsSync(target) && fs.statSync(target).isDirectory()) {
  #|       target = path.join(target, "index.html");
  #|     }
  #|     if (!fs.existsSync(target)) {
  #|       res.writeHead(404);
  #|       res.end("Not found");
  #|       return;
  #|     }
  #|     res.writeHead(200, { "Content-Type": types[path.extname(target)] || "application/octet-stream" });
  #|     fs.createReadStream(target).pipe(res);
  #|   });
  #|   server.listen(port, "127.0.0.1", () => {
  #|     const suffix = mount === "/" ? "/" : mount + "/";
  #|     console.log(`preview http://127.0.0.1:${port}${suffix}`);
  #|     startWatcher();
  #|   });
  #| }

///|
fn load_sources(root : String) -> Array[@core.PageSource] {
  let pairs = read_markdown_pairs(root)
  let sources : Array[@core.PageSource] = []
  for i = 0; i < pairs.length(); i = i + 2 {
    sources.push({ path: pairs[i], source: pairs[i + 1] })
  }
  sources
}

///|
/// Writes every generated file and reports how many of them actually changed.
/// Stale files left over from a previous build are removed afterwards, so the
/// output directory stays a faithful mirror without being wiped on each run.
fn write_build_result(out_dir : String, result : @core.BuildResult) -> Int {
  let paths : Array[String] = []
  let mut changed = 0
  for file in result.files {
    if write_output_file(out_dir, file.path, file.content) {
      changed = changed + 1
    }
    paths.push(file.path)
  }
  prune_output_dir(out_dir, paths.join("\n")) |> ignore
  changed
}

///|
fn copy_assets(docs_dir : String, out_dir : String) -> Unit {
  copy_asset_dir(docs_dir, out_dir)
  copy_asset_dir(docs_dir, out_dir + "/zh")
}

///|
fn start_preview(
  out_dir : String,
  port : Int,
  base_url : String,
  watch_dir : String,
  rebuild_args : String,
) -> Unit {
  serve_dir(out_dir, port, base_url, watch_dir, rebuild_args)
}
