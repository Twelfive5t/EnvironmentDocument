# journalctl

## 一、journalctl 是什么

`journalctl` 是用于查询 **Systemd Journal**（系统日志）的命令行工具。Systemd 统一收集了内核、系统启动过程、标准输出/错误以及各种服务的日志，`journalctl` 提供了强大的过滤和检索功能，替代了传统的查看 `/var/log/messages` 或 `/var/log/syslog` 的方式。

常见用途：

* 查看特定服务的日志
* 实时跟踪日志输出（类似 `tail -f`）
* 按时间范围筛选日志
* 查看系统启动日志

---

## 二、基本用法

### 1. 查看所有日志

```bash
journalctl
```

* 默认会分页显示所有日志，按时间顺序排列。

### 2. 查看最新日志（尾部）

```bash
journalctl -n 20
```

* 显示最后 20 行日志。

### 3. 实时跟踪日志

```bash
journalctl -f
```

* 持续输出最新的日志条目，用于监控实时发生的事件。

---

## 三、常用筛选方式（核心）

### 1. 按服务筛选（最常用）

查看特定服务（如 `ssh` 或 `docker`）的日志：

```bash
journalctl -u ssh
journalctl -u docker.service
```

### 2. 按时间筛选

```bash
journalctl --since "2023-10-01 12:00:00"
journalctl --since "1 hour ago"    # 查看最近1小时
journalctl --since "today"         # 查看今天的日志
journalctl --since "yesterday" --until "today"
```

### 3. 按优先级筛选

日志级别：`emerg` (0), `alert` (1), `crit` (2), `err` (3), `warning` (4), `notice` (5), `info` (6), `debug` (7)。

```bash
journalctl -p err    # 查看错误及以上级别的日志
```

---

## 四、高级用法

### 1. 查看本次启动后的日志

```bash
journalctl -b
```

* 过滤掉之前系统运行周期的日志，只看当前的。

### 2. 查看内核日志

```bash
journalctl -k
```

* 类似 `dmesg`。

### 3. 简洁模式输出

```bash
journalctl -o short-precise
```

* 显示微秒级时间戳。

### 4. 清理日志（维护）

如果日志占用空间过大：

```bash
journalctl --vacuum-time=1weeks   # 保留最近一周
journalctl --vacuum-size=500M     # 限制最大 500MB
```

---

## 五、实用使用场景

### 1. 配合 systemctl 排查服务报错

当服务启动失败时，直接查看该服务的日志：

```bash
journalctl -u nginx -e
```

* `-e` 参数会跳转到日志的末尾（End），方便直接看最新的报错。

### 2. 监控两个服务的交互

同时跟踪两个服务的日志：

```bash
journalctl -u nginx -u php-fpm -f
```

### 3. 导出日志到文件

```bash
journalctl -u ssh > ssh_logs.txt
```

---

## 六、小结

日常最实用组合：

* `journalctl -u <service> -f`：实时调试服务
* `journalctl -xe`：查看刚刚发生的系统错误详情
* `journalctl -b -p err`：检查本次启动后的所有错误

`journalctl` 是现代 Linux 系统排错的神器，熟练掌握过滤参数能极大提高定位问题的效率。
