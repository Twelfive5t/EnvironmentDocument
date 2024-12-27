# Windows环境配置

## Windows Terminal配置

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

iex "& {$(irm get.scoop.sh)} -RunAsAdmin"

1. Terminal-Icons
powershell
复制代码
Install-Module -Name Terminal-Icons
2. PSReadLine
powershell
复制代码
Install-Module -Name PSReadLine
3. posh-git
powershell
复制代码
Install-Module -Name posh-git
4. ZLocation
powershell
复制代码
Install-Module -Name ZLocation
5. oh-my-posh
powershell
复制代码
scoop install oh-my-posh

参考$PROFILE
notepad $PROFILE

https://github.com/veeso/termscp/tree/v0.16.1
https://github.com/jixishi/SerialTerminalForWindowsTerminal?tab=readme-ov-file
https://www.nerdfonts.com/font-downloads

## Yazi配置

winget install Yazi
winget install 7zip.7zip jqlang.jq sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick

安装git后，将git的\\usr\\bin\\file.exe添加到环境变量YAZI_FILE_ONE中
