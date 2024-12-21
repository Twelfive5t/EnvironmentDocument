# WSL2 配置

## 在 Windows 上安装 Linux 子系统

### 前提条件

1. Windows 机器需要支持虚拟化，并且需要在 BIOS 中开启虚拟化技术，因为 WSL2 基于 Hyper-V。

2. 查看是否开启虚拟化：

    - 按住 Windows + R 键，输入 `cmd` 打开命令行，输入以下命令：

        ```bash
        systeminfo
        ```

    - 检查输出中是否有以下字样，表示电脑已支持虚拟化，可以继续安装：

        ```
        Hyper-V 要求:
        虚拟机监视器模式扩展: 是
        固件中已启用虚拟化: 是
        二级地址转换: 是
        数据执行保护可用: 是
        ```

3. 确保使用的是 Windows 最新版本。若不是最新版，请通过“设置” -> “Windows 更新”更新系统。

### 安装步骤

1. **开启开发者模式**

    - 在设置中搜索“开发者设置”并打开；
    - 开启“开发者模式”并点击“是”。

2. **启用适用于 Linux 的 Windows 子系统**

    - 打开“控制面板” -> “程序和功能” -> “启用或关闭 Windows 功能”；
    - 选中“适用于 Linux 的 Windows 子系统”，点击确定。

3. **安装 Linux 发行版**

    执行以下命令：

    ```bash
    wsl --install
    wsl --set-default-version 2
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart
    ```

    **执行完上述步骤后需重新启动电脑。**

### WSL2 更新

1. 更新 WSL2：

    ```bash
    wsl --update
    ```

2. 查看可用的发行版并安装 Ubuntu 24.04：

    ```bash
    wsl --list --online
    wsl --install -d ubuntu-24.04
    ```

> **问题**：`wsl --list --online` 报错：安全频道支持出错，Wsl/0x80072f7d（微软商店也会报此错）

> **修复**：按 `Win + R` 输入 `inetcpl.cpl` -> “高级” -> 开启 TLS 1.2。

### WSL2 移至其他盘

1. **准备工作**

    - 打开 CMD，输入 `wsl -l -v` 查看 WSL 虚拟机的名称与状态。
    - 假设 WSL 的名称为 `Ubuntu-24.04`，以下操作将基于此。

    输入以下命令关闭 WSL：

    ```bash
    wsl --shutdown
    ```

    确保状态为 `stopped`。

2. **导出/恢复备份**

    - 在 D 盘创建一个目录（如：`D:\WSL2`）存放新的 WSL。
    - 导出备份（例如命名为 `Ubuntu.tar`）：

        ```bash
        wsl --export Ubuntu-24.04 D:\WSL2\Ubuntu-24.04.tar
        ```

    - 确保 `D:\WSL2\Ubuntu-24.04.tar` 存在后，注销原有的 WSL：

        ```bash
        wsl --unregister Ubuntu-24.04
        ```

    - 将备份恢复到新的目录：

        ```bash
        wsl --import Ubuntu-24.04 D:\WSL2 D:\WSL2\Ubuntu-24.04.tar
        ```

    启动 WSL 时，可能会出现用户变为 root，且之前的文件不可见。

3. **恢复默认用户**

    执行以下命令恢复默认用户：

    ```bash
    Ubuntu2404 config --default-user liuyijie
    ```

### WSL2 配置 Bridged 模式

1. **创建虚拟交换机**

    - 按 `Win + R` 输入 `virtmgmt.msc` 打开 Hyper-V 管理器。
    - 在 Hyper-V 管理器右侧，点击“虚拟交换机管理器”。
    - 选择“新建虚拟网络交换机”。
    - 选择“外部”，并选择与物理网络连接的网卡，命名为 `WSLBridge`（或其他名称）。
    - 点击“确定”保存。

