# 实时性优化

针对 x86 ACRN 主机与 ARM RK3588 主机的实时性能优化方案，从最底层（BIOS/固件）到最上层（应用程序线程）逐层配置，确保端到端的确定性。

参考文档：
- [ECI Real-Time Scheduling](https://eci.intel.com/docs/3.3/development/performance/rt_scheduling.html)
- [ECI Linux OS Runtime Optimizations](https://eci.intel.com/docs/3.3/development/performance/optimizations.html)

## 📐 调度延迟模型

> **Scheduling Latency = Interrupt Latency + Handler Duration + Scheduler Latency + Scheduler Duration**

实时优化的目标是最小化上式右端每一项：

| 项 | 含义 | 主要影响因素 |
| :--- | :--- | :--- |
| Interrupt Latency | 硬件事件到 CPU 开始执行 ISR 的时间 | SMI、C-State 唤醒、中断屏蔽时长 |
| Handler Duration | ISR 执行时长 | 中断类型 (MSI/legacy)、上下半部拆分 |
| Scheduler Latency | ISR 完成到目标任务被调度的时间 | 调度策略、优先级、抢占配置 |
| Scheduler Duration | 上下文切换本身的时间 | TLB flush、缓存冷热、进程/线程切换 |

优化遵循 **自底向上** 的顺序：固件层 → 内核启动参数 → 运行时电源/频率 → 系统服务 → 中断亲和 → 内存锁定 → 线程调度与绑核。下层未配置好时，上层的优化效果会被抵消。

---

## 平台差异总览

x86 ACRN 与 ARM RK3588 在固件、中断源、时钟源、电源管理驱动上差异显著，需区分配置：

| 维度 | x86 ACRN | ARM RK3588 |
| :--- | :--- | :--- |
| 固件 | UEFI BIOS（含 SMI） | U-Boot / EDK2 UEFI（无 SMI） |
| 中断源 | MSI / legacy PIC / NMI / SMI / SCI | GICv3（无 SMI、无 NMI 等价物） |
| 时钟源 | TSC / HPET | arch_timer（无 TSC、无 HPET） |
| 频率调节驱动 | `intel_pstate` / `acpi-cpufreq` | `cpufreq-dt` |
| 空闲驱动 | `intel_idle` / ACPI processor | `cpuidle` |
| 错误检查 | MCE | 无 MCE（RAS 另有机制） |
| 超线程 | Intel HT | 无（big.LITTLE 大小核） |
| 核显 | i915 | Mali（不在此优化范围） |
| 大页 | `hugepages=` 预分配 | 默认不使用（见 6.3 说明） |
| CPU 拓扑 | 物理核 + 超线程兄弟核 | A55(LITTLE,0-3) + A76(big,4-7) |
| 隔离核选择 | 13 代及更早隔离 1/3，14 代隔离 2/4 | 隔离 A76 大核 4-7（按需子集） |

> 后续每层在差异处用 **[x86]** / **[ARM]** 标注。两者通用的配置不标注。

---

## 第 1 层：BIOS / 固件配置

**[x86]** BIOS 是实时性的基础，固件层的 SMI、C-State、动态调频对 OS 不可见且不可拦截，必须先在固件层关闭。完整配置表见 [AcrnBios.md](./AcrnBios.md)，此处不再重复。

**[ARM]** RK3588 无 SMI、无 BIOS 级动态调频开关，固件层优化集中在 BL31 / U-Boot：

- **使用 RT 版本 BL31**：实时性能更好。RK3568 需用 RT 版 BL31（uboot 执行 `./make.sh rk3568-rt`），RK3588 同样推荐使用带 RT 优化的 rkbin/BL31。开机日志出现 `cache_write_streaming_cfg` 与 `l3 cache partition cfg-xxxx` 打印即说明 RT BL31 已生效：
  ```
  INFO:    cache_write_streaming_cfg:0 2808bc00 PCTL:L3-7 L1-5 WSCTL:L1-0 L3-1
  INFO:    l3 cache partition cfg-8421
  ```
- **L3 缓存分片**：ARM Cortex-A55 架构支持将 L3 空间划分为 4 块，按 CPU 分配，通过 rkbin 的 `RKBOOT/RKxxxxMINIALL.ini` 中 `WORD_3` 配置（详见第 8 层）。
- 固件层可配置项远多于一般认知，但绝大多数仍需在内核与用户态配合完成。

---

## 第 2 层：内核启动命令行参数

通过 GRUB（x86）或 U-Boot/ extlinux（ARM）的启动参数实现 CPU 隔离、电源管理关闭、定时器配置。

### 2.1 [x86] 完整启动参数示例

本项目实际使用参数（见 [eci_grub.cfg](./eci_grub.cfg)）：

```bash
linux /boot/vmlinuz root=PARTUUID=... rootwait \
    console=ttyS0,115200 console=tty0 \
    clocksource=tsc tsc=reliable \
    no_ipi_broadcast=1 nosoftlockup efi=runtime \
    numa_balancing=disable hugepages=1024 audit=0 \
    nmi_watchdog=0 irqaffinity=0 mce=off hpet=disable \
    rcupdate.rcu_cpu_stall_suppress=1 rcu_nocb_poll noht \
    isolcpus=1-2 rcu_nocbs=1-2 nohz_full=1-2 \
    intel_pstate=disable intel.max_cstate=0 intel_idle.max_cstate=0 \
    processor.max_cstate=0 processor_idle.max_cstate=0 \
    i915.force_probe=* i915.enable_rc6=0 i915.enable_dc=0 i915.disable_power_well=0 \
    igb.blacklist=no
```

### 2.2 [ARM] RK3588 启动参数示例

```bash
console=ttyFIQ0,1500000 \
    isolcpus=4-7 rcu_nocbs=4-7 nohz_full=4-7 irqaffinity=0 \
    cpuidle.off=1 idle=poll \
    nohz_full rcupdate.rcu_cpu_stall_suppress=1 rcu_nocb_poll \
    audit=0 nosoftlockup \
    cpufreq.default_governor=performance
```

### 2.3 参数分类说明

#### A. 通用参数（x86 / ARM 均适用）

| 参数 | 说明 |
| :--- | :--- |
| `isolcpus=<cpus>` | 将指定 CPU 从通用调度器中移除，仅留给实时任务通过 `taskset` / `pthread_setaffinity` 显式绑定。x86 取隔离核（如 1-2），ARM 取 A76 大核（如 4-7） |
| `rcu_nocbs=<cpus>` | 将隔离核的 RCU 回调卸载到未隔离核，避免 RCU 打断实时任务 |
| `nohz_full=<cpus>` | 隔离核进入 tickless 模式，无任务运行时停止本地时钟中断 |
| `irqaffinity=0` | 所有未指定亲和的中断默认路由到 CPU 0，远离隔离核 |
| `audit=0` | 关闭审计子系统，减少后台开销 |
| `nosoftlockup` | 关闭软锁死检测，避免隔离核上长时间运行的实时任务被误报 |
| `rcupdate.rcu_cpu_stall_suppress=1` | 抑制 RCU stall 警告，隔离核上 RCU 不动作不应触发告警 |
| `rcu_nocb_poll` | RCU offload 线程使用轮询而非等待唤醒，减少唤醒延迟 |

#### B. [x86] 专用参数

| 参数 | 说明 |
| :--- | :--- |
| `clocksource=tsc` `tsc=reliable` | 使用 TSC 作为时钟源，延迟最低；标记为可靠避免回退到 HPET |
| `hpet=disable` | 禁用 HPET，其访问延迟高于 TSC |
| `nmi_watchdog=0` | 关闭 NMI 看门狗，避免周期性 NMI 抢占 |
| `mce=off` | 关闭机器检查中断，防止周期性硬件错误扫描抢占实时任务 |
| `intel_pstate=disable` | 禁用 Intel 动态调频驱动，交由 cpufreq performance governor 固定频率 |
| `intel.max_cstate=0` `intel_idle.max_cstate=0` | 禁用 Intel idle 驱动的 C-State，CPU 不进入深度睡眠 |
| `processor.max_cstate=0` `processor_idle.max_cstate=0` | 禁用 ACPI 处理器 idle 的 C-State |
| `noht` | 内核层禁用超线程（与 BIOS 双重保障） |
| `hugepages=1024` | 预分配 1024 个大页，减少 TLB miss，降低内存访问抖动（ARM 见 6.3） |
| `numa_balancing=disable` | 禁用 NUMA 自动平衡，防止页面跨节点迁移增加访问延迟 |
| `i915.enable_rc6=0` `i915.enable_dc=0` `i915.disable_power_well=0` | 关闭核显 i915 节能，减少 GPU 生成的中断 |
| `i915.force_probe=*` `igb.blacklist=no` | 强制加载 i915、不禁用 igb 网卡驱动 |
| `no_ipi_broadcast=1` | 关闭 IPI 广播，减少核间中断抖动 |
| `efi=runtime` | 保留 EFI runtime 服务 |

#### C. [ARM] RK3588 专用参数

| 参数 | 说明 |
| :--- | :--- |
| `cpuidle.off=1` | 禁用 cpuidle 框架，CPU 不进入空闲子状态（ARM 对应 x86 的 C-State 关闭） |
| `idle=poll` | 强制空闲时轮询而非进入低功耗状态，消除 idle 唤醒延迟（耗电换确定性） |
| `cpufreq.default_governor=performance` | 默认使用 performance governor，固定最高频率（RK3588 对应 x86 的 `intel_pstate=disable` + governor 设置） |

> RK3588 无 TSC/HPET/MCE/NMI/超线程/i915，这些参数在 ARM 上不存在，不要照搬 x86 配置。

### 2.4 内核配置要求

启动参数生效需要内核已启用相应配置（PREEMPT_RT 内核默认启用）：

```
CONFIG_PREEMPT_RT=y            # 实时抢占
CONFIG_PREEMPT_RCU=y           # RCU 读侧可抢占
CONFIG_RCU_NOCB_CPU=y          # RCU 回调卸载
CONFIG_RCU_BOOST=y             # RCU 优先级提升
CONFIG_RCU_KTHREAD_PRIO=1
CONFIG_HIGH_RES_TIMERS=y       # 高精度定时器
CONFIG_NO_HZ_FULL=y            # tickless 支持
```

---

## 第 3 层：运行时 CPU 频率与电源管理

BIOS 和启动参数已关闭硬件层调频，运行时仍需确保 cpufreq governor 固定为 `performance`，防止 ondemand 调频抖动。

### 3.1 固定 CPU 频率

```bash
# 查看当前 governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 设置所有核为 performance（最高频率固定）
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee $cpu
done

# 查看当前频率（应固定为最大频率）
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
```

### 3.2 运行时关闭 C-State / 空闲状态

**[x86]** 若 BIOS 无法完全关闭，可在运行时通过 PM QoS 限制：

```bash
for f in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
    echo 1 | sudo tee $f
done
```

**[ARM]** RK3588 通过 cpuidle sysfs 关闭各 idle state（启动参数已加 `cpuidle.off=1`，此处为运行时补充）：

```bash
for f in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
    echo 1 | sudo tee $f
done
```

### 3.3 [x86] 关闭机器检查扫描

ARM 无 MCE，此步仅 x86 需要：

```bash
echo 0 | sudo tee /sys/devices/system/machinecheck/machinecheck0/check_interval
```

---

## 第 4 层：系统服务清理

减少后台活动是消除不确定性的重要环节。停止与实时无关的服务，可显著减少中断与调度抖动。x86 与 ARM 通用。

### 4.1 列出与停止服务

```bash
# 列出已加载的 service
systemctl -t service

# 停止常见无关服务
sudo systemctl stop ofono
sudo systemctl stop wpa_supplicant
sudo systemctl stop bluetooth
sudo systemctl stop docker      # 若不使用容器
sudo systemctl stop snapd
sudo systemctl stop cups
```

> **警告**：停止系统服务可能影响系统稳定性，生产环境需逐项评估，建议先在测试机验证。

### 4.2 关闭实时运行时配额

默认实时任务只能获得 95% CPU 时间，5% 留给非实时任务。无界轮询型实时负载需放开此限制：

```bash
# 设置为无限制（谨慎使用：若实时任务存在死循环会锁死系统）
echo -1 | sudo tee /proc/sys/kernel/sched_rt_runtime_us
```

---

## 第 5 层：中断亲和性

将中断集中到 CPU 0，隔离核不处理任何中断，保证实时任务不被打断。

### 5.1 [x86] 网卡中断重映射

ECI 提供 `network-irq-affinity` 工具，将网卡各 TxRx 队列的中断映射到指定核：

```bash
sudo apt install network-irq-affinity

sudo network-irq-affinity \
    -i enp5s0-TxRx-1/1 -i enp4s0-TxRx-1/1 \
    -i enp4s0-TxRx-*/2 -i enp5s0-TxRx-*/3 -v

# 验证
cat /proc/interrupts | grep -e CPU. -e enp.s.
```

### 5.2 全量中断亲和到 CPU 0

将所有非实时中断（除 timer=0、cascade=2）绑定到 CPU 0，x86 与 ARM 通用：

```bash
#!/bin/bash
for i in $(cat /proc/interrupts | grep '^ *[0-9]*[0-9]:' | awk '{print $1}' | sed 's/:$//'); do
    [ "$i" = "0" ] && continue   # Timer
    [ "$i" = "2" ] && continue   # cascade（x86 PIC 级联；ARM 可忽略）
    echo "setting IRQ $i to affine for core 0"
    echo 1 > /proc/irq/$i/smp_affinity
done
```

### 5.3 RCU 卸载线程绑到 CPU 0

```bash
for i in $(pgrep rcu); do
    taskset -pc 0 $i > /dev/null
done
```

---

## 第 6 层：应用内存锁定

实时进程在缺页换页时会产生毫秒级延迟，必须在启动后立即锁住全部内存，并在程序代码中预触碰所有页。x86 与 ARM 通用。

### 6.1 程序内锁定

```c
#define _GNU_SOURCE
#include <sys/mman.h>
#include <string.h>
#include <stdio.h>

int main(void) {
    /* 锁定当前及未来所有页到物理内存，禁止换出 */
    if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) {
        perror("mlockall");
        return -1;
    }
    /* 预触碰所有实时数据缓冲，避免运行时首次访问触发缺页 */
    memset(buffer, 0, sizeof(buffer));
    ...
}
```

| API | 作用 |
| :--- | :--- |
| `mlockall(MCL_CURRENT \| MCL_FUTURE)` | 锁定当前及未来所有页 |
| `mlock(addr, len)` | 锁定指定地址区间 |
| `munlock` / `munlockall` | 解锁 |

> 实时进程通常在整个运行周期内保持内存锁定。`/etc/security/limits.conf` 需配置 `@realtime - memlock unlimited` 或对应用用户放开 `RLIMIT_MEMLOCK`。

### 6.2 [x86] 结合大页减少 TLB 抖动

启动参数已预分配 `hugepages=1024`，应用可使用 `mmap(MAP_HUGETLB)` 或 `libhugetlbfs` 申请大页，进一步降低 TLB miss 延迟。

### 6.3 [ARM] RK3588 大页说明

ARM64 同样支持 hugetext（2MB / 1GB 大页），但 RK3588 实时场景下通常不预分配固定数量大页：一是 RK3588 内存有限，二是 ARM 的 TTBR / TLB 管理与 x86 不同，默认页表配置已能满足需求。如需使用，按需在启动参数中指定 `transparent_hugepage=never` 并显式 `mmap(MAP_HUGETLB)`，而非照搬 x86 的 `hugepages=1024`。

---

## 第 7 层：线程调度策略与优先级

PREEMPT_RT 内核提供三类实时调度策略，优先级从低到高：`SCHED_FIFO` / `SCHED_RR` < `SCHED_DEADLINE`。线程优先级、调度策略属程序内配置，应直接在应用代码中完成（见 7.4 工程实现），而非依赖外部 `chrt`。

### 7.1 调度策略对比

| 策略 | 特性 | 优先级范围 | 适用场景 |
| :--- | :--- | :--- | :--- |
| `SCHED_FIFO` | 先进先出，无时间片，运行至被抢占/阻塞/让出 | 1–99 | 周期型实时任务，单核独占 |
| `SCHED_RR` | 同 FIFO，但加入时间片轮转 | 1–99 | 同优先级多任务需轮流运行 |
| `SCHED_DEADLINE` | EDF + CBS，基于 Runtime/Deadline/Period | 最高（可抢占所有其他策略） | 硬实时、有严格周期与截止时间约束的任务 |

> `SCHED_DEADLINE` 线程一旦 runnable 即抢占任何其他策略线程；若任一 DEADLINE 线程可运行，它优先于所有 FIFO/RR/OTHER。

### 7.2 运行时验证与临时设置（`chrt`）

程序未内建调度配置时，可用 `chrt` 临时验证：

```bash
# SCHED_FIFO，优先级 1
sudo chrt -f 1 <workload>

# 查看进程调度策略与优先级
ps f -g 0 -o pid,policy,rtprio,cmd
```

### 7.3 默认优先级参考（PREEMPT_RT）

| 优先级 | 任务 |
| :--- | :--- |
| 99 | posixcputmr, migration |
| 50 | 大多数 IRQ 线程化处理函数 |
| 49 | mmc0 / mmc1 的 IRQ 处理函数 |
| 1 | i915/signal, ktimersoftd, rcu_preempt, rcu_sched, rcub, rcuc |
| 0 | 其余普通任务 |

应用实时线程优先级通常设为 **1–49**（高于普通任务，低于关键内核线程），避免抢占必要的系统维护线程。

### 7.4 工程实现（程序内设置）

线程优先级、调度策略、CPU 亲和性均应在程序内通过 pthread 接口设置。以下为项目实际使用的实现（见 `osal/linux/osal_thread.c`），线程创建时即完成栈大小、`SCHED_FIFO` 策略、优先级、CPU 亲和性的全部配置。

#### 创建线程（栈大小 + SCHED_FIFO + 优先级 + CPU 亲和性 + 线程名）

```c
/**
 * @file osal_thread.c
 * @brief Linux platform thread implementation for OSAL
 */
#include "osal/osal_thread.h"
#include "osal/osal_types.h"
#include "osal/osal_mem.h"
#include <pthread.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct osal_thread_impl {
    pthread_t thread;
};

int osal_thread_create(osal_thread_func_t task, const char* name, void* parameter,
                        size_t stack_size, int cpu_affinity, int priority,
                        osal_thread_t* thread)
{
    pthread_attr_t attr;
    struct sched_param sched_param;
    int ret;

    if (thread == NULL) {
        printf("Invalid thread(%s) pointer\n", name ? name : "Unknown");
        return -1;
    }

    struct osal_thread_impl* t = (struct osal_thread_impl*)malloc(sizeof(struct osal_thread_impl));
    if (t == NULL) {
        fprintf(stderr, "Failed to allocate memory for thread\n");
        return -1;
    }

    ret = pthread_attr_init(&attr);
    if (ret) { printf("%s pthread attributes failed: %s\n", name, strerror(ret)); goto Failed; }

    /* 设置堆栈空间大小 */
    ret = pthread_attr_setstacksize(&attr, stack_size);
    if (ret) { printf("%s pthread setstacksize failed: %s\n", name, strerror(ret)); goto Failed; }

    /* 设置调度策略（FIFO）和优先级 */
    ret = pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
    if (ret) { printf("%s pthread setschedpolicy failed: %s\n", name, strerror(ret)); goto Failed; }
    sched_param.sched_priority = priority;
    ret = pthread_attr_setschedparam(&attr, &sched_param);
    if (ret) { printf("%s pthread setschedparam failed: %s\n", name, strerror(ret)); goto Failed; }

    /* 关键：显式调度，不继承主线程策略，否则上面的 FIFO+priority 不生效 */
    ret = pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
    if (ret) { printf("%s pthread setinheritschedfailed: %s\n", name, strerror(ret)); goto Failed; }

    /* 设置线程的 CPU 亲和性（绑到隔离核） */
    if (cpu_affinity >= 0) {
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(cpu_affinity, &cpuset);
        ret = pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpuset);
        if (ret) { printf("%s pthread pthread_setaffinity_npfailed: %s\n", name, strerror(ret)); goto Failed; }
    }

    /* 创建具有指定属性的线程 */
    ret = pthread_create(&(t->thread), &attr, (void* (*)(void*))task, parameter);
    if (ret) { printf("create %s pthread failed: %s\n", name, strerror(ret)); goto Failed; }

    /* 设置线程名称（名字长度 < 15 个字符，非 POSIX 标准接口，跨平台可能存在差异） */
    if (name != NULL) {
        char threadName[16] = {0};
        size_t name_len = strlen(name);
        if (name_len > 15) {
            memcpy(threadName, name, 15);
            threadName[15] = '\0';
            printf("Thread name is out of range, changed to %s\n", threadName);
        } else {
            memcpy(threadName, name, name_len);
            threadName[name_len] = '\0';
        }
        ret = pthread_setname_np(t->thread, threadName);
        if (ret) { printf("%s pthread_setname_np failed: %s\n", name, strerror(ret)); free(t); pthread_attr_destroy(&attr); return -1; }
    }

    pthread_attr_destroy(&attr);
    *thread = (osal_thread_t)t;
    return 0;

Failed:
    pthread_attr_destroy(&attr);
    free(t);
    return -1;
}
```

> 要点：`pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED)` 是必须的——若使用默认的 `PTHREAD_INHERIT_SCHED`，子线程会继承创建者（通常是普通 SCHED_OTHER）的策略，前面设置的 `SCHED_FIFO` 与优先级不会生效。

#### 运行时修改优先级

```c
/* 设置线程优先级（运行中调整） */
int osal_thread_set_priority(osal_thread_t thread, int priority) {
    if (thread == NULL) { return -1; }
    struct sched_param param;
    param.sched_priority = priority;
    return pthread_setschedparam(thread->thread, SCHED_FIFO, &param) == 0 ? 0 : -1;
}

/* 获取线程优先级 */
int osal_thread_get_priority(osal_thread_t thread) {
    if (thread == NULL) { return -1; }
    struct sched_param param;
    int policy;
    if (pthread_getschedparam(thread->thread, &policy, &param) != 0) { return -1; }
    return param.sched_priority;
}
```

### 7.5 运行时修改 CPU 亲和性（位掩码形式）

第 7.4 节在线程创建时用 `pthread_attr_setaffinity_np` 绑核；线程运行后需调整亲和性时，用 `pthread_setaffinity_np` 以位掩码形式设置：

```c
/* 设置线程 CPU 亲和性（cpu_mask 为位掩码，bit i 置位表示绑核 i） */
int osal_thread_set_affinity(osal_thread_t thread, uint64_t cpu_mask) {
    if (thread == NULL) { return -1; }
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    for (int i = 0; i < 64; i++) {
        if (cpu_mask & (1ULL << i)) {
            CPU_SET(i, &cpuset);
        }
    }
    return pthread_setaffinity_np(thread->thread, sizeof(cpu_set_t), &cpuset) == 0 ? 0 : -1;
}
```

调用示例（绑到隔离核 3）：

```c
/* x86: 绑核 3 */
osal_thread_set_affinity(thread, (1ULL << 3));

/* ARM RK3588: 绑核 4（A76 大核） */
osal_thread_set_affinity(thread, (1ULL << 4));
```

### 7.6 优先级继承

`CONFIG_PREEMPT_RT` 为 `rtmutex`、`spin_lock`、`mutex` 提供优先级继承：锁持有者自动继承等待该锁的最高优先级线程的优先级，防止优先级反转。使用 `pthread_mutex` 时建议使用 `PTHREAD_PRIO_INHERIT` 协议：

```c
pthread_mutexattr_t mattr;
pthread_mutexattr_init(&mattr);
pthread_mutexattr_setprotocol(&mattr, PTHREAD_PRIO_INHERIT);
pthread_mutex_init(&mutex, &mattr);
```

---

## 第 8 层：缓存分区

缓存分区让实时核独占一段 L2/L3，避免与系统核争用缓存引发抖动。x86 与 ARM 实现机制完全不同：

| 平台 | 机制 | 配置位置 | 工具 |
| :--- | :--- | :--- | :--- |
| [x86] Intel | Intel CAT (Cache Allocation Technology) / resctrl | 运行时 sysfs | `pqos` |
| [ARM] Rockchip | BL31 固件 L3 分片 | rkbin `RKBOOT/RKxxxxMINIALL.ini` `WORD_3` | 无（固件层） |

### 8.1 [x86] Intel CAT（`pqos`）

使用 `pqos` 工具按核划分 L3/L2 缓存：

```bash
# Intel Core / Xeon（共享 L3）
sudo pqos -R                                  # 重置
sudo pqos -e 'llc:0=0x0f;llc:1=0xf0'          # 0 类用前半，1 类用后半
sudo pqos -a 'llc:0=0;llc:1=1,3'              # CPU 0 归 0 类，CPU 1/3 归 1 类

# Intel Atom（共享 L2）
sudo pqos -R
sudo pqos -e 'l2:0=0x0f;l2:1=0xf0'
sudo pqos -a 'llc:0=0,2;llc:1=1,3'
```

### 8.2 [ARM] Rockchip L3 缓存分片（BL31 固件）

ARM Cortex-A55 架构支持对 L3 空间进行划分：**L3 空间划分为 4 块（P0/P1/P2/P3）**，可配置每个 CPU 使用 4 块中的哪几块。该方法在 rkbin 的 `RKBOOT/RKxxxxMINIALL.ini` 中通过 `WORD_3` 配置，由 BL31 在启动时编程生效。

> 参考来源：`firefly_rk3568_SDK/docs/Patches/Real-Time-Performance/README.md`（RK3568 Cortex-A55 实测）。RK3588 的 `rkbin/RKBOOT/RK3588MINIALL.ini` 同样存在 `WORD_3` 旋钮（默认 `0x0`，即不分片），但 RK3588 为 big.LITTLE（A76+A55），L3 拓扑与 4×A55 不同，具体分片编码需以板载 BSP 指南为准。

#### 配置方法

编辑 `rkbin/RKBOOT/RK3568MINIALL.ini`（RK3588 对应 `RK3588MINIALL.ini`）：

```ini
[BOOT1_PARAM]
WORD_3=0xc333
```

#### WORD_3 编码说明（RK3568，4 核 4 块 L3）

`WORD_3` 为 16 位，每 4 位分配给一个 CPU，表示该 CPU 可使用的 L3 块掩码：

| 位域 | 分配对象 | 掩码含义 |
| :--- | :--- | :--- |
| bit0~bit3 | cpu0 | bit0=1 → P0 给 cpu0，bit1=1 → P1 给 cpu0，以此类推 |
| bit4~bit7 | cpu1 | 同上 |
| bit8~bit11 | cpu2 | 同上 |
| bit12~bit15 | cpu3 | 同上 |

#### 配置示例

| WORD_3 | 拆分 | 含义 |
| :--- | :--- | :--- |
| `0x3333` | cpu0/1/2/3 各得 P0,P1 | 默认（所有核共享前半 L3） |
| `0xc333` | cpu0/1/2 得 P0,P1；cpu3 得 P2,P3 | **实时核 cpu3 独占后半 L3**，与系统核隔离 |
| `0x3333` ↔ `0xcccc` | 前半/后半 | 两两分片 |

> `0xc333` 即给实时核 cpu3 分配独立 256K L3，是 RT 场景的典型配置。配置后开机日志可确认：
> ```
> INFO: L3 cache partition cfg-c333
> ```

#### 与 CPU 隔离配合

L3 分片需与第 2 层的 `isolcpus` / `nohz_full` 配合，将实时核隔离出来：

```dts
/* arch/arm64/boot/dts/rockchip/rk3568-linux.dtsi */
chosen {
    bootargs = "earlycon=uart8250,mmio32,0xfe660000 isolcpus=3 nohz_full=3 console=ttyFIQ0 root=PARTUUID=... rw rootwait";
};
```

实时任务绑定到隔离核运行（见第 7 层程序内绑核，或临时用 `taskset`）：

```bash
# 将 cyclictest 绑定到实时核 cpu3
taskset -c 3 cyclictest -c 0 -m -t -p99 -D 12h
# 验证绑定
ps -eo pid,psr,comm | grep cyclictest
```

> 注意：L3 分片在 BL31 固件层生效，**运行时无法动态修改**（不同于 x86 `pqos` 可在运行时调整），需在烧录前配置好 rkbin。

---

## 🧪 完整优化流程（端到端）

以下为典型工作负载从开机到运行的完整优化序列。其中线程优先级/亲和性由程序内代码完成（第 7 层），此处脚本只覆盖程序外的固件/内核/服务/中断层。

```bash
# ===== 第 4 层：服务清理 =====
sudo systemctl stop ofono wpa_supplicant bluetooth docker

# ===== 第 3/4 层：运行时电源与配额 =====
echo -1 | sudo tee /proc/sys/kernel/sched_rt_runtime_us
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee $cpu
done
# [x86] 关闭机器检查扫描
echo 0 | sudo tee /sys/devices/system/machinecheck/machinecheck0/check_interval

# ===== 第 5 层：中断亲和到 CPU 0 =====
for i in $(cat /proc/interrupts | grep '^ *[0-9]*[0-9]:' | awk '{print $1}' | sed 's/:$//'); do
    [ "$i" = "0" ] && continue
    [ "$i" = "2" ] && continue
    echo 1 > /proc/irq/$i/smp_affinity
done
for i in $(pgrep rcu); do taskset -pc 0 $i > /dev/null; done

# ===== 第 8 层：[x86] 缓存分区（Atom 示例）=====
sudo pqos -R
sudo pqos -e 'l2:0=0x0f;l2:1=0xf0'
sudo pqos -a 'llc:0=0,2;llc:1=1,3'

# ===== 第 7 层：启动实时工作负载（线程优先级/亲和性由程序内代码设置）=====
./<workload>
```

---

## ✅ 验证清单（RT-Scheduling Sanity Checks）

按以下顺序逐项验证优化是否生效：

1. **BIOS / 固件设置** — [x86] 进入 BIOS 确认 HT/C-State/SpeedStep/Turbo 均为 Disabled（见 [AcrnBios.md](./AcrnBios.md)）
2. **内核命令行参数** — `cat /proc/cmdline` 确认 `isolcpus`、`nohz_full`、`rcu_nocbs` 已生效；[x86] 额外确认 `intel_pstate=disable` 等
3. **CPU 隔离** — `cat /sys/devices/system/cpu/isolated` 应输出隔离核编号
4. **CPU 频率** — `cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq` 应固定为最大频率
5. **中断分布** — `cat /proc/interrupts` 确认隔离核上无中断计数增长
6. **线程亲和** — `taskset -pc <pid>` / `ps -o pid,tid,psr,comm -L` 确认实时线程只在隔离核运行
7. **调度策略** — `ps f -g 0 -o pid,policy,rtprio,cmd` 确认实时线程为 `FF` 且优先级正确
8. **内存锁定** — `grep VmLck /proc/<pid>/status` 确认已锁定的页数非零
9. **[x86] 缓存分区** — `pqos -s` 查看 LLC 占用是否符合预期
10. **延迟测量** — 用 `cyclictest` 采集延迟直方图，确认最大延迟满足需求

### cyclictest 延迟测量

```bash
sudo cyclictest -m -c 0 -n -p 80 -t 1 -a 3 -i 1000 -d 0 -l 10000000 -h 400 > latency.txt
```

| 参数 | 含义 |
| :--- | :--- |
| `-m` | 锁定内存（`mlockall`），防止测试过程中缺页换页引入额外延迟 |
| `-c 0` | 使用默认时钟，即 `CLOCK_MONOTONIC`（单调时钟，不受系统时间跳变影响） |
| `-n` | 使用 `clock_nanosleep` 而非简单 `sleep`/`usleep`，获得更高精度定时 |
| `-p 80` | 设置测试线程调度策略为 `SCHED_FIFO`、优先级 80 |
| `-t 1` | 启动 1 个测试线程 |
| `-a 3` | 将测试线程绑定到 CPU 3（隔离核；ARM 改为对应 A76 核，如 4） |
| `-i 1000` | 基准睡眠间隔 1000us（即 1ms） |
| `-d 0` | 每次循环间隔增量 0，即间隔保持固定为 1000us，便于稳定测量 |
| `-l 10000000` | 执行 1000 万次循环后结束（与 `-D` 二选一） |
| `-D 12h` | 改为按持续时间运行（12 小时），适合长时间稳定性观测，README 实测命令即用此参数 |
| `-h 400` | 输出 400 桶的延迟直方图，用于统计延迟分布 |

> 解读：关注输出的 `Max` 与直方图尾部。直方图集中在低延迟桶且无长尾，说明配置生效；若出现数十微秒以上的尖刺，回头排查 SMI、中断、C-State、调度抢占。

---

## 🔗 相关文档

- [AcrnBios.md](./AcrnBios.md) — [x86] BIOS 固件层详细配置表（本文档不重复）
- [eci_grub.cfg](./eci_grub.cfg) — [x86] 实际使用的内核启动参数
- [EciImg.md](./EciImg.md) — ECI 镜像构建
- [ECI Real-Time Scheduling](https://eci.intel.com/docs/3.3/development/performance/rt_scheduling.html)
- [ECI Linux OS Runtime Optimizations](https://eci.intel.com/docs/3.3/development/performance/optimizations.html)
- 工程代码：`osal/linux/osal_thread.c`（线程优先级 / 亲和性程序内实现）
