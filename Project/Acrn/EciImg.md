# EciImg

## 常用命令

```bash

qemu-img create -f raw win10-file.img 50G
```

```bash
mount -o loop,offset=1048576 /root/acrn-work/img/eci.wic /root/acrn-work/img/myloop1
vim /root/acrn-work/img/myloop1/EFI/BOOT/grub.cfg
umount /root/acrn-work/img/myloop1
```
