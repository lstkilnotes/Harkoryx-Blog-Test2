# AGENTS.md — AI 编辑指引

> 本文件是 AI Agent 的入口文档。详细工作流见 [`.ai/WORKFLOW.md`](.ai/WORKFLOW.md)

---

## Astro 开发指南（Firefly 版）

When starting the dev server, use background mode:

```
pnpm dev
```

Full documentation: https://docs.astro.build

Consult these guides before working on related tasks:

- [Adding pages, dynamic routes, or middleware](https://docs.astro.build/en/guides/routing/)
- [Working with Astro components](https://docs.astro.build/en/basics/astro-components/)
- [Adding or managing content](https://docs.astro.build/en/guides/content-collections/)
- [Adding styles or using Tailwind](https://docs.astro.build/en/guides/styling/)

**Firefly 专属文档**：
- [Firefly 使用文档](https://docs-firefly.cuteleaf.cn/)
- [Firefly 布局系统详解](https://firefly.cuteleaf.cn/posts/firefly-layout-system/)
- 本项目 `CLAUDE.md` 包含完整架构说明

---

## ⚠️ 核心规则

1. **绝不直接在 `main` 分支编辑** — 所有改动经分支 → 验证 → PR → 主人审核 → 合并
2. **绝不自行合并 PR** — 合并权只在主人手中
3. **每次编辑前必须初始化** — 运行 `./scripts/blog-init.sh <prefix> <type> <name>`

## 包管理器

**必须使用 pnpm**（Firefly 强制要求，`preinstall` 脚本会拦截 npm/yarn）。

```bash
pnpm install          # 安装依赖
pnpm dev              # 开发服务器
pnpm run build        # 生产构建（含 icons → LQIPs → Astro → Pagefind）
pnpm run check        # 类型检查
pnpm run new-post <f> # 创建新文章
pnpm run format       # Biome 格式化
pnpm run lint         # Biome lint + 自动修复
```

## 分支前缀

| Agent | 前缀 | 示例 |
|-------|------|------|
| 绫 (main) | `aya/` | `aya/content/my-article` |
| 萌華 (spicy_leisure) | `moka/` | `moka/feat/add-tags` |
| 塞娜 (basic_exp) | `sena/` | `sena/fix/rss-link` |
| 主人 | `owner/` | `owner/content/my-article` |

## 文章 Frontmatter

Firefly 的文章放在 `src/content/posts/` 下（不是 `src/content/blog/`），frontmatter 格式：

```yaml
---
title: string          # 必填
published: date        # 必填，如 2026-07-04
description: string    # 可选，默认 ""
image: string          # 可选，封面图路径，或 "api" 随机封面
tags: [string]         # 可选，默认 []
category: string|null  # 可选，默认 ""
draft: boolean         # 可选，默认 false
pinned: boolean        # 可选，默认 false
comment: boolean       # 可选，默认 true
lang: string           # 可选，默认 ""（与站点语言不同时设置）
password: string       # 可选，加密文章
passwordHint: string   # 可选，密码提示
---
```

创建新文章推荐使用：`pnpm run new-post <filename>`

## 快速开始

```bash
# 初始化（必须）
./scripts/blog-init.sh <prefix> <type> <name>

# 编辑后验证
pnpm run check && pnpm run build

# 提交 + 推送
git add -A && git commit -m "<type>: <描述>"
git push -u origin <branch-name>

# 创建 PR，通知主人审核 ⛔
```

## 详细文档

- **完整工作流**：[`.ai/WORKFLOW.md`](.ai/WORKFLOW.md) — 初始化流程、安全防护、冲突处理、worktree 管理
- **Firefly 架构**：`CLAUDE.md` — 完整技术架构说明
- **Astro 开发文档**：https://docs.astro.build
