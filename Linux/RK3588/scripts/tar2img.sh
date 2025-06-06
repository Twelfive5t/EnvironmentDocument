#!/bin/bash
# filepath: tar2img2.sh

set -e

# 设置变量
TAR_FILE="rootfs.tar"
MOUNT_DIR="/mnt/myrootfs"
IMG_FILE="rootfs.img"
IMG_TMP="rootfs.img.tmp"
INITIAL_SIZE_MB=10240 # 初始镜像大小（MB）
ENABLE_RESERVE=false  # 是否启用预留空间
RESERVE_MB=20         # 预留空间（MB），仅在 ENABLE_RESERVE=true 时生效

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 错误处理函数
cleanup() {
    local exit_code=$?
    log_warn "执行清理操作..."

    # 卸载挂载点
    if mountpoint -q "$MOUNT_DIR" 2>/dev/null; then
        umount "$MOUNT_DIR" 2>/dev/null || true
    fi

    # 分离循环设备
    if [ -n "$LOOP_DEV" ] && [ -e "$LOOP_DEV" ]; then
        losetup -d "$LOOP_DEV" 2>/dev/null || true
    fi

    # 清理临时文件
    rm -f "$IMG_TMP"

    if [ $exit_code -ne 0 ]; then
        log_error "脚本执行失败，退出码: $exit_code"
    fi

    exit $exit_code
}

# 设置错误处理
trap cleanup EXIT INT TERM

# 获取人类可读的文件大小（支持1位小数）
get_human_size() {
    local bytes=$1

    if [ $bytes -gt 1073741824 ]; then
        # GB
        local gb_int=$((bytes / 1073741824))
        local gb_dec=$(((bytes % 1073741824) * 10 / 1073741824))
        echo "${gb_int}.${gb_dec}GB"
    elif [ $bytes -gt 1048576 ]; then
        # MB
        local mb_int=$((bytes / 1048576))
        local mb_dec=$(((bytes % 1048576) * 10 / 1048576))
        echo "${mb_int}.${mb_dec}MB"
    elif [ $bytes -gt 1024 ]; then
        # KB
        local kb_int=$((bytes / 1024))
        local kb_dec=$(((bytes % 1024) * 10 / 1024))
        echo "${kb_int}.${kb_dec}KB"
    else
        echo "${bytes}B"
    fi
}

# 显示文件大小信息
show_file_info() {
    local file=$1
    local label=$2

    if [ ! -f "$file" ]; then
        log_error "文件不存在: $file"
        return 1
    fi

    local logical_size=$(stat -c %s "$file")
    local physical_size=$(du -b "$file" | cut -f1)
    local disk_usage=$(du -h "$file" | cut -f1)
    local human_logical=$(get_human_size $logical_size)

    echo "=== $label 文件信息 ==="
    echo "文件路径: $file"
    echo "逻辑大小: $logical_size 字节 ($human_logical)"
    echo "物理大小: $physical_size 字节"
    echo "磁盘占用: $disk_usage"
    if [ $logical_size -ne $physical_size ]; then
        local saved_bytes=$((logical_size - physical_size))
        echo "稀疏文件: 是 (节省 $(get_human_size $saved_bytes))"
    else
        echo "稀疏文件: 否"
    fi
    echo
}

# 检查依赖工具
check_dependencies() {
    local tools="tar dd mkfs.ext4 losetup mount umount e2fsck resize2fs truncate tune2fs"
    local missing_tools=""

    for tool in $tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            if [ -z "$missing_tools" ]; then
                missing_tools="$tool"
            else
                missing_tools="$missing_tools $tool"
            fi
        fi
    done

    if [ -n "$missing_tools" ]; then
        log_error "缺少必要工具: $missing_tools"
        log_info "请安装: sudo apt-get install e2fsprogs util-linux"
        exit 1
    fi
}

# 检查权限
check_permissions() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "此脚本需要 root 权限运行"
        log_info "请使用: sudo $0"
        exit 1
    fi
}

# 获取文件系统当前块数
get_current_blocks() {
    local img_file=$1
    tune2fs -l "$img_file" 2>/dev/null | grep "^Block count:" | awk '{print $3}'
}

# 主执行流程
main() {
    log_info "开始创建优化的 rootfs 镜像..."

    if [ "$ENABLE_RESERVE" = "true" ]; then
        log_info "预留空间: 启用 (${RESERVE_MB}MB)"
    else
        log_info "预留空间: 禁用 (最小尺寸)"
    fi

    # 预检查
    check_dependencies
    check_permissions

    # 检查输入文件
    if [ ! -f "$TAR_FILE" ]; then
        log_error "未找到输入文件: $TAR_FILE"
        exit 1
    fi

    local tar_size=$(stat -c %s "$TAR_FILE")
    log_info "输入 TAR 文件大小: $(get_human_size $tar_size)"

    # [1/7] 清理旧环境
    log_info "[1/7] 清理旧挂载点和文件..."
    umount "$MOUNT_DIR" 2>/dev/null || true
    rm -rf "$MOUNT_DIR"
    mkdir -p "$MOUNT_DIR"
    rm -f "$IMG_FILE" "$IMG_TMP"

    # [2/7] 创建空镜像
    log_info "[2/7] 创建初始大小 ${INITIAL_SIZE_MB}MB 的空镜像..."
    dd if=/dev/zero of="$IMG_TMP" bs=1M count="$INITIAL_SIZE_MB" 2>/dev/null
    mkfs.ext4 -F -q "$IMG_TMP"

    # [3/7] 挂载镜像
    log_info "[3/7] 挂载镜像到 $MOUNT_DIR..."
    LOOP_DEV=$(losetup --find --show "$IMG_TMP")
    log_info "使用循环设备: $LOOP_DEV"
    mount "$LOOP_DEV" "$MOUNT_DIR"

    # [4/7] 解压 rootfs.tar
    log_info "[4/7] 解压 $TAR_FILE 到 $MOUNT_DIR..."
    tar -xf "$TAR_FILE" -C "$MOUNT_DIR" --numeric-owner

    # [5/7] 显示使用情况
    log_info "[5/7] 检查磁盘使用情况..."
    df -h "$MOUNT_DIR"

    # [6/7] 同步并卸载
    log_info "[6/7] 卸载并同步文件..."
    sync
    umount "$MOUNT_DIR"
    losetup -d "$LOOP_DEV"
    LOOP_DEV="" # 清空变量防止重复分离

    # [7/7] 调整文件系统大小
    log_info "[7/7] 调整文件系统到最佳尺寸..."

    # 首先修复文件系统
    e2fsck -p -f "$IMG_TMP" >/dev/null 2>&1

    # 收缩到最小尺寸
    log_info "收缩文件系统到最小尺寸..."
    resize2fs -M "$IMG_TMP" 2>/dev/null

    # 获取当前实际的块数和大小
    local current_blocks=$(get_current_blocks "$IMG_TMP")
    local current_size=$((current_blocks * 4096))

    log_info "收缩后块数: $current_blocks ($(get_human_size $current_size))"

    # 根据配置决定是否添加预留空间
    if [ "$ENABLE_RESERVE" = "true" ] && [ $RESERVE_MB -gt 0 ]; then
        local reserve_blocks=$((RESERVE_MB * 1024 * 1024 / 4096))
        local target_blocks=$((current_blocks + reserve_blocks))
        local target_size=$((target_blocks * 4096))

        log_info "尝试添加 ${RESERVE_MB}MB 预留空间..."

        # 先扩展镜像文件大小
        truncate -s "$target_size" "$IMG_TMP"

        # 再扩展文件系统
        if resize2fs "$IMG_TMP" ${target_blocks}s >/dev/null 2>&1; then
            log_success "成功添加预留空间"
        else
            log_warn "添加预留空间失败，使用最小尺寸"
            truncate -s "$current_size" "$IMG_TMP"
        fi
    else
        log_info "使用最小尺寸"
        truncate -s "$current_size" "$IMG_TMP"
    fi

    # 移动到最终位置
    mv "$IMG_TMP" "$IMG_FILE"

    # 显示详细的大小信息
    show_file_info "$IMG_FILE" "最终生成的 rootfs 镜像"

    # 统计信息
    local img_size=$(stat -c %s "$IMG_FILE")

    log_success "rootfs 镜像创建完成!"
    echo "=========================================="
    echo "原始 TAR 大小: $(get_human_size $tar_size)"
    echo "最终镜像大小: $(get_human_size $img_size)"

    # 计算压缩比
    if [ $tar_size -gt 0 ]; then
        local ratio=$((img_size * 100 / tar_size))
        echo "镜像/TAR 比率: ${ratio}%"
    fi

    # 计算空间效率
    local estimated_extracted=$((tar_size * 120 / 100)) # 估计解压后为 TAR 的 1.2 倍
    if [ $img_size -lt $estimated_extracted ]; then
        local space_saved=$((estimated_extracted - img_size))
        echo "相比直接解压节省: $(get_human_size $space_saved)"
    fi
    echo "=========================================="

    # 验证镜像完整性
    log_info "验证镜像完整性..."
    if e2fsck -n "$IMG_FILE" >/dev/null 2>&1; then
        log_success "镜像文件系统完整性检查通过"
    else
        log_warn "镜像文件系统检查发现问题，但可能仍然可用"
    fi
}

# 执行主函数
main "$@"
