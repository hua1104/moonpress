import assert from "node:assert/strict";
import { once } from "node:events";
import { existsSync } from "node:fs";
import { mkdir, mkdtemp, readFile, readdir, rm, stat, writeFile } from "node:fs/promises";
import { createServer } from "node:net";
import { tmpdir } from "node:os";
import path from "node:path";
import { spawn, spawnSync } from "node:child_process";
import test from "node:test";
import { fileURLToPath } from "node:url";

const repoRoot = fileURLToPath(new URL("../", import.meta.url));
const cliPath = path.join(
  repoRoot,
  "_build",
  "js",
  "debug",
  "build",
  "cmd",
  "moonpress",
  "moonpress.js",
);

async function createFixture() {
  const root = await mkdtemp(path.join(tmpdir(), "moonpress-integration-"));
  const docs = path.join(root, "docs");
  const output = path.join(root, "site");
  await mkdir(path.join(docs, "guide"), { recursive: true });
  await mkdir(path.join(docs, "zh"), { recursive: true });
  await mkdir(path.join(docs, "assets"), { recursive: true });
  await writeFile(
    path.join(docs, "index.md"),
    "---\ntitle: Home\norder: 1\n---\n# Home\n",
  );
  await writeFile(
    path.join(docs, "guide", "start.md"),
    "---\ntitle: Start\norder: 2\n---\n# Start\n",
  );
  await writeFile(
    path.join(docs, "zh", "index.md"),
    "---\ntitle: Home\nlang: zh\norder: 1\n---\n# Home\n",
  );
  await writeFile(path.join(docs, "assets", "custom.css"), "body{color:red}\n");
  return { root, docs, output };
}

function runCli(args, options = {}) {
  const result = spawnSync(process.execPath, [cliPath, ...args], {
    cwd: options.cwd ?? repoRoot,
    encoding: "utf8",
  });
  const expected = options.status ?? 0;
  assert.equal(result.status, expected, result.stderr || result.stdout);
  return result;
}

async function freePort() {
  const server = createServer();
  server.listen(0, "127.0.0.1");
  await once(server, "listening");
  const address = server.address();
  assert.notEqual(address, null);
  const port = address.port;
  server.close();
  await once(server, "close");
  return port;
}

async function waitForPreview(child, expected) {
  let output = "";
  child.stdout.setEncoding("utf8");
  child.stderr.setEncoding("utf8");
  child.stdout.on("data", chunk => {
    output += chunk;
  });
  child.stderr.on("data", chunk => {
    output += chunk;
  });
  const timeoutAt = Date.now() + 10_000;
  while (!output.includes(expected)) {
    if (child.exitCode !== null) {
      assert.fail(`preview exited early:\n${output}`);
    }
    if (Date.now() > timeoutAt) {
      assert.fail(`preview did not start:\n${output}`);
    }
    await new Promise(resolve => setTimeout(resolve, 25));
  }
}

test("CLI build applies base URL, copies assets, and cleans output", async () => {
  const fixture = await createFixture();
  runCli(
    ["build", fixture.docs, "--out", fixture.output, "--base-url", "/moonpress/"],
    { cwd: fixture.root },
  );

  const html = await readFile(path.join(fixture.output, "index.html"), "utf8");
  assert.match(html, /href="\/moonpress\/assets\/moonpress\.css"/);
  assert.match(html, /href="\/moonpress\/guide\/start"/);
  assert.match(html, /href="\/moonpress\/zh\/"/);
  assert.doesNotMatch(html, /href="\/(?:assets|guide|zh)(?:\/|\")/);

  const sitemap = await readFile(path.join(fixture.output, "sitemap.xml"), "utf8");
  assert.match(sitemap, /<loc>\/moonpress\/<\/loc>/);
  assert.match(sitemap, /<loc>\/moonpress\/guide\/start<\/loc>/);
  const zhHtml = await readFile(
    path.join(fixture.output, "zh", "index.html"),
    "utf8",
  );
  const zhSitemap = await readFile(
    path.join(fixture.output, "zh", "sitemap.xml"),
    "utf8",
  );
  assert.match(zhHtml, /href="\/moonpress\/assets\/moonpress\.css"/);
  assert.match(zhHtml, /href="\/moonpress\/zh\/"/);
  assert.match(zhSitemap, /<loc>\/moonpress\/zh\/<\/loc>/);
  assert.equal(
    await readFile(path.join(fixture.output, "assets", "custom.css"), "utf8"),
    "body{color:red}\n",
  );
  assert.equal(
    await readFile(path.join(fixture.output, "zh", "assets", "custom.css"), "utf8"),
    "body{color:red}\n",
  );

  const feed = await readFile(path.join(fixture.output, "feed.xml"), "utf8");
  assert.match(feed, /<rss version="2\.0"/);
  assert.match(feed, /<link>\/moonpress\/guide\/start<\/link>/);
  const zhFeed = await readFile(
    path.join(fixture.output, "zh", "feed.xml"),
    "utf8",
  );
  assert.match(zhFeed, /<link>\/moonpress\/zh\/<\/link>/);

  const notFound = await readFile(
    path.join(fixture.output, "404.html"),
    "utf8",
  );
  assert.match(notFound, /mp-404-title/);
  assert.match(notFound, /href="\/moonpress\/"/);

  runCli(["clean", "--out", fixture.output], { cwd: fixture.root });
  assert.deepEqual(await readdir(fixture.output), []);
});

test("CLI rebuilds incrementally and prunes stale output", async () => {
  const fixture = await createFixture();
  const first = runCli(["build", fixture.docs, "--out", fixture.output], {
    cwd: fixture.root,
  });
  assert.match(first.stdout, /changed [1-9]\d* of \d+ files/);

  const again = runCli(["build", fixture.docs, "--out", fixture.output], {
    cwd: fixture.root,
  });
  assert.match(again.stdout, /changed 0 of \d+ files/);

  const indexPath = path.join(fixture.output, "guide", "start", "index.html");
  const before = (await stat(indexPath)).mtimeMs;
  await writeFile(
    path.join(fixture.docs, "index.md"),
    "---\ntitle: Home\norder: 1\n---\n# Home\n\nUpdated body.\n",
  );
  const rebuilt = runCli(["build", fixture.docs, "--out", fixture.output], {
    cwd: fixture.root,
  });
  assert.match(rebuilt.stdout, /changed [1-9]\d* of \d+ files/);
  assert.equal((await stat(indexPath)).mtimeMs, before);

  await rm(path.join(fixture.docs, "guide", "start.md"));
  runCli(["build", fixture.docs, "--out", fixture.output], {
    cwd: fixture.root,
  });
  assert.equal(existsSync(path.join(fixture.output, "guide")), false);
  assert.ok(existsSync(path.join(fixture.output, "assets", "custom.css")));
});

test("CLI reads moonpress.json and emits SEO metadata", async () => {
  const fixture = await createFixture();
  await writeFile(
    path.join(fixture.root, "moonpress.json"),
    JSON.stringify({
      title: "Fixture Docs",
      description: "Config driven description",
      base_url: "/moonpress/",
      author: "tester",
      site_url: "https://example.com",
    }),
  );

  runCli(["build", fixture.docs, "--out", fixture.output], {
    cwd: fixture.root,
  });

  const html = await readFile(path.join(fixture.output, "index.html"), "utf8");
  assert.match(html, /<title>Home \| Fixture Docs<\/title>/);
  assert.match(
    html,
    /<meta name="description" content="Config driven description">/,
  );
  assert.match(html, /<meta name="author" content="tester">/);
  assert.match(
    html,
    /<link rel="canonical" href="https:\/\/example\.com\/moonpress\/">/,
  );
  assert.match(
    html,
    /<link rel="alternate" hreflang="zh" href="https:\/\/example\.com\/moonpress\/zh\/">/,
  );
  assert.match(html, /href="\/moonpress\/assets\/moonpress\.css"/);

  const robots = await readFile(path.join(fixture.output, "robots.txt"), "utf8");
  assert.match(robots, /Sitemap: https:\/\/example\.com\/moonpress\/sitemap\.xml/);
});

test("CLI flags override config file values", async () => {
  const fixture = await createFixture();
  await writeFile(
    path.join(fixture.root, "moonpress.json"),
    JSON.stringify({ title: "Fixture Docs", base_url: "/from-config/" }),
  );

  runCli(
    ["build", fixture.docs, "--out", fixture.output, "--base-url", "/from-flag/"],
    { cwd: fixture.root },
  );

  const html = await readFile(path.join(fixture.output, "index.html"), "utf8");
  assert.match(html, /href="\/from-flag\/assets\/moonpress\.css"/);
  assert.doesNotMatch(html, /\/from-config\//);
});

test("CLI ships a working search bundle for each language", async () => {
  const fixture = await createFixture();
  runCli(["build", fixture.docs, "--out", fixture.output], {
    cwd: fixture.root,
  });

  const html = await readFile(path.join(fixture.output, "index.html"), "utf8");
  assert.match(html, /src="\/assets\/moonpress-search\.js" defer/);

  const script = await readFile(
    path.join(fixture.output, "assets", "moonpress-search.js"),
    "utf8",
  );
  assert.match(script, /"\/search-index\.json"/);
  assert.match(script, /mp-search-input/);
  assert.match(script, /moonpress-theme/);
  assert.match(script, /mp-copy/);
  assert.match(script, /__moonpress\/reload/);

  const zhScript = await readFile(
    path.join(fixture.output, "zh", "assets", "moonpress-search.js"),
    "utf8",
  );
  assert.match(zhScript, /"\/zh\/search-index\.json"/);

  const index = JSON.parse(
    await readFile(path.join(fixture.output, "search-index.json"), "utf8"),
  );
  assert.ok(index.length > 0);
  assert.ok(index.every(entry => entry.title && entry.route));
});

test("CLI renders the extended Markdown subset", async () => {
  const fixture = await createFixture();
  await writeFile(
    path.join(fixture.docs, "rich.md"),
    [
      "---",
      "title: Rich",
      "order: 9",
      "---",
      "# Rich Content",
      "",
      "Text with **bold**, *italic*, and ![logo](/logo.png).",
      "",
      "> A quotation.",
      "",
      "1. first",
      "2. second",
      "",
      "| Name | Value |",
      "|:-----|------:|",
      "| a    | 1     |",
      "",
      "```moonbit",
      "let x = 1",
      "```",
      "",
      "- [x] shipped",
      "- [ ] pending",
      "",
      "~~old~~ new, see <https://moonbitlang.com> or [ref][mb].",
      "",
      "A claim.[^note]",
      "",
      "[mb]: https://moonbitlang.com",
      "[^note]: Because tests.",
    ].join("\n"),
  );

  runCli(["build", fixture.docs, "--out", fixture.output], {
    cwd: fixture.root,
  });
  const html = await readFile(
    path.join(fixture.output, "rich", "index.html"),
    "utf8",
  );

  assert.match(html, /<h1 id="rich-content">/);
  assert.match(html, /<a class="mp-anchor" href="#rich-content"/);
  assert.match(html, /<strong>bold<\/strong>/);
  assert.match(html, /<em>italic<\/em>/);
  assert.match(html, /<img src="\/logo\.png" alt="logo" loading="lazy">/);
  assert.match(html, /<blockquote>/);
  assert.match(html, /<ol>\s*<li>first<\/li>/);
  assert.match(html, /<th style="text-align:right">Value<\/th>/);
  assert.match(html, /<code class="language-moonbit">/);
  assert.match(html, /<figure class="mp-code" data-lang="moonbit">/);
  assert.match(html, /<span class="mp-tok-keyword">let<\/span>/);
  assert.match(html, /<li class="mp-task"><input type="checkbox" disabled checked>/);
  assert.match(html, /<del>old<\/del>/);
  assert.match(
    html,
    /<a href="https:\/\/moonbitlang\.com" rel="noopener noreferrer" target="_blank">ref<\/a>/,
  );
  assert.match(html, /<sup class="mp-fn-ref" id="fnref-note">/);
  assert.match(html, /<section class="mp-footnotes">/);
});

test("CLI reports usage and runtime errors with distinct exit codes", async () => {
  const fixture = await createFixture();
  const cwd = fixture.root;

  const unknownOption = runCli(["build", fixture.docs, "--nope"], {
    cwd,
    status: 2,
  });
  assert.match(unknownOption.stderr, /unknown option: --nope/);

  const missingValue = runCli(["build", fixture.docs, "--out"], {
    cwd,
    status: 2,
  });
  assert.match(missingValue.stderr, /missing value for --out/);

  const badPort = runCli(["dev", fixture.docs, "--port", "abc"], {
    cwd,
    status: 2,
  });
  assert.match(badPort.stderr, /invalid value for --port: abc/);

  const missingInput = runCli(["build", path.join(fixture.root, "absent")], {
    cwd,
    status: 1,
  });
  assert.match(missingInput.stderr, /input directory not found/);

  const missingConfig = runCli(
    ["build", fixture.docs, "--config", "absent.json"],
    { cwd, status: 1 },
  );
  assert.match(missingConfig.stderr, /config file not found/);

  const help = runCli(["--help"], { cwd });
  assert.match(help.stdout, /Usage:/);
  assert.match(help.stdout, /--base-url/);

  const version = runCli(["version"], { cwd });
  assert.match(version.stdout, /^moonpress \d+\.\d+\.\d+/);
});

test("CLI preview serves a site mounted below a base URL", async () => {
  const fixture = await createFixture();
  const port = await freePort();
  const child = spawn(
    process.execPath,
    [
      cliPath,
      "dev",
      fixture.docs,
      "--out",
      fixture.output,
      "--base-url",
      "/moonpress/",
      "--port",
      String(port),
    ],
    { cwd: fixture.root, stdio: ["ignore", "pipe", "pipe"] },
  );

  try {
    await waitForPreview(child, `preview http://127.0.0.1:${port}/moonpress/`);
    const root = await fetch(`http://127.0.0.1:${port}/moonpress/`);
    const guide = await fetch(
      `http://127.0.0.1:${port}/moonpress/guide/start/`,
    );
    const css = await fetch(
      `http://127.0.0.1:${port}/moonpress/assets/moonpress.css`,
    );
    const missingSlash = await fetch(`http://127.0.0.1:${port}/moonpress`, {
      redirect: "manual",
    });
    const outsideMount = await fetch(`http://127.0.0.1:${port}/`);
    assert.equal(root.status, 200);
    assert.equal(guide.status, 200);
    assert.equal(css.status, 200);
    assert.equal(missingSlash.status, 302);
    assert.equal(missingSlash.headers.get("location"), "/moonpress/");
    assert.equal(outsideMount.status, 404);
  } finally {
    if (child.exitCode === null) {
      const exited = once(child, "exit");
      child.kill();
      await exited;
    }
  }
});

test("CLI dev watches the docs and pushes live reload events", async () => {
  const fixture = await createFixture();
  const port = await freePort();
  const child = spawn(
    process.execPath,
    [cliPath, "dev", fixture.docs, "--out", fixture.output, "--port", String(port)],
    { cwd: fixture.root, stdio: ["ignore", "pipe", "pipe"] },
  );

  const controller = new AbortController();
  try {
    await waitForPreview(child, "watching");
    const stream = await fetch(`http://127.0.0.1:${port}/__moonpress/reload`, {
      signal: controller.signal,
    });
    assert.equal(stream.status, 200);
    assert.match(stream.headers.get("content-type"), /text\/event-stream/);
    const reader = stream.body.getReader();
    const decoder = new TextDecoder();
    let received = decoder.decode((await reader.read()).value);
    assert.match(received, /moonpress-ready/);

    await writeFile(
      path.join(fixture.docs, "index.md"),
      "---\ntitle: Home\norder: 1\n---\n# Home\n\nEdited live.\n",
    );

    const timeoutAt = Date.now() + 10_000;
    while (!received.includes("moonpress-reload")) {
      assert.ok(Date.now() < timeoutAt, `no reload event:\n${received}`);
      const chunk = await Promise.race([
        reader.read().catch(() => null),
        new Promise(resolve => setTimeout(() => resolve(null), 500)),
      ]);
      if (chunk && chunk.value) {
        received += decoder.decode(chunk.value);
      }
    }

    const page = await fetch(`http://127.0.0.1:${port}/`);
    assert.match(await page.text(), /Edited live\./);
  } finally {
    controller.abort();
    if (child.exitCode === null) {
      const exited = once(child, "exit");
      child.kill();
      await exited;
    }
  }
});
