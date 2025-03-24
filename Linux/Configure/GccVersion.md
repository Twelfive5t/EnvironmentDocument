# Linux 环境下 GCC 版本更新指南

本文档提供在 Linux 系统（主要针对 Ubuntu/Debian）中更新和管理 GCC 编译器版本的详细步骤。

## 1. 查看当前系统中的 GCC 版本

使用以下命令查看当前安装的 GCC 版本：

```bash
gcc -v
# 或者
gcc --version
```

## 2. 更新系统软件源

在安装新版本之前，确保系统软件源是最新的：

```bash
sudo apt-get update
sudo apt-get upgrade
```

## 3. 安装最新版本的 GCC

### 方法一：通过 Ubuntu Toolchain 测试版源（推荐）

- 添加 Ubuntu Toolchain 测试版源：

```bash
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
```

- 安装 GCC 和 G++ 的最新版本（以 GCC 11 为例）：

```bash
sudo apt-get install gcc-11 g++-11
```

- 安装特定架构的编译器（可选）：

```bash
sudo apt install gcc-9-aarch64-linux-gnu g++-9-aarch64-linux-gnu
```

### 方法二：从源代码编译（适用于所有 Linux 发行版）

如果您需要最新版本或特定版本的 GCC，可以从源代码编译：

```bash
# 下载 GCC 源代码（以 GCC 12.2.0 为例）
wget https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz
tar -xf gcc-12.2.0.tar.gz
cd gcc-12.2.0

# 安装依赖项
./contrib/download_prerequisites

# 创建构建目录
mkdir build && cd build

# 配置
../configure --enable-languages=c,c++ --disable-multilib

# 编译和安装（-j 参数指定并行编译的作业数，可以设为 CPU 核心数）
make -j$(nproc)
sudo make install
```

## 4. 使用 update-alternatives 管理多个 GCC 版本

如果系统中有多个 GCC 版本，可以使用 `update-alternatives` 进行管理：

- 将 GCC 版本添加到 alternatives 系统：

```bash
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 110

# 如果有其他版本，也可以添加（优先级数字较小）
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90
```

- 配置默认 GCC 和 G++ 版本：

```bash
sudo update-alternatives --config gcc
sudo update-alternatives --config g++
```

系统会提示您选择想要使用的版本。

## 5. 为特定项目设置 GCC 版本

在不更改系统默认 GCC 版本的情况下，您可以为特定项目指定编译器：

### 使用环境变量

```bash
export CC=/usr/bin/gcc-11
export CXX=/usr/bin/g++-11
```

### 在 CMake 项目中

```bash
cmake -DCMAKE_C_COMPILER=/usr/bin/gcc-11 -DCMAKE_CXX_COMPILER=/usr/bin/g++-11 ..
```

### 在 Makefile 中

```makefile
CC = /usr/bin/gcc-11
CXX = /usr/bin/g++-11
```

## 6. 故障排除

### 问题：找不到库文件

如果出现 `cannot find -lstdc++` 等错误，安装相应的库：

```bash
sudo apt-get install libstdc++-11-dev
```

### 问题：版本冲突

如果遇到依赖或版本冲突，可以尝试：

```bash
# 检查已安装的 GCC 相关包
dpkg -l | grep gcc

# 如需要，卸载特定版本
sudo apt remove gcc-X g++-X
```

## 参考资源

- [GCC 官方文档](https://gcc.gnu.org/onlinedocs/)
- [Ubuntu Toolchain PPA](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test)
