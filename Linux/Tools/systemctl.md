# systemctl

## 一、systemctl 是什么

`systemctl` 是 **Systemd** 系统和服务管理器的主要命令行工具。它用于检查和控制 systemd 系统和服务管理器。在现代 Linux 发行版（如 Ubuntu 16.04+, CentOS 7+, Debian 8+）中，它是管理系统服务的标准方式。

常见用途：

* 启动、停止、重启服务
* 设置服务开机自启
* 查看服务运行状态
* 管理系统状态（关机、重启）

---

## 二、基本语法

```bash
systemctl [COMMAND] [UNIT]
```

---

## 三、常用服务管理命令

假设服务名称为 `nginx`：

### 1. 查看状态

```bash
systemctl status nginx
```

* 显示服务是否正在运行、最近的日志输出以及进程 ID。

### 2. 启动与停止

```bash
systemctl start nginx    # 启动服务
systemctl stop nginx     # 停止服务
```

### 3. 重启与重载

```bash
systemctl restart nginx  # 重启服务（先停止再启动）
systemctl reload nginx   # 重载配置（不中断服务，仅重新加载配置文件）
```

---

## 四、开机自启管理

### 1. 设置开机自启

```bash
systemctl enable nginx
```

* 创建符号链接，使服务在系统启动时自动运行。

### 2. 取消开机自启

```bash
systemctl disable nginx
```

### 3. 检查是否开机自启

```bash
systemctl is-enabled nginx
```

---

## 五、编辑服务配置

### 1. 安全修改配置（推荐）

```bash
systemctl edit nginx
```

* 此命令会自动创建一个覆盖文件（`override.conf`），用于覆盖默认配置。
* **优势**：避免直接修改 `/lib/systemd/system/` 下的原文件，防止系统更新时配置被覆盖。

### 2. 查看最终配置

```bash
systemctl cat nginx
```

* 查看服务文件的原始内容及所有叠加的配置。

---

## 六、实用使用场景

### 1. 服务启动失败排查

当 `systemctl start xxx` 失败时，通常会提示使用 `status` 或 `journalctl` 查看详情：

```bash
systemctl status xxx.service
```

查看输出中的 `Active` 状态和底部的日志片段。

### 2. 查看所有已启动的服务

```bash
systemctl list-units --type=service --state=running
```

### 3. 屏蔽服务（禁止手动或自动启动）

```bash
systemctl mask nginx    # 屏蔽
systemctl unmask nginx  # 解除屏蔽
```

---

## 七、小结

日常最实用组合：

* `systemctl status <service>`：检查服务为何挂掉
* `systemctl restart <service>`：修改配置后重启
* `systemctl enable --now <service>`：设置开机自启并立即启动

它是 Linux 运维中最基础也是最高频使用的命令之一。
