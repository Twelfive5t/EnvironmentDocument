# Acrn Bios

参考 [Install Debian-based ECI Images (Generic) — ECI documentation](https://eci.intel.com/docs/3.0/get_started/install_generic.html)

`ctrl+alt+F11` 进入高级配置界面

| Setting Name | Option | Setting Menu | Note/Function (配置作用) |
| :--- | :--- | :--- | :--- |
| **Hyper-Threading** | Disabled | Advanced ⟶ Advanced ⟶ CPU Configuration | 禁用超线程，减少实时任务的抖动，提高确定性。 |
| **Intel Virtualization Technology (VT-x)** | Disabled* (see footnote) | Intel Advanced Menu ⟶ CPU Configuration | CPU 虚拟化支持。ACRN 需要开启，但在某些实时场景若不使用虚拟化可关闭以减少开销。 |
| **Intel(R) SpeedStep** | Disabled | Advanced ⟶ CPU Configuration | 禁用动态频率调整，防止 CPU 降频导致实时性能下降。 |
| **Turbo Mode** | Disabled | Advanced ⟶ CPU Configuration | 禁用睿频，保持 CPU 频率恒定，避免频率切换带来的延迟。 |
| **C States** | Disabled | Advanced ⟶ Advanced ⟶ Power & Performance ⟶ CPU - Power Management Control | 禁用 CPU 省电状态，防止 CPU 进入深度睡眠导致唤醒延迟。 |
| **RC6 (Render Standby)** | Disabled | Advanced ⟶ Advanced ⟶ Power & Performance ⟶ GT - Power Management Control | 禁用核显待机节能，防止图形单元休眠影响实时性。 |
| **Maximum GT freq** | Lowest (usually 100MHz) | Advanced ⟶ Advanced ⟶ Power & Performance ⟶ GT - Power Management Control | 降低核显频率，减少功耗和热量，避免影响 CPU 核心性能。 |
| **SA GV** | Fixed to 4th Point | Chipset ⟶ Chipset ⟶ System Agent (SA) Configuration ⟶ Memory Configuration | 固定 System Agent Geyserville (动态电压频率调整)，锁定内存/总线频率以保证确定性。 |
| **VT-d** | Enabled* (see footnote) | Chipset ⟶ Chipset ⟶ System Agent (SA) Configuration | 启用 I/O 虚拟化 (IOMMU)，ACRN 直通设备必须开启。 |
| **PCI Express Clock Gating** | Disabled | Intel Advanced Menu ⟶ System Agent (SA) Configuration ⟶ PCI Express Configuration | (没找到) 禁用 PCIe 时钟门控，防止 PCIe 链路进入低功耗状态增加延迟。 |
| **Gfx Low Power Mode** | Disabled | Intel Advanced Menu ⟶ System Agent (SA) Configuration ⟶ Graphics Configuration | (没找到) 禁用图形低功耗模式。 |
| **ACPI S3 Support** | Disabled | Advanced ⟶ Advanced ⟶ ACPI Settings | (没找到，ACPI Sleep State 配置为 Suspend Disabled) 禁用 S3 睡眠，实时系统通常不需要睡眠功能。 |
| **Native ASPM** | Disabled | Intel Advanced Menu ⟶ ACPI Settings | (没找到) 禁用操作系统控制的活动状态电源管理，防止 PCIe 链路节能。 |
| **Legacy IO Low Latency** | Enabled | Chipset ⟶ Chipset⟶ PCH-IO Configuration | 启用传统 I/O 低延迟模式，优化 I/O 响应速度。 |
| **PCH Cross Throttling** | Disabled | Chipset ⟶ Chipset ⟶ PCH-IO Configuration | 禁用 PCH 交叉节流，防止芯片组因热管理降低性能。 |
| **Delay Enable DMI ASPM** | Disabled | Intel Advanced Menu ⟶ PCH-IO Configuration ⟶ PCI Express Configuration | (没找到) 禁用 DMI 链路的 ASPM 延迟启用。 |
| **DMI Link ASPM** | Disabled | Intel Advanced Menu ⟶ PCH-IO Configuration ⟶ PCI Express Configuration | 禁用 CPU 与 PCH 之间 DMI 链路的节能模式，保证带宽和低延迟。 |
| **Aggressive LPM Support** | Disabled | Intel Advanced Menu ⟶ PCH-IO Configuration ⟶ SATA And RST Configuration | (没找到) 禁用 SATA 激进链路电源管理，防止硬盘接口进入低功耗导致延迟。 |
| **USB Periodic SMI** | Disabled | Intel Advanced Menu ⟶ LEGACY USB Configuration | (没找到) 禁用 USB 周期性系统管理中断，减少 SMI 对实时任务的干扰。 |
| **Above 4GB MMIO BIOS assignment** | Disabled | Chipset ⟶ Chipset ⟶ System Agent (SA) Configuration | 禁用 4GB 以上 MMIO 分配，某些旧系统或特定配置可能需要禁用以避免兼容性问题。 |
| **PM Support** | Enabled | Intel Advanced Menu ⟶ System Agent (SA) Configuration ⟶ Graphics Configuration | (没找到) 启用电源管理支持 (通常指图形部分的基础 PM 支持)。 |
| **DVMT Pre-Allocated** | 64M | Chipset ⟶ System Agent (SA) Configuration ⟶ Graphics Configuration | 预分配显存大小，ACRN 共享显存通常需要固定大小。 |

> **Footnote:**
>
> * **VT-x** and **VT-d** are required by most virtualization solutions (KVM, RTH Hypervisor, ACRN Hypervisor, etc.), so set to **Enabled** for greatest compatibility. However, if you know that virtualization will not be used, you can safely set VT-x and VT-d to disabled.
