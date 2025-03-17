# Windows环境配置

## Windows Terminal配置

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
```

### PowerShell 模块安装

```powershell
# 1. Terminal-Icons - 为 PowerShell 提供文件图标
Install-Module -Name Terminal-Icons

# 2. PSReadLine - 命令行编辑增强
Install-Module -Name PSReadLine

# 3. posh-git - Git 集成
Install-Module -Name posh-git

# 4. ZLocation - 智能目录跳转
Install-Module -Name ZLocation

# 5. oh-my-posh - 终端美化
scoop install oh-my-posh
```

### PowerShell 配置文件

```powershell
# 编辑 PowerShell 配置文件
notepad $PROFILE
```

### 有用的资源

- [查看 termscp v0.16.1 版本](https://github.com/veeso/termscp/tree/v0.16.1)
- [访问 SerialTerminalForWindowsTerminal 项目](https://github.com/jixishi/SerialTerminalForWindowsTerminal?tab=readme-ov-file)
- [下载 Nerd Fonts](https://www.nerdfonts.com/font-downloads)

## Yazi 文件管理器配置

```powershell
# 安装 Yazi
winget install Yazi

# 安装依赖工具
winget install 7zip.7zip jqlang.jq sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick

# 配置环境变量
[Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", "C:\Program Files\Git\usr\bin\file.exe", "User")
```

> 注意：请根据 Git 实际安装路径调整上述环境变量路径