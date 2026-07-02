# Commit Plan

This repository can be submitted as 15 meaningful commits. The groups below avoid empty commits and keep each change reviewable.

## Commit 1

`chore: initialize moonpress module`

- `.gitignore`
- `LICENSE`
- `moon.mod.json`
- `src/moon.pkg.json`
- `README.md`

## Commit 2

`docs: add competition application materials`

- `APPLICATION.md`
- `ROADMAP.md`
- `COMMIT_PLAN.md`

## Commit 3

`feat: add core document models`

- `src/model.mbt`
- `src/moonpress.mbt`

## Commit 4

`feat: add route helpers and basic rendering`

- `src/router.mbt`
- `src/render.mbt`
- `src/moonpress_test.mbt`

## Commit 5

`feat: parse front matter metadata`

- `src/frontmatter.mbt`
- tests touching title, description, order, and draft behavior

## Commit 6

`feat: render markdown subset`

- `src/markdown.mbt`
- heading, paragraph, fenced code block, list, link, and inline code tests

## Commit 7

`feat: plan pages from document sources`

- `src/site_plan.mbt`
- `src/site_plan_test.mbt`

## Commit 8

`feat: generate navigation and pager links`

- `src/navigation.mbt`
- `src/navigation_test.mbt`
- `src/pager.mbt`
- `src/pager_test.mbt`

## Commit 9

`feat: build static output files`

- `src/builder.mbt`
- `src/builder_test.mbt`

## Commit 10

`feat: generate search index sitemap and manifest`

- `src/search.mbt`
- `src/search_test.mbt`
- `src/sitemap.mbt`
- `src/sitemap_test.mbt`
- `src/manifest.mbt`
- `src/manifest_test.mbt`

## Commit 11

`feat: add moonpress cli package`

- `src/cmd/moonpress/moon.pkg.json`
- `src/cmd/moonpress/main.mbt`

## Commit 12

`feat: wire cli docs to dist build`

- `src/cmd/moonpress/fs_js.mbt`
- CLI build, clean, output directory, asset copying, and base URL support

## Commit 13

`docs: add sample documentation site`

- `docs/index.md`
- `docs/guide/getting-started.md`
- `docs/architecture.md`
- `docs/configuration.md`
- `docs/assets/moonpress.css`

## Commit 14

`docs: document cli workflow and architecture`

- `README.md`
- `ROADMAP.md`

## Commit 15

`chore: prepare application submission`

- final polish to `APPLICATION.md`
- final `moon check`
- final `moon test`
- verify `moon run src/cmd/moonpress`

