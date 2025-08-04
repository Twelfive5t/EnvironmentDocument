# Zsh 配置

## 更新软件源并安装 Zsh 和相关工具

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y zsh git curl
```

## 切换终端为 Zsh

```bash
chsh -s /bin/zsh
```

## 下载 oh-my-zsh 和插件

- 使用以下任意方法安装 `oh-my-zsh`：

```bash
sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
```

```bash
sh -c "$(wget -O- https://install.ohmyz.sh/)"
```

## 克隆插件

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
git clone https://github.com/sunlei/zsh-ssh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-ssh
```

## 修改 Zsh 配置并使修改生效(见.zshrc)

```bash
curl -o ~/.zshrc https://raw.githubusercontent.com/Twelfive5t/EnvironmentDocument/main/Linux/File/.zshrc
source ~/.zshrc
```
