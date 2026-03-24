# tmux

## 一、tmux 是什么

`tmux` 是一个**终端复用器（Terminal Multiplexer）**，允许在一个终端窗口中同时管理多个会话、窗口和面板。

一句话理解：

> 让你在一个终端里开多个"屏幕"，并且断开 SSH 后程序继续在后台运行。

常见使用场景：

* 远程 SSH 会话保持（断网重连后恢复工作现场）
* 同时监控多个终端窗口
* 分屏查看日志与编辑代码
* 长时间运行任务（编译、测试）时保护进程不被中断

---

## 二、安装

```bash
sudo apt install tmux      # Debian / Ubuntu
sudo yum install tmux      # CentOS / RHEL
```

验证安装：

```bash
tmux -V
```

---

## 三、核心概念

tmux 有三层结构：

| 层级 | 名称 | 说明 |
|------|------|------|
| 最外层 | Session（会话） | 一个独立的工作空间，可后台运行 |
| 中间层 | Window（窗口） | 类似浏览器标签页 |
| 最内层 | Pane（面板） | 一个窗口内的分屏区域 |

**前缀键**：所有 tmux 快捷键都需要先按前缀键（默认 `Ctrl+b`），再按功能键。

---

## 四、会话管理（Session）

### 创建会话

```bash
tmux                        # 创建匿名会话
tmux new -s mysession       # 创建并命名会话
```

### 离开与恢复

```bash
# 在 tmux 内按快捷键离开（会话继续在后台运行）
Ctrl+b  d

# 重新连接到会话
tmux attach -t mysession    # 按名称连接
tmux a                      # 连接最近的会话
```

### 查看与删除会话

```bash
tmux ls                     # 列出所有会话
tmux kill-session -t mysession   # 删除指定会话
tmux kill-server            # 删除所有会话
```

---

## 五、窗口管理（Window）

在 tmux 内使用快捷键（需先按 `Ctrl+b`）：

| 快捷键 | 功能 |
|--------|------|
| `c` | 创建新窗口 |
| `n` | 切换到下一个窗口 |
| `p` | 切换到上一个窗口 |
| `0-9` | 按编号切换窗口 |
| `,` | 重命名当前窗口 |
| `&` | 关闭当前窗口 |
| `w` | 以列表形式选择窗口 |

---

## 六、面板管理（Pane）

### 分屏操作

| 快捷键 | 功能 |
|--------|------|
| `%` | 左右分屏 |
| `"` | 上下分屏 |
| `x` | 关闭当前面板 |
| `z` | 当前面板全屏 / 还原 |

### 面板切换与调整

| 快捷键 | 功能 |
|--------|------|
| `方向键` | 切换到相邻面板 |
| `Ctrl+方向键` | 调整面板大小 |
| `{` / `}` | 与上 / 下一个面板交换位置 |
| `q` | 显示面板编号 |

---

## 七、复制模式（Copy Mode）

tmux 支持在终端内滚动查看历史输出：

```
Ctrl+b  [      # 进入复制模式
方向键 / PgUp  # 滚动浏览
q              # 退出复制模式
```

开启鼠标滚轮支持（推荐）：

```bash
# 在 ~/.tmux.conf 中添加
set -g mouse on
```

---

## 八、配置文件

tmux 配置文件位于 `~/.tmux.conf`，修改后执行以下命令生效：

```bash
tmux source-file ~/.tmux.conf
# 或在 tmux 内按 Ctrl+b : 输入
source-file ~/.tmux.conf
```

常用配置示例：

```bash
# 开启鼠标支持
set -g mouse on

# 修改前缀键为 Ctrl+a（更顺手）
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# 面板切换使用 vim 风格（h/j/k/l）
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# 设置历史记录上限
set -g history-limit 10000

# 窗口编号从 1 开始
set -g base-index 1
```

---

## 九、实用使用场景

### 1. SSH 断线后恢复工作

```bash
# 连接远程服务器后，创建 tmux 会话再开始工作
ssh user@server
tmux new -s work

# 网络断开后重新 SSH 进来
ssh user@server
tmux attach -t work    # 工作现场完整恢复
```

### 2. 同时监控日志和运行程序

```bash
tmux new -s monitor
# Ctrl+b % 左右分屏
# 左侧面板：tail -f /var/log/syslog
# 右侧面板：运行程序
```

### 3. 后台执行长时间编译任务

```bash
tmux new -s build
make -j$(nproc)
# Ctrl+b d  离开会话，编译继续运行
```

---

## 十、小结

tmux 最核心的价值：

> **会话持久化** + **多窗口分屏**，让终端工作效率大幅提升。

日常最常用操作：

* `tmux new -s <name>`：创建命名会话
* `Ctrl+b d`：离开会话（保持后台运行）
* `tmux attach -t <name>`：重新连接会话
* `Ctrl+b %` / `"`：左右 / 上下分屏
* `Ctrl+b 方向键`：切换面板
