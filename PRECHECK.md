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

All local HTML resource, navigation, language, and pager links must start with `/moonpress/`. Both sitemap files must use the same prefix, and files from `docs/assets/` must exist under `site/assets/` and `site/zh/assets/`.
