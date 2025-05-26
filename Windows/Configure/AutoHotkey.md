# AutoHotkey 键盘映射配置指南

AutoHotkey 是一个强大的 Windows 自动化工具，可以用来重新映射键盘按键、创建快捷键等。

## 目录

- [AutoHotkey 键盘映射配置指南](#autohotkey-键盘映射配置指南)
  - [目录](#目录)
  - [安装 AutoHotkey](#安装-autohotkey)
    - [下载安装](#下载安装)
  - [创建键盘映射脚本](#创建键盘映射脚本)
    - [基础映射脚本](#基础映射脚本)
    - [脚本说明](#脚本说明)
  - [编译和运行](#编译和运行)
    - [方法一：直接运行脚本（推荐）](#方法一直接运行脚本推荐)
    - [方法二：编译为可执行文件](#方法二编译为可执行文件)
  - [开机自启动设置](#开机自启动设置)
    - [方法一：添加到启动文件夹（推荐）](#方法一添加到启动文件夹推荐)
    - [方法二：任务计划程序](#方法二任务计划程序)
  - [常用键盘映射示例](#常用键盘映射示例)
  - [故障排除](#故障排除)
    - [常见问题](#常见问题)
    - [调试技巧](#调试技巧)
  - [参考资源](#参考资源)

## 安装 AutoHotkey

### 下载安装

1. 访问官网下载 AutoHotkey v2：

   ```url
   https://www.autohotkey.com/download/ahk-v2.exe
   ```

2. 运行安装程序，按默认设置安装即可

## 创建键盘映射脚本

### 基础映射脚本

创建 `capslock.ahk` 文件，内容如下：

```autohotkey
; 将 CapsLock 键映射为 Esc 键
CapsLock::Esc

; 可选：添加其他有用的映射
; Win + H 映射为 Left Arrow
#h::Left

; Win + J 映射为 Down Arrow  
#j::Down

; Win + K 映射为 Up Arrow
#k::Up

; Win + L 映射为 Right Arrow
#l::Right
```

### 脚本说明

- `CapsLock::Esc`：将 CapsLock 键重新映射为 Esc 键
- `;` 开头的行是注释
- `#` 表示 Windows 键
- 更多语法请参考 [AutoHotkey 官方文档](https://www.autohotkey.com/docs/)

## 编译和运行

### 方法一：直接运行脚本（推荐）

1. 双击 `.ahk` 文件直接运行
2. 系统托盘会出现 AutoHotkey 图标

### 方法二：编译为可执行文件

1. 打开编译器：

   ```path
   C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
   ```

2. 在编译器中：
   - **Source (script file)**：选择你的 `.ahk` 文件
   - **Destination (.exe file)**：选择输出的 `.exe` 文件位置
   - 点击 **Convert** 开始编译

3. 编译完成后，运行生成的 `.exe` 文件

## 开机自启动设置

### 方法一：添加到启动文件夹（推荐）

1. **打开启动文件夹**：
   - 按 `Win + R`，输入 `shell:startup`，按回车
   - 这将打开当前用户的启动文件夹

2. **添加程序快捷方式**：
   - 将编译好的 `.exe` 文件或 `.ahk` 文件的快捷方式复制到该文件夹
   - 下次开机时会自动运行

3. **全局启动**（可选）：
   - 如需所有用户都自动启动，使用 `shell:common startup` 命令
   - 需要管理员权限

### 方法二：任务计划程序

1. 按 `Win + R`，输入 `taskschd.msc`
2. 创建基本任务，设置为系统启动时运行
3. 指定程序路径为你的 `.exe` 或 `.ahk` 文件

## 常用键盘映射示例

```autohotkey
; === 基础映射 ===
; CapsLock 改为 Esc（程序员友好）
CapsLock::Esc

; === Vim 风格导航 ===
; Win + HJKL 作为方向键
#h::Left
#j::Down
#k::Up
#l::Right

; === 功能增强 ===
; Alt + Space 打开开始菜单
!Space::LWin

; Ctrl + Alt + T 打开终端
^!t::Run "wt.exe"

; === 窗口管理 ===
; Win + Q 关闭当前窗口
#q::WinClose "A"

; Win + F 全屏切换
#f::WinSetAlwaysOnTop -1, "A"
```

## 故障排除

### 常见问题

1. **脚本不生效**：
   - 确认 AutoHotkey 正在运行（检查系统托盘）
   - 检查脚本语法是否正确
   - 尝试以管理员身份运行

2. **与其他程序冲突**：
   - 某些游戏或安全软件可能阻止 AutoHotkey
   - 将 AutoHotkey 添加到白名单

3. **开机启动失败**：
   - 检查启动文件夹中的快捷方式是否有效
   - 确认目标文件路径没有变化

### 调试技巧

- 使用 `MsgBox "测试消息"` 来调试脚本
- 查看 AutoHotkey 窗口菜单中的 "View" > "Lines most recently executed"
- 重新加载脚本：右键托盘图标 > "Reload This Script"

## 参考资源

- [AutoHotkey 官方文档](https://www.autohotkey.com/docs/)
- [AutoHotkey 社区](https://www.autohotkey.com/community/)
- [按键代码参考](https://www.autohotkey.com/docs/KeyList.htm)
