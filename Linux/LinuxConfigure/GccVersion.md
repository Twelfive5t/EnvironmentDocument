> 查看当前系统中的GCC版本：

    gcc -v

> 更新软件源：

    sudo apt-get update

> 升级系统中的软件：

    sudo app-get upgrade

> 添加Ubuntu Toolchain测试版源：

    sudo add-apt-repository ppa:ubuntu-toolchain-r/test

> 再次更新软件源：

    sudo apt-get update

> 安装最新版本的GCC（版本为11）：

    sudo apt-get install gcc-11 g++-11

> 添加 gcc 版本到 update-alternatives

    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

> 配置默认 gcc g++ 版本

    sudo update-alternatives --config gcc
    sudo update-alternatives --config gcc