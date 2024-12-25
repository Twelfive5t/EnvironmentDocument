# 更新 GCC 到最新版本

## 查看当前系统中的 GCC 版本

1. 使用以下命令查看当前安装的 GCC 版本：

    ```bash
    gcc -v
    ```

## 更新系统软件源

1. 更新软件源：

    ```bash
    sudo apt-get update
    ```

2. 升级系统中的软件：

    ```bash
    sudo apt-get upgrade
    ```

## 添加 Ubuntu Toolchain 测试版源

1. 添加 Ubuntu Toolchain 测试版源：

    ```bash
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    ```

2. 再次更新软件源：

    ```bash
    sudo apt-get update
    ```

## 安装最新版本的 GCC（版本 11）

1. 安装 GCC 11 和 G++ 11：

    ```bash
    sudo apt-get install gcc-11 g++-11
    ```

## 添加 GCC 版本到 `update-alternatives`

1. 将 GCC 11 添加到 `update-alternatives`：

    ```bash
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100
    ```

## 配置默认 GCC 和 G++ 版本

1. 配置默认 GCC 版本：

    ```bash
    sudo update-alternatives --config gcc
    ```

2. 配置默认 G++ 版本：

    ```bash
    sudo update-alternatives --config g++
    ```
