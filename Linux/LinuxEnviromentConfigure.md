# Linux环境配置

## 初始换源

    apt install vim -y

    sudo vim /etc/apt/sources.list
     
    deb https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
    deb-src https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
    deb https://mirrors.aliyun.com/debian-security/ bullseye-security main
    deb-src https://mirrors.aliyun.com/debian-security/ bullseye-security main
    deb https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
    deb-src https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
    deb https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
    deb-src https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib

    sudo apt update -y
    sudo apt upgrade -y

## 安装常用工具

    sudo apt install -y make cmake gcc g++ flex bison libelf-dev libssl-dev
    sudo apt install -y git fakeroot ncurses-dev xz-utils bc
    sudo apt install -y gdb m4 autoconf automake libtool libncurses5-dev build-essential fakeroot
    sudo apt -y install coreutils qemu qemu-user-static python3 device-tree-compiler clang bison flex lld libssl-dev bc genext2fs
    sudo apt install -y libcurses-dev  ncurses-dev z4
    sudo apt install -y vim mlocate htop wget  net-tools
    sudo apt install -y liblwip-dev rt-tests btop bat w3m w3m-img


## 添加Root用户

    sudo vim /etc/sudoers

    修改
    root      ALL=(ALL:ALL) ALL
    为
    root      ALL=(ALL) ALL

## ssh配置
### Linux

    sudo apt install -y ssh

    sudo sed -i '$ a PermitRootLogin yes\n' /etc/ssh/sshd_config

    sudo systemctl restart sshd

    sudo passwd root

    #生成密钥
    ssh-keygen -t rsa

### Windows

> #生成钥匙
ssh-keygen -t rsa

> #ssh远程连接后
> #打开插件里的设置 编辑配置文件
> #选择id_ras.pub，拷贝内容
echo "xxxx" >> ~/.ssh/authorized_keys

## zsh配置

    #更新软件源
    sudo apt update && sudo apt upgrade -y
    # 安装 zsh git curl
    sudo apt install zsh git curl

    # 切换终端为zsh
    chsh -s /bin/zsh

### 下载oh-my-zsh及插件


| Method |	Command |
| ------ | --------|
| curl |	sh -c "$(curl -fsSL https://install.ohmyz.sh/)" |
| wget |	sh -c "$(wget -O- https://install.ohmyz.sh/)" |
| fetch |	sh -c "$(fetch -o - https://install.ohmyz.sh/)" |
| 国内curl镜像 |	sh -c "$(curl -fsSL https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)" |
| 国内wget镜像 |	sh -c "$(wget -O- https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)" |


    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
    git clone https://github.com/fdellwing/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat

### 修改zsh配置

vim ~/.zshrc

    ###########################################################
    ZSH_THEME="powerlevel10k/powerlevel10k"

    plugins=(git zsh-autosuggestions zsh-syntax-highlighting z extract web-search \
            zsh-history-substring-search you-should-use zsh-bat\
    )



    # 设置代理
    #proxy ()
    {
      export ALL_PROXY="http://10.1.50.43:7897"
      export HTTP_PROXY="http://10.1.50.43:7897"
      export HTTPS_PROXY="http://10.1.50.43:7897"
      export NO_PROXY="localhost,127.0.0.1,.example.com"
      export all_proxy="http://10.1.50.43:7897"
      export http_proxy="http://10.1.50.43:7897"
      export https_proxy="http://10.1.50.43:7897"
      export no_proxy="localhost,127.0.0.1,.example.com"
    }

    # 取消代理
    unproxy ()
    {
      unset ALL_PROXY
      unset HTTP_PROXY
      unset HTTPS_PROXY
      unset NO_PROXY
      unset all_proxy
      unset http_proxy
      unset https_proxy
      unset no_proxy
    }


    # This speeds up pasting w/ autosuggest
    # https://github.com/zsh-users/zsh-autosuggestions/issues/238
    pasteinit() {
      OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
      zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
    }

    pastefinish() {
      zle -N self-insert $OLD_SELF_INSERT
    }
    zstyle :bracketed-paste-magic paste-init pasteinit
    zstyle :bracketed-paste-magic paste-finish pastefinit
    ############################################################
> #使zsh配置修改生效
source ~/.zshrc

## 网络配置

sudo vim /etc/netplan/01-network-manager-all.yaml

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


netplan apply

## Docker配置

wget -O- https://get.docker.com/ | sh

vim /lib/systemd/system/docker.service

    #在【Service】下添加
    Environment="ALL_PROXY=http://10.1.50.43:7897"
    Environment="HTTP_PROXY=http://10.1.50.43:7897"
    Environment="HTTPS_PROXY=http://10.1.50.43:7897"
    Environment="NO_PROXY=localhost,127.0.0.1,.example.com"

> #重新加载系统配置后重启docker，并检测是否设置成功
systemctl daemon-reload
systemctl restart docker
systemctl show --property=Environment docker


## 开机自启动服务

vim /etc/init.d/rk3568_auto_start.sh

    #!/bin/bash
    sleep 5
    echo userspace > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
    echo 1416000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed

sudo chmod +x /etc/init.d/rk3568_auto_start.sh

vim /etc/systemd/system/rk3568_auto_start.service

    [Unit]
    Description=restart
    After=default.target
    [Service]
    ExecStart=/etc/init.d/rk3568_auto_start.sh
    [Install]
    WantedBy=default.target

> #重新加载系统服务
sudo systemctl daemon-reload
sudo systemctl enable rk3568_auto_start.service
sudo systemctl start rk3568_auto_start.service
> #检测是否生效
sudo systemctl status rk3568_auto_start.service



## 实时性

> #1.不要运行 图形界面，而不绝对要求，特别是在服务器上。检查系统是否默认配置为引导到 GUI:
systemctl get-default
> #2.如果命令的输出是 graphical.target，请将系统配置为引导进入文本模式:
systemctl set-default multi-user.target

https://www.cnblogs.com/wsg1100/p/12730720.html
https://blog.csdn.net/qq_31985307/article/details/130791459



## vim
https://blog.csdn.net/amoscykl/article/details/80616688?spm=1001.2014.3001.5506

https://blog.csdn.net/zhangpower1993/article/details/52184581?spm=1001.2014.3001.5506

sudo apt install vim universal-ctags

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

> #直接命令行输入vim
vim
> #安装对应vimrc中的插件
:PluginInstall
> #查看已安装插件
:PluginList

### neovim && lazyvim
https://github.com/neovim/neovim
https://www.lazyvim.org/

> #直接下载nvim安装包
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
tar -xvzf nvim-linux64.tar.gz
> #创建软链接
cd /usr/bin
ln -s ~/Desktop/nvim-linux64/bin/nvim nvim
> #拷贝lazyvim的配置
git clone https://github.com/LazyVim/starter ~/.config/nvim
> 去除git库，后续可自行创建自己的nvim配置库
rm -rf ~/.config/nvim/.git