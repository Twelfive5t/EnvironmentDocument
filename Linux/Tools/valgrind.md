# valgrind 快速使用速查

## 一、valgrind 是什么

`valgrind` 是 Linux 下非常重要的 **程序动态分析工具**，主要用于发现 **内存问题和线程问题**。它通过在虚拟 CPU 上运行程序，精确地监控每一次内存访问。

一句话理解：

> 用来找那些“不会立刻崩，但迟早要命”的 Bug。

常见用途：

* 内存泄漏检测
* 越界访问、野指针定位
* 未初始化内存使用排查
* 多线程数据竞争分析

---

## 二、基本用法

```bash
valgrind 程序名 [参数]
```

示例：

```bash
valgrind ./app
```

说明：

* 程序会明显变慢（这是正常的）
* 所有内存问题都会被拦下来检查

---

## 三、最常用工具：Memcheck

`memcheck` 是 valgrind 默认、也是使用频率最高的工具。

### 推荐启动方式

```bash
valgrind --tool=memcheck --leak-check=full ./app
```

常用参数说明：

* `--leak-check=full`：详细报告内存泄漏
* `--show-leak-kinds=all`：显示所有泄漏类型
* `--track-origins=yes`：追踪未初始化内存来源（更慢）

---

## 四、典型输出解读

示例片段：

```text
Invalid read of size 4
  at 0x4005ED: foo (test.c:10)
```

含义：

* `Invalid read`：非法内存访问
* `size 4`：访问 4 字节
* 后面是函数调用栈和源码位置

这通常意味着 **越界访问或野指针**。

---

## 五、常见内存问题类型

* **Definitely lost**：确定泄漏（必须修）
* **Indirectly lost**：间接泄漏
* **Possibly lost**：可能泄漏（需确认）
* **Still reachable**：程序结束时仍可达（一般可忽略）

排查重点永远是前两类。

---

## 六、常用实战组合

### 1. 检查内存泄漏（最常用）

```bash
valgrind --leak-check=full --show-leak-kinds=all ./app
```

---

### 2. 定位未初始化变量

```bash
valgrind --track-origins=yes ./app
```

---

### 3. 输出到日志文件

```bash
valgrind --log-file=valgrind.log ./app
```

适合 CI 或远程调试。

---

## 七、多线程与性能相关工具

* `helgrind`：检测数据竞争
* `drd`：另一种线程错误检测工具
* `callgrind`：函数调用与性能分析

示例：

```bash
valgrind --tool=helgrind ./app
```

---

## 八、使用建议（经验向）

* 编译时开启调试信息：`-g`
* 关闭优化更易定位问题：`-O0`
* 优先修复第一个报错，后续往往是连锁反应

---

## 九、小结

`valgrind` 的核心价值在于：

> **把不确定的内存行为，变成确定的错误报告**。

它跑得慢，但说的每一句话都值得认真听。在 C / C++ 世界里，这是极少数“愿意替你承担怀疑”的工具。
