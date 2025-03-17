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

## Zsh 配置

1. 更新软件源并安装 Zsh 和相关工具：

    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y zsh git curl
    ```

2. 切换终端为 Zsh：

    ```bash
    chsh -s /bin/zsh
    ```

### 下载 oh-my-zsh 和插件

1. 使用以下任意方法安装 `oh-my-zsh`：

    - `curl`：

        ```bash
        sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
        ```

    - `wget`：

        ```bash
        sh -c "$(wget -O- https://install.ohmyz.sh/)"
        ```

2. 克隆插件：

    ```bash
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
    git clone https://github.com/fdellwing/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat
    ```

3. 修改 Zsh 配置并使修改生效(见.zshrc)：

    ```bash
    source ~/.zshrc
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

## Docker 配置

1. 安装 Docker：

    ```bash
    wget -O- https://get.docker.com/ | sh
    ```

2. 编辑 Docker 配置文件 `/lib/systemd/system/docker.service`，添加代理配置：

    ```bash
    Environment="ALL_PROXY=http://10.1.50.43:7897"
    Environment="HTTP_PROXY=http://10.1.50.43:7897"
    Environment="HTTPS_PROXY=http://10.1.50.43:7897"
    Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
    ```

3. 重新加载并重启 Docker：

    ```bash
    systemctl daemon-reload
    systemctl restart docker
    systemctl show --property=Environment docker
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

## Vim 配置

### Vim参考链接

- [Vim的终极配置方案，完美的写代码界面! ——.vimrc](https://blog.csdn.net/amoscykl/article/details/80616688?spm=1001.2014.3001.5506)
- [vim插件管理器：Vundle的介绍及安装（很全）](https://blog.csdn.net/zhangpower1993/article/details/52184581?spm=1001.2014.3001.5506)

1. 安装 `vim` 和插件：

    ```bash
    sudo apt install -y vim universal-ctags
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    ```

2. 编辑 `~/.vimrc`，安装插件：

    ```bash
    vim ~/.vimrc
    ```

3. 安装插件：

    ```vim
    :PluginInstall
    ```

4. 查看已安装插件：

    ```vim
    :PluginList
    ```

### Neovim 与 LazyVim

### Neovim参考链接

- [neovim github](https://github.com/neovim/neovim)
- [lazyvim](https://www.lazyvim.org/)

1. 安装 Neovim：

    ```bash
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
    tar -xvzf nvim-linux64.tar.gz
    ```

2. 创建软链接：

    ```bash
    ln -s ~/Desktop/nvim-linux64/bin/nvim /usr/bin/nvim
    ```

3. 拷贝 LazyVim 配置：

    ```bash
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    ```

### fzf 配置

1. 安装 fzf：

    ```bash
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    sudo apt install ripgrep
    ```

2. 修改 `key-bindings.zsh` 配置(见fzf-key-bindings.zsh)：

    ```bash
    nvim ~/.fzf/shell/key-bindings.zsh
    ```

3. 激活配置, 添加到 `~/.fzf.zsh` 中：

    ```bash
    # FZF Configure
    # CTRL-T    命令行打印选中内容
    # CTRL-R    命令行历史记录搜索，并打印输出
    # ALT-C     模糊搜索目录，并进入（cd）
    export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!mnt/*'"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview '[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || batcat --style=numbers --color=always {} | head -500'"

    source ~/.fzf/shell/key-bindings.zsh
    ```

### tldr 配置

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
