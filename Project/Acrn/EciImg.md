# EciImg

## 常用命令

deb包编译

```bash
cd ~/acrn-work/acrn-hypervisor
make clean
debian/debian_build.sh clean && debian/debian_build.sh -c ~/acrn-work/MyConfiguration

sudo scp ~/acrn-work/acrn*.deb ~/acrn-work/grub*.deb ~/acrn-work/*acrn-service-vm*.deb ubuntu@10.1.61.32:/tmp

#切到目标机
sudo apt purge -y acrn-hypervisor
sudo apt install -y /tmp/acrn-hypervisor*.deb  /tmp/*acrn-service-vm*.deb
```

qemu创建空白镜像

```bash
qemu-img create -f raw win10-file.img 50G
```

eci挂载镜像后修改grub启动项

```bash
mount -o loop,offset=1048576 /root/acrn-work/img/eci.wic /root/acrn-work/img/myloop1
vim /root/acrn-work/img/myloop1/EFI/BOOT/grub.cfg
umount /root/acrn-work/img/myloop1
```

windows镜像添加cd用于安装系统

```bash
# 重装windows镜像记得替换OVMF
`add_virtual_device                       11 ahci cd:/home/acrn/acrn-work/OSImage/win10-ltsc.iso`
    `add_virtual_device                       12 ahci cd:/home/acrn/acrn-work/OSImage/winvirtio.iso`
```

winvm镜像压缩

```bash
sudo qemu-img convert -f raw -O qcow2 win10-ltsc.img win10-ltsc.qcow2
sudo qemu-img convert -f qcow2 -O raw win10-ltsc.qcow2 win10-ltsc.img
```

rtvm扩容

```bash
qemu-img resize eci.wic +5G
# 进入rtvm
sudo apt-get update
sudo apt-get install cloud-guest-utils
sudo growpart /dev/vda 2
sudo resize2fs /dev/vda2
```

winvm扩容

```powershell
diskpart
list disk
select disk 0
list volume
select volume 2
delete volume override
# 然后磁盘管理手动扩容
```

winvm配置

```powershell
# 开测试模式
bcdedit /set testsigning on
# 时区配置
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```
