# WSL2 Ubuntu 24.04 安装示例

## 注意事项第一次

- **千万不要修改全局路径下的 glibc 路径！！！**

## 安装前检查

1. 为了防止安装不可用导致系统崩溃，建议先进行机器检查并备份相关数据。

2. 运行以下命令检查当前 `glibc` 版本：

    ```bash
    strings /lib64/libc.so.6
    ```

3. 查看 `ld-linux-x86-64.so.2` 的版本信息：

    ```bash
    ll /lib64/ld-linux-x86-64.so.2
    ```

    输出示例：

    ```bash
    lrwxrwxrwx 1 root root 44 Aug  8 22:47 /lib64/ld-linux-x86-64.so.2 -> ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
    ```

## 下载并安装所需版本的 glibc

1. 访问官网 [http://ftp.gnu.org/gnu/glibc/](http://ftp.gnu.org/gnu/glibc/) 下载所需版本。

2. 以 `glibc-2.35` 为例，使用以下命令下载并安装：

    ```bash
    wget http://ftp.gnu.org/gnu/glibc/glibc-2.35.tar.gz
    tar -xvzf glibc-2.35.tar.gz
    cd glibc-2.35
    mkdir build
    cd build
    ../configure --prefix=/opt/glibc-2.35
    make -j$(nproc)
    sudo make install
    ```

## 使用 glibc-all-in-one 安装指定版本的 glibc

1. 克隆 `glibc-all-in-one` 仓库：

    ```bash
    git clone https://github.com/matrix1001/glibc-all-in-one
    cd glibc-all-in-one/
    ```

2. 更新列表并查看可用版本：

    ```bash
    python3 update_list
    cat list
    ```

3. 下载并安装 `glibc` 版本（以 `2.23-0ubuntu11.3_amd64` 为例）：

    ```bash
    ./download 2.23-0ubuntu11.3_amd64
    ```

## 使用 patchelf 修改二进制

1. 查看二进制程序依赖的glibc库及其库版本

    ```bash
    nm sample_adc | grep GLIBC_
    ```

2. 通过file查看链接的库.

    ```bash
    file sample_adc
    ```

3. 安装patchelf

    ```bash
    //新建目录
    git clone https://github.com/NixOS/patchelf.git
    //进行仓库
    ./bootstrap.sh
    (.bootstrap.sh执行报 autoreconf: not found
    执行sudo apt-get install autoconf automake libtool)
    ./configure
    make
    make check
    sudo make install
    ```

4. 以编译后的可执行程序来指定与开发板适配的glibc:以2.25为例:

    ```bash
    patchelf --set-interpreter  /opt/glibc-2.25/lib/libc.so.6(glibc的文件路经) --set-rpath   /opt/glibc-2.25/lib(glibc的搜索路径)  spi_master(可执行程序)
    ```

5. 最后通过file确定

    ```bash
    file sample_adc
    ```

## 注意事项第二次

- **千万不要修改全局路径下的 glibc 路径！！！**
