# Linux环境配置

## 初始换源

1. 安装 `vim`：

    ```bash
    apt install vim -y
    ```

2. 编辑 `sources.list` 文件：

    ```bash
    sudo vim /etc/apt/sources.list
    ```

3. 更新软件源并升级系统：

    ```bash
    sudo apt update -y
    sudo apt upgrade -y
    ```

## 安装常用工具

1. 基础开发工具：

    ```bash
    # 编译构建工具
    sudo apt install -y build-essential make cmake gcc g++
    # 版本控制
    sudo apt install -y git
    # 自动化构建工具
    sudo apt install -y autoconf automake libtool m4
    ```

2. 内核和驱动开发工具：

    ```bash
    # 内核编译依赖
    sudo apt install -y libelf-dev libssl-dev fakeroot bc
    # 设备树编译器
    sudo apt install -y device-tree-compiler
    # QEMU模拟器
    sudo apt install -y qemu qemu-user-static
    ```

3. 代码分析和调试工具：

    ```bash
    # 调试工具
    sudo apt install -y gdb
    # Clang工具链
    sudo apt install -y clangd clang-tidy clang-format clang
    # 词法分析工具
    sudo apt install -y flex bison
    # 安装 clang
    wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 19 all

    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-19 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100 \
    && update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-19 100 \
    && update-alternatives --install /usr/bin/run-clang-tidy run-clang-tidy /usr/bin/run-clang-tidy-19 100 \
    && update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-19 100
    ```

4. Python开发环境：

    ```bash
    # Python3及其开发工具
    sudo apt install -y python3 python3-dev python3-pip python3-setuptools
    ```

5. 系统工具：

    ```bash
    # 文本编辑器
    sudo apt install -y vim
    # 系统监控工具
    sudo apt install -y htop btop
    # 文件搜索工具
    sudo apt install -y plocate
    # 网络工具
    sudo apt install -y net-tools wget
    # 剪贴板工具
    sudo apt install -y xclip xsel
    ```

6. 实用工具：

    ```bash
    # 现代化cat替代品
    sudo apt install -y bat
    # 终端浏览器
    sudo apt install -y w3m w3m-img
    # 系统信息显示
    sudo apt install -y neofetch
    # 实时性测试工具
    sudo apt install -y rt-tests
    # lwIP网络协议栈开发
    sudo apt install -y liblwip-dev
    ```

## 系统环境配置

1. 设置系统时区与系统语言

    ```bash
    sudo timedatectl set-timezone Asia/Shanghai
    sudo localectl set-locale LANG=en_US.UTF-8
    ```

## 添加Root用户

1. 编辑 `sudoers` 文件：

    ```bash
    sudo vim /etc/sudoers
    ```

2. 修改为：

    ```bash
    root      ALL=(ALL) ALL
    ```

## SSH 配置

### Linux 端配置

1. 安装 `ssh`：

    ```bash
    sudo apt install -y ssh
    ```

2. 修改 SSH 配置，允许 root 登录：

    ```bash
    sudo sed -i '$ a PermitRootLogin yes\n' /etc/ssh/sshd_config
    sed -i '1i Host *\n  ServerAliveInterval 60\n' ~/.ssh/config
    sudo systemctl restart sshd
    ```

3. 设置 root 密码：

    ```bash
    sudo passwd root
    ```

4. 生成 SSH 密钥：

    ```bash
    ssh-keygen -t rsa
    ```

### Windows 端配置

1. 生成密钥：

    ```bash
    ssh-keygen -t rsa
    ```

2. 在 Windows 端配置：

    - 打开插件设置，编辑配置文件
    - 选择 `id_ras.pub`，并拷贝内容
    - 在 Linux 端 `~/.ssh/authorized_keys` 文件中添加密钥：

    ```bash
    echo "xxxx" >> ~/.ssh/authorized_keys
    ```

## 网络配置

1. 编辑网络配置文件 `/etc/netplan/01-network-manager-all.yaml`：

    ```bash
    sudo vim /etc/netplan/01-network-manager-all.yaml
    ```

2. 配置文件内容如下：

    ```yaml
    network:
      version: 2
      renderer: NetworkManager
      wifis:
        wlan0:
          dhcp4: true
          access-points:
            "Fscut_office":
              password: "fscut@64309023"
              band: 5GHz
              channel: 44
          optional: true
      ethernets:
        eth0:
          dhcp4: yes
        eth1:
          dhcp4: no
          addresses:
            - 192.168.29.11/24
    ```

3. 应用配置：

    ```bash
    netplan apply
    ```

## 实时性优化

### 实时性参考链接

- [【原创】有利于提高xenomai /PREEMPT-RT 实时性的一些配置建议](https://www.cnblogs.com/wsg1100/p/12730720.html)
- [【实时性】实时性优化的一些参数设置和心得](https://blog.csdn.net/qq_31985307/article/details/130791459)

1. 检查是否默认引导到 GUI：

    ```bash
    systemctl get-default
    ```

2. 如果输出为 `graphical.target`，切换到文本模式：

    ```bash
    systemctl set-default multi-user.target
    ```

## tldr 配置

1. 安装 tldr：

    ```bash
    npm install -g tldr
    pip install tldr
    brew install tlrc
    ```

2. 配置.zshrc：

    ```bash
    export TLDR_LANGUAGE="zh"
    ```

3. 更新本地缓存：

    ```bash
    tldr --update
    ```
