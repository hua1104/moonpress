# MoonPress

MoonPress is a MoonBit-first static site and documentation generator. It is designed for MoonBit library authors who want to turn Markdown notes, examples, and package metadata into a small, fast, reusable documentation website.

## Goals

- Generate static documentation sites from Markdown files.
- Provide simple routing, page metadata, navigation, and HTML rendering.
- Keep the core implementation in MoonBit, with a CLI suitable for project automation.
- Offer a polished sample site that can be used as the competition demo.

## Phase 1 Scope

This repository starts with the reusable core model, route helpers, a small Markdown rendering layer, and an initial CLI entry point. The next milestones will add filesystem scanning, front matter parsing, theme assets, local preview, search index generation, and integration tests.

## Planned Usage

```bash
moon run src/cmd/moonpress -- build docs --out dist
moon run src/cmd/moonpress -- dev docs --port 8080
```

## Current Demo

The current CLI builds the sample `docs/` directory into `dist/`:

```bash
moon run src/cmd/moonpress
```

Expected output includes `dist/index.html`, a guide page, `dist/search-index.json`, `dist/sitemap.xml`, copied assets under `dist/assets/`, and `dist/moonpress-manifest.txt`.

The sample site is bilingual. English pages are emitted at the site root, and Chinese pages are emitted under `dist/zh/`. Open `dist/index.html` or `dist/zh/index.html` to try the language switcher.

After the JS backend artifact is built, custom input and output paths can be used directly with Node:

```bash
node _build/js/debug/build/cmd/moonpress/moonpress.js build docs --out site
node _build/js/debug/build/cmd/moonpress/moonpress.js build docs --out site --base-url https://example.com/moonpress/
node _build/js/debug/build/cmd/moonpress/moonpress.js clean --out site
```

## Project Status

Competition application phase. The repository is organized as a reusable MoonBit package plus CLI package. The core can already plan routes, parse page metadata, render HTML, generate navigation and pager links, produce a search index, generate a sitemap, build bilingual output, and write a real `dist/` directory from `docs/`.
