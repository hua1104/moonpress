---
title: 快速开始
description: 构建第一个 MoonPress 文档站
order: 2
lang: zh
---

# 快速开始

创建 `docs` 目录，编写 Markdown 文件，然后运行 MoonPress CLI 生成 HTML 页面。

## 构建命令

```bash
moon run src/cmd/moonpress -- build docs --out dist
```

部署到 GitHub Pages 项目站点时，需要指定仓库子路径：

```bash
moon run src/cmd/moonpress -- build docs --out dist --base-url /moonpress/
```
