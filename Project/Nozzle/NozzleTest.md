# Nozzle 测试问题记录（RK3588）

## 已知问题及解决方案

### 问题 1：无法进入烧录模式

**原因**：新底板无 Reset 和 Recovery 按钮，无法进入 Loader 模式烧录。

**解决**：将新底板插至原底板上进行烧录。

### 问题 2：开机启动失败，卡死在 PCIe

**原因**：新底板没有 PCIe 3.0 硬件。

**解决**：进入内核配置，禁用 PCIe 3.0 × 4。

### 问题 3：插上网线后没有网络

**原因**：缺少对应 PHY 芯片驱动。

**解决**：在内核驱动中添加对应的 PHY 芯片驱动。

### 问题 4：SPI2 配置 spidev 导致开机失败

**原因**：SPI2 存在兼容问题，且 spi2m1 MISO 需取消。

**解决**：不使用 SPI2，改用 GPIO 模拟 SPI。

---

## 常用调试命令

### 内核镜像同步（scp）

```bash
# 推送 Image 到目标板
scp -r kernel/arch/arm64/boot/Image root@10.1.50.12:/boot/Image-5.10.198

# 推送 DTB 到目标板
scp -r kernel/arch/arm64/boot/dts/rockchip/rk3588-firefly-aio-3588q-mipi101-M101014-BE45-A1.dtb root@10.1.50.12:/boot

# 推送驱动模块到目标板
scp -r kernel/drivers/gpio/gpio-led.ko root@10.1.50.12:/home/firefly/Downloads/pipeline/test/

# 从远程拉取驱动模块
scp -r root@10.1.50.124:/root/proj/rk3588_sdk/kernel/drivers/gpio/gpio-led.ko /home/firefly/Downloads/pipeline/test/
```

### 内核配置

```bash
make ARCH=arm64 rockchip_linux_defconfig
make ARCH=arm64 menuconfig
make ARCH=arm64 savedefconfig
mv defconfig arch/arm64/configs/rockchip_linux_defconfig
```

### 网络

```bash
# 连接 Wi-Fi（有 Wi-Fi 时可用）
nmcli device wifi connect Fscut_office password fscut@64309023
```

### GPIO / Pinctrl 调试

```bash
cat /sys/kernel/debug/gpio
cat /sys/kernel/debug/pinctrl/pinctrl-rockchip-pinctrl/pinmux-pins
```
