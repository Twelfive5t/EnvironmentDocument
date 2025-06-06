# RK3588 Buildroot 编译配置指南

本文档介绍如何为 RK3588 平台配置和编译 Buildroot 系统。

## 目录

- [RK3588 Buildroot 编译配置指南](#rk3588-buildroot-编译配置指南)
  - [目录](#目录)
  - [参考资料](#参考资料)
  - [前置准备](#前置准备)
  - [基础配置](#基础配置)
    - [目标架构配置](#目标架构配置)
    - [工具链配置](#工具链配置)
    - [系统配置](#系统配置)
    - [目标软件包配置](#目标软件包配置)
  - [Docker 支持配置](#docker-支持配置)
    - [基础 Docker 配置](#基础-docker-配置)
    - [升级 Docker 版本](#升级-docker-版本)
    - [解决编译问题](#解决编译问题)
  - [中文支持配置](#中文支持配置)
    - [修改 BusyBox 源码](#修改-busybox-源码)
  - [编译环境设置](#编译环境设置)
    - [WSL2 环境配置](#wsl2-环境配置)
    - [编译优化设置](#编译优化设置)
  - [编译和部署](#编译和部署)
    - [开始编译](#开始编译)
    - [编译输出](#编译输出)
    - [部署到设备](#部署到设备)
  - [故障排除](#故障排除)
    - [常见编译错误](#常见编译错误)
    - [调试技巧](#调试技巧)
    - [性能优化建议](#性能优化建议)

## 参考资料

- [视频教程：RK3588 开发指南](https://www.bilibili.com/video/BV1WN4y1w7Mx)
- [官方文档：iCore-3588JQ Linux 编译](https://wiki.t-firefly.com/zh_CN/iCore-3588JQ/linux_compile.html)

## 前置准备

1. **下载 RK3588 SDK**：
   - 获取 RK3588 的完整 SDK 源码包
   - 确保 SDK 中包含 buildroot 模块

2. **环境要求**：
   - Linux 开发环境（推荐 Ubuntu 18.04+）
   - 至少 50GB 可用磁盘空间
   - 8GB+ 内存

## 基础配置

进入 buildroot 目录并开始配置：

```bash
cd path/to/rk3588_sdk/buildroot
make menuconfig
```

### 目标架构配置

```text
Target options  --->
    Target Architecture (AArch64 (little endian))  --->
    Target Architecture Variant (cortex-A76/A55 big.LITTLE)  --->
    Floating point strategy (FP-ARMv8)  --->
    MMU Page Size (4KB)  --->
    Target Binary Format (ELF)  --->
```

### 工具链配置

```text
Toolchain  --->
    [ ] Prefer to use clang
    Toolchain type (External toolchain)  --->
    *** Toolchain External Options ***
    Toolchain (Custom toolchain)  --->
    Toolchain origin (Pre-installed toolchain)  --->
    Toolchain path: /root/proj/rk3588_sdk/prebuilts/gcc/linux-x86/aarch64/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu
    Toolchain prefix: aarch64-none-linux-gnu
    External toolchain gcc version (10.x)  --->
    External toolchain kernel headers series (5.10.x)  --->
    External toolchain C library (glibc)  --->
    [*] Toolchain has SSP support?
    [*]   Toolchain has SSP strong support?
    [ ] Toolchain has RPC support?
    [*] Toolchain has C++ support?
    [ ] Toolchain has D support?
    [*] Toolchain has Fortran support?
    [*] Toolchain has OpenMP support?
```

### 系统配置

```text
System configuration  --->
    Root FS skeleton (default target skeleton)  --->
    System hostname: buildroot
    System banner: Welcome to Buildroot
    Passwords encoding (sha-256)  --->
    Init system (BusyBox)  --->
    /dev management (Dynamic using devtmpfs + eudev)  --->
    Path to the permission tables: system/device_table.txt
    [ ] support extended attributes in device tables
    [ ] Use symlinks to /usr for /bin, /sbin and /lib
    [*] Enable root login with password
    Root password: firefly
    /bin/sh (zsh)  --->
    Run a shell on serial console after boot (/sbin/getty (login prompt))  --->
    -*- Run a getty (login prompt) after boot  --->
    [*] remount root filesystem read-write during boot
    Network interface to configure through DHCP: (留空)
    Set the system's default PATH: /bin:/sbin:/usr/bin:/usr/sbin
    [*] Purge unwanted locales
    Locales to keep: C en_US
    Generate locale data: (留空)
    [ ] Enable Native Language Support (NLS)
    [ ] Install timezone info
    Path to the users tables: (留空)
    Root filesystem overlay directories: board/firefly/rootfs-overlay
```

### 目标软件包配置

在 `Target packages` 中选择以下软件包：

```text
Target packages  --->
    Networking applications  --->
        [*] openssh
    System tools  --->
        [*] htop
    Text editors and viewers  --->
        [*] vim
    Development tools  --->
        [*] git
    Shells  --->
        [*] zsh
    Libraries  --->
        Text and terminal handling  --->
            [*] ncurses
                [*] enable wide char support
    Compressors and decompressors  --->
        [*] tar
```

## Docker 支持配置

### 基础 Docker 配置

如需要 Docker 功能，添加以下配置：

```bash
# 在 .config 文件中添加或通过 menuconfig 选择
BR2_PACKAGE_CGROUPFS_MOUNT=y
BR2_PACKAGE_DOCKER_ENGINE=y
BR2_PACKAGE_DOCKER_ENGINE_EXPERIMENTAL=y
BR2_PACKAGE_DOCKER_ENGINE_STATIC_CLIENT=y
BR2_PACKAGE_DOCKER_ENGINE_DRIVER_BTRFS=y
BR2_PACKAGE_DOCKER_ENGINE_DRIVER_DEVICEMAPPER=y
BR2_PACKAGE_DOCKER_ENGINE_DRIVER_VFS=y
```

**注意事项**：

- 需要将 rootfs-overlay 挂载 SDK 编译出的内核的 `lib/modules`
- Firefly 的 `firefly-linux.config` 将 iptable、netfilter 等模块设为 `m`，未编译进内核
- Docker 高版本不需要安装 Docker-Compose

### 升级 Docker 版本

由于默认 Docker 版本较低，可通过以下步骤升级：

1. **克隆官方 Buildroot**：

   ```bash
   git clone https://github.com/buildroot/buildroot.git /tmp/buildroot-official
   ```

2. **备份并替换软件包**：

   ```bash
   # 备份原有包
   cp -r package/containerd package/containerd.bak
   cp -r package/docker* package/docker*.bak
   cp -r package/go package/go.bak

   # 替换为官方最新版本
   cp -r /tmp/buildroot-official/package/containerd package/
   cp -r /tmp/buildroot-official/package/docker* package/
   cp -r /tmp/buildroot-official/package/go package/
   ```

### 解决编译问题

设置 Go 代理以解决网络依赖问题：

```bash
# 方法 A：使用官方代理
export GOPROXY="https://proxy.golang.org,direct"

# 方法 B：使用国内代理
export GOPROXY="https://goproxy.cn,direct"

# 在对应的 build 目录下执行
cd output/build/<package-name>/
/root/proj/rk3588_sdk/buildroot/output/host/bin/go mod tidy
/root/proj/rk3588_sdk/buildroot/output/host/bin/go mod vendor
```

## 中文支持配置

### 修改 BusyBox 源码

1. **修改字符串处理**：

   ```bash
   vim dl/busybox/busybox-*/libbb/printable_string.c
   ```

2. **修改 Unicode 支持**：

   ```bash
   vim dl/busybox/busybox-*/libbb/unicode.c
   # 修改 unicode_conv_to_printable2 函数（约第1030行）
   ```

3. **启用 Unicode 支持**：

   ```bash
   make busybox-menuconfig
   # 在 Settings 中选择 "Support Unicode"
   ```

## 编译环境设置

### WSL2 环境配置

如果在 WSL2 中编译，需要设置正确的 PATH：

```bash
export PATH=/root/.nvm/versions/node/v20.19.2/bin:/root/.opam/5.1.0/bin:/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib
```

### 编译优化设置

```bash
# 设置并行编译数量（根据 CPU 核心数调整）
export BR2_JLEVEL=8

# 设置下载目录（可选）
export BR2_DL_DIR=/path/to/download/cache
```

## 编译和部署

### 开始编译

```bash
# 清理之前的编译结果（可选）
make clean

# 开始编译
make

# 或者指定并行编译
make -j8
```

### 编译输出

编译完成后，主要输出文件位于：

```text
output/images/
├── rootfs.ext4          # 根文件系统镜像
├── rootfs.tar           # 根文件系统 tar 包
├── uboot.img           # U-Boot 镜像
└── zImage              # 内核镜像
```

### 部署到设备

```bash


```

## 故障排除

### 常见编译错误

1. **交叉编译工具链错误**：

   ```bash
   # 检查工具链路径是否正确
   ls -la /root/proj/rk3588_sdk/prebuilts/gcc/linux-x86/aarch64/

   # 验证工具链是否可用
   /root/proj/rk3588_sdk/prebuilts/gcc/linux-x86/aarch64/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc --version
   ```

2. **磁盘空间不足**：

   ```bash
   # 清理编译缓存
   make clean

   # 清理下载缓存
   rm -rf dl/*
   ```

### 调试技巧

```bash
# 查看详细编译日志
make V=1

# 单独编译某个包
make <package-name>

# 重新配置某个包
make <package-name>-reconfigure

# 清理某个包
make <package-name>-dirclean
```

### 性能优化建议

1. **使用本地下载缓存**：

   ```bash
   mkdir -p ~/buildroot-dl
   export BR2_DL_DIR=~/buildroot-dl
   ```

2. **启用 ccache**：

   ```bash
   # 在 menuconfig 中启用
   Build options  --->
       [*] Enable compiler cache
   ```

3. **调整并行编译数**：

   ```bash
   # 根据 CPU 核心数设置，通常为核心数 + 1
   make -j$(nproc)
   ```
