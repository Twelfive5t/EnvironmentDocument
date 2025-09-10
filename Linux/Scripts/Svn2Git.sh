#!/usr/bin/env bash
set -euo pipefail

# ================== 可配置参数 ==================
# 这里是 SVN 仓库地址。当前指向 trunk，如果你想包含 branches / tags，参考后文改法。
SVN_URL="svn://ebd.fsvn.cn/BPC6203E/trunk"

# 作者邮箱域（会生成 username = username <username@域>）
EMAIL_DOMAIN="fscut.com"

# 输出作者映射文件
AUTHORS_FILE="authors.txt"

# git svn clone 目标目录（留空表示让 git svn 自动根据 URL 末尾命名）
TARGET_DIR=""
# 例如想固定目录名：TARGET_DIR="BPC6203E-git"

# 是否显示调试信息 (true/false)
DEBUG=false
# =================================================

log() { echo "[`date +%H:%M:%S`] $*"; }

command -v svn >/dev/null 2>&1 || { echo "缺少 svn 命令"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "缺少 git 命令"; exit 1; }
git svn --version >/dev/null 2>&1 || { echo "缺少 git-svn 支持 (安装 git-svn 包)"; exit 1; }

TMP_AUTHORS_RAW=$(mktemp /tmp/authors_raw.XXXXXX)

log "1) 提取作者列表..."
svn log "$SVN_URL" --quiet \
  | awk -F'|' '/^r[0-9]+/ {
      a=$2
      gsub(/^[ \t]+|[ \t]+$/, "", a)
      if (a != "") print a
    }' \
  | sort -u > "$TMP_AUTHORS_RAW"

COUNT=$(wc -l < "$TMP_AUTHORS_RAW" | tr -d ' ')
log "   收集到 $COUNT 个唯一作者"

log "2) 生成 $AUTHORS_FILE ..."
awk -v domain="$EMAIL_DOMAIN" 'NF {
  # 若用户名里含有@，则直接用用户名本身作为邮箱左侧部分
  user=$1
  gsub(/^[ \t]+|[ \t]+$/, "", user)
  if (user != "")
    printf "%s = %s <%s@%s>\n", user, user, user, domain
}' "$TMP_AUTHORS_RAW" | sort -u > "$AUTHORS_FILE"

rm -f "$TMP_AUTHORS_RAW"
log "   已生成 $AUTHORS_FILE"
echo

CLONE_CMD=(git svn clone "$SVN_URL" --no-metadata --authors-file="$AUTHORS_FILE")

if [[ -n "${TARGET_DIR}" ]]; then
  CLONE_CMD+=("$TARGET_DIR")
fi

log "3) 开始 git svn clone ..."

"${CLONE_CMD[@]}"

log "完成。后续可执行："
if [[ -n "${TARGET_DIR}" ]]; then
  echo "  cd \"$TARGET_DIR\""
else
  echo "  cd $(basename \"$SVN_URL\")"
fi
echo "  git log --oneline -n 5"
