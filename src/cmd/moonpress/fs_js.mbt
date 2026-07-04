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

extern "js" fn write_output_file(root : String, rel : String, content : String) -> Unit =
  #| function(root, rel, content) {
  #|   const fs = require("fs");
  #|   const path = require("path");
  #|   const out = path.resolve(process.cwd(), root, rel);
  #|   fs.mkdirSync(path.dirname(out), { recursive: true });
  #|   fs.writeFileSync(out, content, "utf8");
  #| }

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

extern "js" fn copy_asset_dir(input_root : String, output_root : String) -> Unit =
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

fn load_sources(root : String) -> Array[@core.PageSource] {
  let pairs = read_markdown_pairs(root)
  let sources : Array[@core.PageSource] = []
  for i = 0; i < pairs.length(); i = i + 2 {
    sources.push({
      path: pairs[i],
      source: pairs[i + 1],
    })
  }
  sources
}

fn write_build_result(out_dir : String, result : @core.BuildResult) -> Unit {
  clean_output_dir(out_dir)
  for file in result.files {
    write_output_file(out_dir, file.path, file.content)
  }
}

fn copy_assets(docs_dir : String, out_dir : String) -> Unit {
  copy_asset_dir(docs_dir, out_dir)
  copy_asset_dir(docs_dir, out_dir + "/zh")
}
