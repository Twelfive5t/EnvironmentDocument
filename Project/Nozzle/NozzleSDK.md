# Nozzle SDK 编译指南（RK3588）

## 参考资料

- [编译 Linux 固件 — Firefly Wiki](https://wiki.t-firefly.com/zh_CN/iCore-3588JQ/linux_compile.html)
- [Firefly 固件下载](https://www.t-firefly.com/doc/download/161.html)
- Ubuntu 镜像：`Ubuntu20.04-Xfce_RK3588_v3.11-17_20240312.7z`

## 虚拟机配置

- 系统：Ubuntu 20.04
- 配置：4核×2、内存 8192 MB、硬盘 150 GB（尽量大）
- 参考教程：[VMWare 安装 Ubuntu 20.04 并使用 root 登录](https://blog.csdn.net/weixin_42250835/article/details/119063080)

## 编译步骤

### 1. 安装基础依赖

将文件复制到任意路径后，先安装 git 和 python（repo 不用单独管）：

```bash
sudo apt install -y git python
```

### 2. 同步代码

解压成功后执行同步。若执行失败，按提示添加 safe.directory：

```bash
git config --global --add safe.directory /root/proj/rk3588_sdk/.repo/manifests
git config --global --add safe.directory /root/proj/rk3588_sdk/.repo/repo
```

> 注意：同步耗时较长，请耐心等待。

### 3. 安装编译依赖

```bash
sudo apt-get install git ssh make gcc libssl-dev liblz4-tool \
  expect g++ patchelf chrpath gawk texinfo chrpath diffstat binfmt-support \
  qemu-user-static live-build bison flex fakeroot cmake gcc-multilib g++-multilib \
  unzip device-tree-compiler ncurses-dev
```

### 4. 开始编译

```bash
./build.sh lunch
```

选择开发板，改为 `28. aio-3588q-BE45-A1-buildroot.mk`。
