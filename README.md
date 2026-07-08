# MoonPress

MoonPress is a MoonBit-first static site and documentation generator. It is designed for MoonBit library authors who want to turn Markdown notes, examples, and package metadata into a small, fast, reusable documentation website.

## Goals

- Generate static documentation sites from Markdown files.
- Provide simple routing, page metadata, navigation, and HTML rendering.
- Keep the core implementation in MoonBit, with a CLI suitable for project automation.
- Offer a polished sample site that can be used as the competition demo.

## Phase 1 Scope

This repository starts with the reusable core model, route helpers, a small Markdown rendering layer, and an initial CLI entry point. The next milestones will add filesystem scanning, front matter parsing, theme assets, local preview, search index generation, and integration tests.

## Usage

```bash
moon run src/cmd/moonpress
```

The default command builds the sample `docs/` directory into `dist/`.

After the JS backend artifact is built, custom input, output, base URL, and preview commands can be used directly with Node:

```bash
node _build/js/debug/build/cmd/moonpress/moonpress.js build docs --out site
node _build/js/debug/build/cmd/moonpress/moonpress.js build docs --out site --base-url https://example.com/moonpress/
node _build/js/debug/build/cmd/moonpress/moonpress.js dev docs --out site --port 8080
node _build/js/debug/build/cmd/moonpress/moonpress.js clean --out site
```

Expected output includes `dist/index.html`, a guide page, `dist/search-index.json`, `dist/sitemap.xml`, copied assets under `dist/assets/`, and `dist/moonpress-manifest.txt`.

The sample site is bilingual. English pages are emitted at the site root, and Chinese pages are emitted under `dist/zh/`. Open `dist/index.html` or `dist/zh/index.html` to try the language switcher.

## Quality Gates

The project is expected to pass the current MoonBit toolchain checks:

```bash
moon check
moon fmt --check
moon info
moon test
```

The CI workflow also attempts the review-required `moon fmt --deny-warn` and `moon info --deny-warn` commands first. If the installed stable MoonBit toolchain does not support those flags yet, it falls back to the current stable equivalents above.

## Publishing

The module name is `hua1104/moonpress`, and the repository field points to `https://github.com/hua1104/moonpress.git`. To publish after logging in to mooncakes.io:

```bash
moon login
moon package
moon publish
```

## Project Status

Competition application phase. The repository is organized as a reusable MoonBit package plus CLI package. The core can plan routes, parse page metadata, render HTML, generate navigation and pager links, produce a search index, generate a sitemap, build bilingual output, write a real `dist/` directory from `docs/`, and serve a local preview through the CLI package.
