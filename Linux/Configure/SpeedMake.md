# SpeedMake 编译加速

## Distcc 分布式编译

### 1. 配置 A 为 distcc 服务器

首先，在 A 中安装和配置 distcc。

#### 安装 distcc

在 A 中打开终端，执行以下命令：

```bash
sudo apt update
sudo apt install distcc
```

#### 修改配置

编辑 /etc/default/distcc 文件，配置如下：

```bash
STARTDISTCC="true"
ALLOWEDNETS="10.1.50.0/24 172.19.64.0/24"
NICE="16"
JOBS="16"
```

### 2. 在 B 中配置 distcc

在 B 中打开终端，安装 distcc：

```bash
sudo apt update
sudo apt install distcc
```

#### 配置 distcc 主机

编辑 ~/.distcc/hosts 文件，添加如下内容：

```bash
10.1.50.43/24
```

### 3. 在 A 中查看 distcc 日志

使用以下命令查看 distcc 日志：

```bash
tail -f /var/log/distccd.log
```

### 4. 在 CMake 中配置 distcc

在 CMakeLists.txt 文件中添加以下配置：

```cmake
set(CMAKE_C_COMPILER_LAUNCHER distcc)
set(CMAKE_CXX_COMPILER_LAUNCHER distcc)
```

## ccache 缓存

### 1. 安装 ccache

在终端执行以下命令安装 ccache：

```bash
sudo apt install ccache
```

### 2. 在 CMake 中配置 ccache

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

### 3. 查看缓存命中

```bash
ccache -s
```
