# Wsl2配置

https://blog.csdn.net/weixin_44301630/article/details/122390018

## 在Windows上安装Linux子系统

### 前提条件

windows机器需要支持虚拟化，并且需要在BIOS中开启虚拟化技术，因为WSL2基于hyper-V。

> 查看是否开启虚拟化
> 按住Windows+R输入cmd打开命令行，输入

    systeminfo
> 可以看到如下字样，代表电脑已经支持虚拟化，可继续安装
>
> Hyper-V 要求:     虚拟机监视器模式扩展: 是
>                 固件中已启用虚拟化: 是
>                 二级地址转换: 是
>                 数据执行保护可用: 是

无论是Windows10还是Windows11，所使用的Windows是最新版的，如果不是最新版，请在设置-Windows更新中将系统更新到最新版本。

### 安装步骤

1. 开启开发者模式

        在设置中搜索“开发者设置”并打开；
        打开开发人员模式并点击是，这时候就成功打开开发者模式啦；

2. 开启“适用于Linux的Windows子系统”

        找到控制面板-程序和功能-启用或关闭Windows功能
        选中“适用于Linux的Windows子系统”，然后点击确定

3. 安装Linux分发版

        wsl --install
        wsl --set-default-version 2
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

    **重新启动电脑**

### Wsl2更新

    wsl --update
    wsl --list --online
    wsl --install -d ubuntu-24.04

> 问题：wsl --list --online 报错：安全频道支持出错，Wsl/0x80072f7d（同时微软商店也会报这个错）
> 修复：win+r 输入inetcpl.cpl -> 高级 -> 开启TLS1.2

### wsl2移至其他盘
1. 准备工作
    打开CMD，输入wsl -l -v查看wsl虚拟机的名称与状态。
    了解到本机的WSL全称为Ubuntu-24.04，以下的操作都将围绕这个来进行。

    输入 wsl --shutdown 使其停止运行，再次使用wsl -l -v确保其处于stopped状态。

2. 导出/恢复备份
    在D盘创建一个目录用来存放新的WSL，比如我创建了一个 D:\WSL2 。
    ①导出它的备份(比如命名为Ubuntu.tar)

        wsl --export Ubuntu-24.04 D:\WSL2\Ubuntu-24.04.tar

    ②确定在此目录下可以看见备份Ubuntu.tar文件之后，注销原有的wsl

        wsl --unregister Ubuntu-24.04

    ③将备份文件恢复到D:\Ubuntu_WSL中去

        wsl --import Ubuntu-24.04 D:\WSL2 D:\WSL2\Ubuntu-24.04.tar

    这时候启动WSL，发现好像已经恢复正常了，但是用户变成了root，之前使用过的文件也看不见了。

3. 恢复默认用户
    在CMD中，输入 Linux发行版名称 config --default-user 原本用户名
    例如：

        Ubuntu2404 config --default-user cham

### wsl2配置bridged模式

如果需要使用 bridged 模式，请按照以下步骤创建并配置虚拟交换机：

1. 打开 Hyper-V 管理器：

    在 Windows 中按 Win + R，输入 virtmgmt.msc。
    打开 Hyper-V 管理器。

2. 创建虚拟交换机：

    在 Hyper-V 管理器右侧，点击 "虚拟交换机管理器"。
    选择 "新建虚拟网络交换机"。
    类型选择 "外部"。
    选择与物理网络连接的网卡，命名为 WSLBridge 或其他名称。
    点击 "确定" 保存。