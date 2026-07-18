import assert from "node:assert/strict";
import { once } from "node:events";
import { mkdir, mkdtemp, readFile, readdir, writeFile } from "node:fs/promises";
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

function runCli(args) {
  const result = spawnSync(process.execPath, [cliPath, ...args], {
    cwd: repoRoot,
    encoding: "utf8",
  });
  assert.equal(result.status, 0, result.stderr || result.stdout);
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
  runCli([
    "build",
    fixture.docs,
    "--out",
    fixture.output,
    "--base-url",
    "/moonpress/",
  ]);

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

  runCli(["clean", "--out", fixture.output]);
  assert.deepEqual(await readdir(fixture.output), []);
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
    { cwd: repoRoot, stdio: ["ignore", "pipe", "pipe"] },
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
