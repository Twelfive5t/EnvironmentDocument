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
Environment="ALL_PROXY=http://10.1.50.43:7897"
Environment="HTTP_PROXY=http://10.1.50.43:7897"
Environment="HTTPS_PROXY=http://10.1.50.43:7897"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
```

## 4. 重新加载并重启 Docker

```bash
systemctl daemon-reload
systemctl restart docker
systemctl show --property=Environment docker
```
