# Acceptance Precheck

Run this checklist with the latest stable MoonBit toolchain and Node.js 20 or newer.

```bash
moon version
node --version
moon clean
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon info
git diff --exit-code -- src/pkg.generated.mbti src/cmd/moonpress/pkg.generated.mbti
moon build --target js src/cmd/moonpress
node --test tests/cli.integration.test.mjs
```

Verify a GitHub Pages-style build manually:

```bash
moon run src/cmd/moonpress -- build docs --out site --base-url /moonpress/
```

Check the generated output:

- All local HTML resource, navigation, language, and pager links must start with `/moonpress/`.
- `site/feed.xml`, `site/zh/feed.xml`, `site/404.html`, and `site/zh/404.html` must exist, and the feed links must carry the same prefix.
- A page with two or more `##` headings must contain an `mp-toc` aside; fenced code blocks must be wrapped in `mp-code` figures with highlighted spans for known languages.
- Rebuilding without edits must report `changed 0 of N files`; deleting a document and rebuilding must remove its output directory.
- `moonpress dev` must print `watching docs`, rebuild on save, and push a `moonpress-reload` event to `/__moonpress/reload` subscribers.
- Both sitemap files must use the same prefix, and files from `docs/assets/` must exist under `site/assets/` and `site/zh/assets/`.
- Every page must contain a `description` meta tag, `og:title`, and, when `site_url` is configured, a `canonical` link plus `hreflang` alternates for `en`, `zh`, and `x-default`.
- `site/assets/moonpress-search.js` and `site/zh/assets/moonpress-search.js` must reference their own `search-index.json`.
- `site/robots.txt` and `site/zh/robots.txt` must point at the matching sitemap.

Verify CLI failure handling:

```bash
moon run src/cmd/moonpress -- build docs --unknown-flag; echo $?   # expects 2
moon run src/cmd/moonpress -- build missing-dir; echo $?           # expects 1
moon run src/cmd/moonpress -- help
```
