---
title: 架构设计
description: MoonPress 如何把文档转换成静态站点
order: 3
lang: zh
---

# 架构设计

MoonPress 分为可复用核心库和 CLI 包两部分。

## 核心库

- `frontmatter.mbt` 读取页面元数据。
- `router.mbt` 把 Markdown 路径映射为文档路由。
- `site_plan.mbt` 生成排序后的页面计划。
- `markdown.mbt` 渲染 Markdown 子集。
- `navigation.mbt` 和 `pager.mbt` 生成浏览链接。
- `builder.mbt` 输出 HTML、搜索索引、sitemap 和 manifest。

## CLI 包

CLI 包负责扫描 `docs/`、复制静态资源、写入 `dist/`，并提供清理命令。

