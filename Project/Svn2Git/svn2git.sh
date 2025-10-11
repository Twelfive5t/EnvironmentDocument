#!/usr/bin/env bash
set -euo pipefail

# ================== 可配置参数 ==================
# SVN 仓库基础地址
SVN_BASE_URL="file:///opt/test/svn_repository"

# 主干路径（必须）
TRUNK="trunk"

# 分支路径（可为空）
# 支持多个分支路径，用空格分隔
BRANCH="branches Feature"

# 作者邮箱域
EMAIL_DOMAIN="fscut.com"

# 输出作者映射文件
AUTHORS_FILE="authors.txt"

# git svn clone 目标目录（留空表示自动命名）
TARGET_DIR="svn_test2"

# Git 远程仓库地址（留空则不推送）
GIT_REMOTE_URL="https://git.fscut.com/rtos/tools/svn2git.git"

# Git Hooks 目录路径（留空则不配置，相对或绝对路径）
GITHOOKS_DIR=".githooks"

# =================================================

# 全局变量
REPO_DIR=""

# ============== 工具函数 ==============

log() {
    echo "[$(date +%H:%M:%S)] $*"
}

error() {
    echo "[错误] $*" >&2
    exit 1
}

check_dependencies() {
    command -v svn >/dev/null 2>&1 || error "缺少 svn 命令，请执行: apt install subversion"
    command -v git >/dev/null 2>&1 || error "缺少 git 命令，请执行: apt install git"
    git svn --version >/dev/null 2>&1 || error "缺少 git-svn 支持，请执行: apt install git-svn"
}

determine_repo_dir() {
    if [[ -n "${TARGET_DIR}" ]]; then
        REPO_DIR="$TARGET_DIR"
    else
        REPO_DIR=$(basename "$SVN_URL")
    fi
}

# ============== SVN 相关 ==============

build_svn_url() {
    if [[ -n "${BRANCH}" ]]; then
        SVN_URL="$SVN_BASE_URL"
        log "使用标准 SVN 布局: $SVN_URL (trunk: $TRUNK, branches: $BRANCH)"
    else
        SVN_URL="$SVN_BASE_URL/$TRUNK"
        log "只克隆主干: $SVN_URL"
    fi
}

extract_authors() {
    log "1) 提取作者列表..."

    local tmp_authors_raw
    tmp_authors_raw=$(mktemp /tmp/authors_raw.XXXXXX)

    svn log "$SVN_URL" --quiet |
        awk -F'|' '/^r[0-9]+/ {
            a=$2
            gsub(/^[ \t]+|[ \t]+$/, "", a)
            if (a != "") print a
        }' |
        sort -u >"$tmp_authors_raw"

    local count
    count=$(wc -l <"$tmp_authors_raw" | tr -d ' ')
    log "   收集到 $count 个唯一作者"

    log "2) 生成 $AUTHORS_FILE ..."
    awk -v domain="$EMAIL_DOMAIN" 'NF {
        user=$1
        gsub(/^[ \t]+|[ \t]+$/, "", user)
        if (user != "")
            printf "%s = %s <%s@%s>\n", user, user, user, domain
    }' "$tmp_authors_raw" | sort -u >"$AUTHORS_FILE"

    rm -f "$tmp_authors_raw"
    log "   已生成 $AUTHORS_FILE"
    echo
}

# ============== Git SVN 克隆 ==============

clone_with_branches() {
    log "   使用 git svn init 方式以支持多分支路径..."

    local init_args=(git svn init "$SVN_URL" --trunk="$TRUNK")
    [[ -n "${TARGET_DIR}" ]] && init_args+=("$TARGET_DIR")

    "${init_args[@]}"
    cd "$REPO_DIR"

    # 设置默认分支为 main
    git symbolic-ref HEAD refs/heads/main

    # 拷贝 authors.txt 到仓库目录
    cp "../$AUTHORS_FILE" .
    log "   已拷贝 $AUTHORS_FILE 到仓库目录"

    # 配置 git svn 使用作者映射文件
    git config svn.authorsfile "$AUTHORS_FILE"
    log "   已配置 git svn 使用 $AUTHORS_FILE"

    # 配置分支路径，保留完整路径
    for branch_path in $BRANCH; do
        log "   配置分支路径: $branch_path"
        git config --add svn-remote.svn.branches "$branch_path/*:refs/remotes/$branch_path/*"
    done

    log "   执行 git svn fetch ..."
    git svn fetch

    cd - >/dev/null
}

clone_trunk_only() {
    local clone_cmd=(git svn clone "$SVN_URL" --authors-file="$AUTHORS_FILE")
    [[ -n "${TARGET_DIR}" ]] && clone_cmd+=("$TARGET_DIR")

    log "   执行命令: ${clone_cmd[*]}"
    echo
    "${clone_cmd[@]}"

    # 设置默认分支为 main
    cd "$REPO_DIR"
    git symbolic-ref HEAD refs/heads/main

    # 拷贝 authors.txt 到仓库目录
    cp "../$AUTHORS_FILE" .
    log "   已拷贝 $AUTHORS_FILE 到仓库目录"

    # 配置 git svn 使用作者映射文件
    git config svn.authorsfile "$AUTHORS_FILE"
    log "   已配置 git svn 使用 $AUTHORS_FILE"

    cd - >/dev/null
}

perform_git_svn_clone() {
    log "3) 开始 git svn clone ..."

    determine_repo_dir

    if [[ -n "${BRANCH}" ]]; then
        clone_with_branches
    else
        clone_trunk_only
    fi

    echo
    log "完成 SVN 到 Git 的转换。"
}

# ============== Git 推送 ==============

check_remote_repository() {
    log "   检查远程仓库状态: $GIT_REMOTE_URL"

    if ! git ls-remote "$GIT_REMOTE_URL" HEAD &>/dev/null; then
        log "   ⚠️  无法连接到远程仓库，请检查 URL 和网络连接"
        return 1
    fi

    local remote_refs
    remote_refs=$(git ls-remote "$GIT_REMOTE_URL" 2>/dev/null | wc -l)

    if [[ $remote_refs -gt 0 ]]; then
        echo "   ⚠️  警告: 远程仓库不为空 (发现 $remote_refs 个引用)"
        echo "   为避免冲突，建议使用空仓库。是否继续推送? (yes/no)"
        read -r response
        if [[ "$response" != "yes" ]]; then
            log "   已取消推送操作"
            return 1
        fi
    else
        log "   ✓ 远程仓库为空，可以安全推送"
    fi

    return 0
}

setup_remote() {
    log "   添加远程仓库..."
    if git remote add origin "$GIT_REMOTE_URL" 2>/dev/null; then
        log "   ✓ 远程仓库添加成功"
    else
        log "   远程仓库已存在，更新 URL..."
        git remote set-url origin "$GIT_REMOTE_URL"
    fi
}

create_local_branches() {
    log "   创建本地分支（保留完整路径）..."

    # 构建正则表达式，匹配所有配置的分支路径
    local branch_pattern=""
    for branch_path in $BRANCH; do
        if [[ -z "$branch_pattern" ]]; then
            branch_pattern="$branch_path/"
        else
            branch_pattern="$branch_pattern|$branch_path/"
        fi
    done

    if [[ -n "$branch_pattern" ]]; then
        git branch -r | grep -E "($branch_pattern)" | sed 's|^[[:space:]]*||' | while read -r remote_branch; do
            local branch_name="$remote_branch"
            log "   创建本地分支: $branch_name"
            git branch "$branch_name" "$remote_branch" 2>/dev/null || true
        done
    fi
}

push_to_remote() {
    log "4) 推送到远程 Git 仓库..."

    cd "$REPO_DIR"

    if ! check_remote_repository; then
        cd - >/dev/null
        return 1
    fi

    setup_remote

    # 推送主分支
    log "   推送主分支 main..."
    git push -u origin main

    # 处理并推送所有分支
    if [[ -n "${BRANCH}" ]]; then
        create_local_branches
        log "   推送所有分支并建立跟踪关系..."

        # 获取所有本地分支（除了 main）
        git branch | grep -v '^\*' | grep -v 'main' | sed 's|^[[:space:]]*||' | while read -r branch; do
            log "   推送分支: $branch"
            git push -u origin "$branch" 2>/dev/null || true
        done
    fi

    # 推送标签
    log "   推送所有标签..."
    git push origin --tags 2>/dev/null || true

    cd - >/dev/null

    echo
    log "✓ 已成功推送到远程仓库: $GIT_REMOTE_URL"
    return 0
}

# ============== Git Hooks 配置 ==============

setup_git_hooks() {
    if [[ -z "${GITHOOKS_DIR}" ]]; then
        log "未配置 Git Hooks 目录，跳过 hooks 设置"
        return 0
    fi

    log "5) 配置 Git Hooks..."

    cd "$REPO_DIR"

    # 检查源 hooks 目录是否存在
    local source_hooks_dir
    if [[ "${GITHOOKS_DIR}" = /* ]]; then
        # 绝对路径
        source_hooks_dir="${GITHOOKS_DIR}"
    else
        # 相对路径，相对于脚本执行目录
        source_hooks_dir="../${GITHOOKS_DIR}"
    fi

    if [[ ! -d "$source_hooks_dir" ]]; then
        log "   ⚠️  Git Hooks 目录不存在: $source_hooks_dir"
        log "   跳过 hooks 配置"
        cd - >/dev/null
        return 0
    fi

    # 复制 hooks 目录到仓库
    local target_hooks_dir=".githooks"
    log "   复制 Git Hooks 目录到仓库..."
    cp -r "$source_hooks_dir" "$target_hooks_dir"

    # 设置 hooks 文件为可执行
    find "$target_hooks_dir" -type f -exec chmod +x {} \;
    log "   已设置 hooks 文件为可执行"

    # 配置 git 使用自定义 hooks 目录
    git config core.hooksPath "$target_hooks_dir"
    log "   已配置 git config core.hooksPath $target_hooks_dir"

    cd - >/dev/null

    echo
    log "✓ Git Hooks 配置完成"
}

# ============== 主流程 ==============
main() {
    check_dependencies
    build_svn_url
    extract_authors
    perform_git_svn_clone

    # 配置 Git Hooks
    setup_git_hooks

    if [[ -n "${GIT_REMOTE_URL}" ]]; then
        push_to_remote || true
    else
        log "未配置远程仓库地址，跳过推送步骤"
    fi
}

# 执行主程序
main
