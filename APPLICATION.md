# MoonPress 项目申报材料

## 项目名称

MoonPress：面向 MoonBit 生态的静态文档站生成器

## 项目简介

MoonPress 是一个使用 MoonBit 实现的静态站点与项目文档生成工具，目标是帮助 MoonBit 开源库作者把 Markdown 文档、示例代码和项目元数据快速生成可发布的 HTML 文档站。项目重点不是重复实现 Markdown parser，而是补齐 MoonBit 生态中“文档站构建器”这一工程基础设施能力。

## 项目方向与适用场景

项目方向属于工程基础设施与应用生态。适用场景包括 MoonBit 开源库文档站、课程讲义、教程站、项目主页、API 示例集合，以及竞赛项目展示页。MoonPress 生成静态文件，便于部署到 GitHub Pages、Gitlink Pages 或任意静态文件服务。

## 拟实现的核心功能

- 扫描文档目录并生成路由。
- 解析 Markdown 文件与 front matter 页面元数据。
- 生成 HTML 页面、目录导航、上一篇/下一篇链接。
- 提供默认主题、静态资源复制和搜索索引生成。
- 提供 CLI：`build`、`clean`，后续扩展 `dev`。
- 提供示例站点、测试用例和完整使用文档。

## 原创性与参考项目

本项目为原创项目，会参考成熟生态中静态站点生成器的产品形态与工程经验，例如 Rust 的 mdBook、JavaScript 的 VitePress / Docusaurus，但不会直接移植其代码。项目核心实现、CLI、数据模型和站点生成流程将使用 MoonBit 编写。若后续接入 MoonBit 生态已有 Markdown parser，会以依赖形式复用并明确标注许可证。

## 最终交付

- GitHub 仓库与同步的 Gitlink 仓库。
- 4k-10k 行有效 MoonBit 代码。
- 可运行的 MoonPress CLI。
- 示例文档站与 `docs/` 到 `dist/` 的生成结果。
- 单元测试、集成测试和 benchmark / 示例说明。
- README、路线图、设计说明和参赛总结。

## 当前初始化进展

仓库已完成 MoonBit 模块初始化、核心模型、路由规划、front matter 解析、Markdown 子集渲染、导航、上一篇/下一篇链接、搜索索引、sitemap、manifest、CLI 构建命令、静态资源复制和示例文档站。当前可通过 `moon run src/cmd/moonpress` 从 `docs/` 生成 `dist/`。

项目已加入中英文双语示例站点和语言切换入口，英文页面输出到站点根目录，中文页面输出到 `zh/` 子目录。
