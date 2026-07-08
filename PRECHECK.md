# Precheck Notes

This document maps the pre-acceptance feedback to repository changes.

## 1. MoonBit format and info checks

The project has been migrated from deprecated `moon.mod.json` / `moon.pkg.json` manifests to the current `moon.mod` / `moon.pkg` format.

Current stable toolchain used locally:

```text
moon 0.1.20260703
```

Local passing commands:

```bash
moon fmt --check
moon info
moon check
moon test
```

The current stable toolchain does not expose `moon fmt --deny-warn` or `moon info --deny-warn`. The CI workflow attempts those commands first and falls back to the current stable equivalents only when the toolchain reports that the flags are unsupported.

## 2. CI workflow

GitHub Actions workflow:

```text
.github/workflows/ci.yml
```

It runs:

- `moon check`
- `moon fmt --deny-warn` with stable-toolchain fallback to `moon fmt --check`
- `moon info --deny-warn` with stable-toolchain fallback to `moon info`
- `moon test`
- sample site build

## 3. Mooncakes module metadata

The module metadata has been aligned with the actual GitHub repository:

```text
module: hua1104/moonpress
repository: https://github.com/hua1104/moonpress.git
```

The package can be prepared with:

```bash
moon package
```

Publishing requires the maintainer account:

```bash
moon login
moon publish
```

## 4. README consistency

The README now documents implemented functionality only:

- `build`
- `clean`
- `dev`
- bilingual example site
- search index
- sitemap
- manifest
- asset copying

## 5. Scope and tests

The project now includes:

- bilingual English / Chinese docs
- routing and output planning
- front matter parsing
- Markdown subset rendering
- navigation and pager generation
- search index, sitemap, manifest generation
- Node.js filesystem bridge for CLI build/dev/clean
- 21 passing tests

