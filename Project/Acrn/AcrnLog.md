# AcrnLog 配置与使用指南

参考文档: [ACRN Debug Tutorial](https://projectacrn.github.io/latest/tutorials/debug.html#acrn-log)

## 1. 编译 AcrnLog

AcrnLog 需要手动编译。

1. 进入 `acrn-hypervisor` 目录。
2. 执行编译命令：

    ```bash
    make acrnlog
    ```

3. 编译完成后，将生成的 `acrnlog` 可执行文件和 `acrnlog.service` 文件复制到 Service VM 中。

## 2. 配置 Service VM 启动参数

参考文档: [ACRN Kernel Parameters](https://projectacrn.github.io/latest/user-guides/kernel-parameters.html)

需要在 Service VM 的启动命令行中添加 `hvlog` 参数，用于指定日志缓冲区的大小和物理内存地址。

格式: `hvlog=<size>@<paddr>`

### 内存地址选择示例

地址不能随意指定，需要根据系统的内存布局来选择。可以通过查看 `/proc/iomem` 获取可用内存范围。

```bash
cat /proc/iomem
```

假设输出包含如下片段：

```text
00100000-003fffff : System RAM
```

这段内存范围是：

- 起始：`0x00100000` (1MB)
- 结束：`0x003fffff` (接近 4MB)
- 总大小：3MB

如果需要分配 2MB 的日志空间，可以选择在此范围内的一个起始地址，例如 `0x200000`。

配置示例：

```text
hvlog=2M@0x200000
```

## 3. 修改构建与运行配置

为了启用完整的调试日志，需要进行以下配置修改：

1. **ACRN Configurator**:
    - 将 Hypervisor 构建类型修改为 `Debug`。
    - 将 Log Level 从默认的 `333` 修改为 `554` (或根据需求调整)。

2. **构建规则 (`acrn-hypervisor/debian/rules`)**:
    - 确保设置为非 Release 版本：

      ```makefile
      export RELEASE ?= n
      ```

3. **Service VM 启动参数**:
    - 将 `loglevel` 参数从 `3` 修改为 `7` 以获取更多内核日志。

## 4. 启动 AcrnLog 服务

在 Service VM 中执行以下命令来启用并启动服务：

```bash
systemctl enable acrnlog
systemctl start acrnlog
```
