# Docker 配置

## 1. 检查内核兼容性

```bash
curl https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh > check-config.sh

bash ./check-config.sh
```

## 2. 安装 Docker

```bash
wget -O- https://get.docker.com/ | sh
```

## 3. 添加代理配置

```bash
vim /lib/systemd/system/docker.service
```

```bash
Environment="all_proxy=http://10.1.61.147:7897"
Environment="http_proxy=http://10.1.61.147:7897"
Environment="https_proxy=http://10.1.61.147:7897"
Environment="no_proxy=localhost,127.0.0.1,.example.com"
Environment="ALL_PROXY=http://10.1.61.147:7897"
Environment="HTTP_PROXY=http://10.1.61.147:7897"
Environment="HTTPS_PROXY=http://10.1.61.147:7897"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
```

## 4. 重新加载并重启 Docker

```bash
systemctl daemon-reload
systemctl restart docker
systemctl show --property=Environment docker
```

## devcontainer 配置

```sh
PROXY=http://10.1.61.147:7897

docker build \
  --build-arg http_proxy="${PROXY}" \
  --build-arg https_proxy="${PROXY}" \
  --build-arg HTTP_PROXY="${PROXY}" \
  --build-arg HTTPS_PROXY="${PROXY}" \
  -t harbor.fscut.com/rtos/nozzle-devcontainer:latest \
  -f Dockerfile.devcontainer .
```

```dockerfile
USER root

RUN apt install -y zsh git curl wget
RUN chsh -s $(which zsh)
RUN sh -c "$(wget -O- https://install.ohmyz.sh/)"

RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
RUN git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
RUN git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
RUN git clone https://github.com/sunlei/zsh-ssh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-ssh

RUN curl -o ~/.p10k.zsh https://raw.githubusercontent.com/Twelfive5t/EnvironmentDocument/main/Linux/File/.p10k.zsh
RUN curl -o ~/.zshrc https://raw.githubusercontent.com/Twelfive5t/EnvironmentDocument/main/Linux/File/.zshrc
```
