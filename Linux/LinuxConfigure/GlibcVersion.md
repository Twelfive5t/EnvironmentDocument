# wsl2 Ubuntu24.04 example

> 安装检查
> 为了防止安装不可用，导致系统奔溃，建议先做机器检查，备份相关数据。
> 运行strings /lib64/libc.so.6 查看该so指向哪个版本

    ll /lib64/ld-linux-x86-64.so.2

    lrwxrwxrwx 1 root root 44 Aug  8 22:47 /lib64/ld-linux-x86-64.so.2 -> ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2

> 下载安装文件

> 安装文件都在官网http://ftp.gnu.org/gnu/glibc/ 这里可以找到你想要的版本，可自行下载，
> 示例：

    wget http://ftp.gnu.org/gnu/glibc/glibc-2.35..tar.gz
    tar -xvzf glibc-2.35.tar.gz
    cd glibc-2.35
    mkdir build
    cd build
    ../configure --prefix=/opt/glibc-2.35
    make -j$(nproc)
    sudo make install

> 安装glibc-all-in-one来下载我们需要的glibc，这里以下载glibc2.23为例。注：ldd --version可以查看当前glibc版本

    git clone https://github.com/matrix1001/glibc-all-in-one
    cd glibc-all-in-one/
    python3 update_list
    cat list
    ./download 2.23-0ubuntu11.3_amd64

# 千万不要修改全局路径下的glibc路径！！！