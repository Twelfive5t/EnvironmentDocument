# 开机自启动服务

## 创建启动脚本

1. 编辑 `rk3568_auto_start.sh` 启动脚本：

    ```bash
    vim /etc/init.d/rk3568_auto_start.sh
    ```

2. 脚本内容如下：

    ```bash
    #!/bin/bash
    sleep 5
    echo userspace > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
    echo 1416000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed
    ```

3. 使脚本可执行：

    ```bash
    sudo chmod +x /etc/init.d/rk3568_auto_start.sh
    ```

## 创建 systemd 服务

1. 编辑 `rk3568_auto_start.service` 服务文件：

    ```bash
    vim /etc/systemd/system/rk3568_auto_start.service
    ```

2. 服务文件内容如下：

    ```ini
    [Unit]
    Description=restart
    After=default.target

    [Service]
    ExecStart=/etc/init.d/rk3568_auto_start.sh

    [Install]
    WantedBy=default.target
    ```

## 启用并启动服务

1. 重新加载系统服务配置：

    ```bash
    sudo systemctl daemon-reload
    ```

2. 启用并启动服务：

    ```bash
    sudo systemctl enable rk3568_auto_start.service
    sudo systemctl start rk3568_auto_start.service
    ```

## 检查服务状态

1. 检查服务是否生效：

    ```bash
    sudo systemctl status rk3568_auto_start.service
    ```
