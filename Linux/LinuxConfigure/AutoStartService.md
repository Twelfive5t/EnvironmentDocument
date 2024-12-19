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