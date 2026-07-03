#!/bin/bash
# blog-init.sh — 博客编辑初始化脚本 (Firefly 版)
# 用法: ./blog-init.sh <prefix> <type> <name>
#   prefix: aya / moka / sena / owner
#   type:   content / feat / fix / style
#   name:   分支名（如 my-article, add-tags）
# 示例: ./blog-init.sh aya content my-first-article

set -e

REPO=/root/user_documents/Long_Term_Projects/Personal_Blog_Test/Harkoryx-Blog-Test2

# --- 参数检查 ---
if [ $# -ne 3 ]; then
    echo "用法: $0 <prefix> <type> <name>"
    echo "  prefix: aya / moka / sena / owner"
    echo "  type:   content / feat / fix / style / refactor / chore"
    echo "  name:   分支名"
    echo ""
    echo "示例: $0 aya content my-first-article"
    exit 1
fi

PREFIX="$1"
TYPE="$2"
NAME="$3"
BRANCH="${PREFIX}/${TYPE}/${NAME}"

# 验证 prefix
case "$PREFIX" in
    aya|moka|sena|owner) ;;
    *) echo "❌ 无效 prefix: $PREFIX（应为 aya/moka/sena/owner）"; exit 1 ;;
esac

# 验证 type
case "$TYPE" in
    content|feat|fix|style|refactor|chore) ;;
    *) echo "❌ 无效 type: $TYPE（应为 content/feat/fix/style/refactor/chore）"; exit 1 ;;
esac

# --- 确定工作目录和待命分支 ---
case "$PREFIX" in
    owner) WORKDIR="$REPO"; IDLE_BRANCH="main" ;;
    aya)   WORKDIR="$REPO/worktrees/aya"; IDLE_BRANCH="aya/work" ;;
    moka)  WORKDIR="$REPO/worktrees/moka"; IDLE_BRANCH="moka/work" ;;
    sena)  WORKDIR="$REPO/worktrees/sena"; IDLE_BRANCH="sena/work" ;;
esac

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Harkoryx Blog 编辑初始化 (Firefly)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- Step 1: 进入工作目录 ---
echo "📁 工作目录: $WORKDIR"
cd "$WORKDIR"

# --- Step 2: 检查工作区状态 ---
echo ""
echo "🔍 Step 1/7: 检查工作区状态..."
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "⚠️  工作区有未提交的改动："
    git status --short
    echo ""
    echo "请先处理以上改动，然后再运行初始化。"
    echo "  继续: 跳过初始化，直接在当前分支工作"
    echo "  放弃: git checkout ."
    echo "  保存: git add -A && git commit -m 'WIP'"
    exit 1
fi
echo "✅ 工作区干净"

# --- Step 3: 切回待命分支 ---
echo ""
echo "🔄 Step 2/7: 切回待命分支 $IDLE_BRANCH..."
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$IDLE_BRANCH" ]; then
    echo "  当前在 $CURRENT_BRANCH，切回 $IDLE_BRANCH"
    git checkout "$IDLE_BRANCH"
else
    echo "  已在 $IDLE_BRANCH"
fi
echo "✅ 已在待命分支"

# --- Step 4: 同步远程 ---
echo ""
echo "🔄 Step 3/7: 同步远程 main..."
git fetch origin main
echo "✅ 已获取最新 origin/main"

# --- Step 5: 创建分支 ---
echo ""
echo "🌿 Step 4/7: 创建分支 $BRANCH (基于 origin/main)..."
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    echo "⚠️  分支 $BRANCH 已存在！"
    echo "  如果要继续上次的工作: git checkout $BRANCH"
    echo "  如果要重新开始: 先删除旧分支 git branch -D $BRANCH"
    exit 1
fi
git checkout -b "$BRANCH" origin/main
echo "✅ 已创建并切换到分支 $BRANCH"

# --- Step 6: 确认依赖 ---
echo ""
echo "📦 Step 5/7: 确认依赖..."
if [ ! -d "node_modules" ]; then
    echo "安装依赖中..."
    pnpm install
fi
echo "✅ 依赖就绪"

# --- Step 7: 类型检查 + 构建验证基线 ---
echo ""
echo "🔍 Step 6/7: 类型检查基线..."
CHECK_OUTPUT=$(pnpm astro check 2>&1)
CHECK_EXIT_CODE=${PIPESTATUS[0]:-$?}
if [ $CHECK_EXIT_CODE -eq 0 ]; then
    echo "✅ 类型检查通过"
else
    echo "❌ 类型检查失败！"
    echo "$CHECK_OUTPUT" | tail -5
    git checkout "$IDLE_BRANCH"
    git branch -d "$BRANCH" 2>/dev/null
    exit 1
fi

echo ""
echo "🏗️  Step 7/7: 构建验证基线..."
BUILD_OUTPUT=$(pnpm run build 2>&1)
BUILD_EXIT_CODE=${PIPESTATUS[0]:-$?}
if [ $BUILD_EXIT_CODE -eq 0 ] && echo "$BUILD_OUTPUT" | tail -1 | grep -qE "Complete|built in|done"; then
    echo "✅ 基线构建通过"
else
    echo "❌ 基线构建失败！环境可能有问题，不应继续编辑。"
    echo "$BUILD_OUTPUT" | tail -5
    # 切回待命分支，清理
    git checkout "$IDLE_BRANCH"
    git branch -d "$BRANCH" 2>/dev/null
    exit 1
fi

# --- 完成 ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ 初始化完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  分支: $BRANCH"
echo "  目录: $WORKDIR"
echo ""
echo "  现在可以开始编辑了。"
echo "  完成后运行:"
echo "    pnpm run check && pnpm run build  # 验证"
echo "    git add -A && git commit -m '$TYPE: <描述>'"
echo "    git push -u origin $BRANCH"
echo "    # 然后创建 PR，通知主人审核"
echo ""
