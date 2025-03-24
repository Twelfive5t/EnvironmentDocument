# SpeedMake 编译加速技术

本文档介绍多种 Linux 环境下的编译加速技术，帮助开发者减少项目编译时间。

## 1. ccache 编译缓存

ccache 通过缓存之前的编译结果来加速重复编译过程。

### 1.1 安装 ccache

```bash
# Debian/Ubuntu
sudo apt install ccache

# CentOS/RHEL
sudo yum install ccache

# Arch Linux
sudo pacman -S ccache
```

### 1.2 在 CMake 中配置 ccache

在 CMakeLists.txt 文件中添加以下配置：

```cmake
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
  set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
  set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
  message(STATUS "Using ccache: ${CCACHE_PROGRAM}")
else()
  message(STATUS "ccache not found")
endif()
```

### 1.3 ccache 常用命令

```bash
# 查看缓存统计信息
ccache -s

# 清除缓存
ccache -C

# 设置最大缓存大小（如：10GB）
ccache -M 10G
```

## 2. 并行编译

### 2.1 使用 Make 并行编译

```bash
# 使用所有可用核心
make -j$(nproc)

# 指定线程数（例如8线程）
make -j8
```

### 2.2 在 CMake 中配置并行编译

```bash
cmake --build . -- -j$(nproc)
```

## 3. 分布式编译 - distcc

distcc 允许在多台机器上分发编译任务。

### 3.1 安装 distcc

```bash
sudo apt install distcc
```

### 3.2 配置 distcc

#### 3.2.1 服务器端配置（被分发编译的机器）

在每台作为编译服务器的机器（如 192.168.1.101, 192.168.1.102）上：

```bash
# 安装distcc
sudo apt install distcc

# 启动distcc服务器
sudo systemctl enable distccd
sudo systemctl start distccd

# 或手动启动，允许特定网段访问
sudo distccd --daemon --allow 192.168.1.0/24 --jobs 8 --log-file /var/log/distccd.log

# 确保安装了相同版本的编译器
gcc --version
g++ --version
```

#### 3.2.2 客户端配置（发起编译的机器）

```bash
# 编辑 distcc 主机列表
mkdir -p ~/.distcc
echo "localhost 192.168.1.101 192.168.1.102" > ~/.distcc/hosts

# 或设置环境变量
export DISTCC_HOSTS='localhost 192.168.1.101 192.168.1.102'
```

### 3.3 在 CMake 中配置 distcc

与 ccache 类似，可以在 CMakeLists.txt 中添加以下配置：

```cmake
# 查找 distcc 程序
find_program(DISTCC_FOUND distcc)

if(DISTCC_FOUND)
  # 设置编译器启动器为 distcc
  set(CMAKE_C_COMPILER_LAUNCHER ${DISTCC_FOUND})
  set(CMAKE_CXX_COMPILER_LAUNCHER ${DISTCC_FOUND})
  message(STATUS "Using distcc: ${DISTCC_FOUND}")

  # 可选：结合 ccache 和 distcc
  find_program(CCACHE_FOUND ccache)
  if(CCACHE_FOUND)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_FOUND}" "${DISTCC_FOUND}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_FOUND}" "${DISTCC_FOUND}")
    message(STATUS "Using ccache with distcc")
  endif()
else()
  message(STATUS "distcc not found")
endif()
```

### 3.4 distcc 状态监控

```bash
# 安装监控工具
sudo apt install distccmon-gnome

# 命令行监控
watch -n 1 distccmon-text

# 图形界面监控
distccmon-gnome
```

### 3.5 distcc 常见问题排查

- 确保所有机器使用相同版本的编译器
- 检查防火墙是否允许 distcc 默认端口 (3632)
- 使用 `distcc --show-hosts` 验证主机列表
- 在有问题的主机上检查 distccd 日志

## 4. 预编译头文件 (PCH)

### 4.1 在 CMake 中配置预编译头文件

```cmake
target_precompile_headers(your_target PRIVATE
    <vector>
    <string>
    <map>
    <your_common_header.h>
)
```

## 5. 增量编译技巧

- 使用 `-pipe` 编译选项减少临时文件IO
- 使用 RAM 磁盘存储中间编译文件
- 优化项目结构减少不必要的重新编译

## 6. 编译优化小结

| 技术         | 适用场景               | 优势                     | 注意事项                 |
|-------------|------------------------|--------------------------|--------------------------|
| ccache      | 重复编译相同或相似代码  | 减少相同代码的重复编译时间 | 需要额外磁盘空间          |
| 并行编译     | 多核心系统             | 充分利用CPU多核能力       | 内存占用增加             |
| distcc      | 大型项目/多台机器环境   | 分散编译负载              | 需要网络配置和维护        |
| 预编译头文件  | 使用大量公共头文件的项目 | 减少头文件解析时间        | 可能影响编译灵活性        |
