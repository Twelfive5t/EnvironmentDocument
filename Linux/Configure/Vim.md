# Vim 与 Neovim 配置指南

> 本文档提供 Vim 和 Neovim (包括 LazyVim) 的安装、配置和使用说明。

## 目录

- [Vim 配置](#vim-配置)
  - [参考链接](#vim参考链接)
  - [安装与配置步骤](#1-安装-vim-和插件)
- [Neovim 与 LazyVim](#neovim-与-lazyvim)
  - [参考链接](#neovim参考链接)
  - [安装步骤](#1-安装-neovim)
  - [工具配置](#2-工具安装)
  - [Neovim 配置](#3-nvim-配置)

## Vim 配置

### Vim参考链接

- [Vim的终极配置方案，完美的写代码界面! ——.vimrc](https://blog.csdn.net/amoscykl/article/details/80616688)
- [vim插件管理器：Vundle的介绍及安装](https://blog.csdn.net/zhangpower1993/article/details/52184581)

### 1. 安装 `vim` 和插件

#### 1.1 检查 Vim 剪贴板支持

在安装前，先检查系统的 Vim 是否支持剪贴板操作：

```bash
# 检查 Vim 剪贴板支持
vim --version | grep clipboard
```

- 如果出现 `+clipboard`，说明支持剪贴板交互
- 如果出现 `-clipboard`，说明不支持剪贴板交互，需要安装 vim-gtk

#### 1.2 安装 Vim

```bash
# 如果剪贴板检查显示 "-clipboard"，则安装 vim-gtk 以获得剪贴板支持
sudo apt install -y vim-gtk universal-ctags

# 如果已经显示 "+clipboard"，则可以安装标准版本
# sudo apt install -y vim universal-ctags

# 安装完成后再次检查剪贴板支持
vim --version | grep clipboard
```

> **重要提示**：确保看到 `+clipboard` 才能在 Vim 中与系统剪贴板进行交互操作（如使用 `"+y` 复制到系统剪贴板，`"+p` 从系统剪贴板粘贴）。

#### 1.3 安装 Vundle 插件管理器

```bash
# 安装 Vundle 插件管理器
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

### 2. 编辑 `~/.vimrc`，安装插件

```bash
curl -o ~/.vimrc https://raw.githubusercontent.com/Twelfive5t/EnvironmentDocument/main/Linux/File/.vimrc
source ~/.vimrc
```

> **提示**：在此步骤中，您应该添加所需的 Vim 配置和插件。可参考下方提供的参考链接。

### 3. 安装插件

在 Vim 中执行以下命令：

```vim
:PluginInstall
```

> **说明**：此命令会打开一个新窗口，显示插件安装进度。安装完成后可按 `q` 关闭窗口。

### 4. 查看已安装插件

在 Vim 中执行以下命令：

```vim
:PluginList
```

## Neovim 与 LazyVim

### Neovim参考链接

- [Neovim GitHub 仓库](https://github.com/neovim/neovim)
- [LazyVim 官方网站](https://www.lazyvim.org/)
- [LazyVim 中文教程](https://soda.dnggentle.art)

### 1. 安装 Neovim

```bash
# 下载最新版 Neovim (此处示例版本为 0.11.1，请检查最新版本)
wget https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz

# 解压到系统目录
sudo tar -xzf nvim-linux-x86_64.tar.gz -C /usr/local --strip-components=1

# 验证安装
nvim --version

# 如果需要创建软链接（根据实际情况调整路径）
# ln -s ~/Desktop/nvim-linux64/bin/nvim /usr/bin/nvim

# 从干净的状态开始（如果需要重新配置）
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# 克隆 LazyVim 入门模板
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### 2. 工具安装

> **说明**：以下工具可以极大地提升 Neovim 的功能和使用体验。

#### 2.1 fzf 配置

[fzf](https://github.com/junegunn/fzf) 是一个通用的命令行模糊查找器，可以极大提高搜索效率。

##### 2.1.1 安装 fzf

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

##### 2.1.2 修改 `key-bindings.zsh` 配置

```bash
nvim ~/.fzf/shell/key-bindings.zsh
```

> **说明**：可以根据个人偏好调整快捷键，文件路径为 `~/.fzf/shell/key-bindings.zsh`。

##### 2.1.3 激活配置, 添加到 `~/.fzf.zsh` 中

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

#### 2.2 安装 lazygit

[lazygit](https://github.com/jesseduffield/lazygit) 是一个简单的终端 UI，用于 git 命令，支持键盘快捷操作。

```bash
# 下载最新版 lazygit (请检查最新版本)
LAZYGIT_VERSION="0.50.0"
curl -Lo lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar -xzf lazygit.tar.gz -C /usr/local/bin
sudo chmod +x /usr/local/bin/lazygit
lazygit --version
```

#### 2.3 安装 fd

[fd](https://github.com/sharkdp/fd) 是一个比 `find` 更简单、更快的替代品。

```bash
# 下载最新版 fd (请检查最新版本)
FD_VERSION="10.2.0"
curl -Lo fd.deb \
  "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-musl_${FD_VERSION}_amd64.deb"
sudo dpkg -i fd.deb
fd --version
```

#### 2.4 安装 ripgrep

[ripgrep (rg)](https://github.com/BurntSushi/ripgrep) 是一个比 grep 更快的搜索工具，对大型代码库尤其有效。

```bash
# 下载最新版 ripgrep (请检查最新版本)
RG_VERSION="14.1.1"
curl -Lo ripgrep.deb \
  "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}-1_amd64.deb"
sudo dpkg -i ripgrep.deb
rg --version
```

### 3. nvim 配置

#### 3.1 基本配置

将以下内容添加到 `~/.config/nvim/lua/config/options.lua` 文件中，或在 LazyVim 中创建自定义配置文件：

```lua
vim.g.encoding = "UTF-8" -- 默认编码格式为 "UTF-8"
vim.g.autoformat = false -- 默认关闭保存文件时自动格式化

local opt = vim.opt
opt.expandtab = true -- 使用空格代替 Tab 字符
opt.tabstop = 4 -- Tab 键显示为 4 个空格宽度
opt.shiftwidth = 4 -- 自动缩进宽度为 4 个空格
opt.softtabstop = 4 -- 编辑时 Tab 键等于 4 个空格
opt.relativenumber = false -- 是否显示相对行号
opt.listchars = "space:·" -- 不可见字符的显示，这里只把空格显示为一个点
vim.opt.listchars = {
  space = "·", -- 空格
--  eol = "$", -- 行尾符
  tab = ">-", -- 制表符
  trail = "·", -- 行尾空格
  lead = "·", -- 行首空格
  extends = "~", -- 超出屏幕右侧的文本
  precedes = "~", -- 超出屏幕左侧的文本
  conceal = "+", -- 被隐藏的字符
  nbsp = "&", -- 非断行空格
}
```
