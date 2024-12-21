# 加速 zsh 启动

## Profiling zsh shell scripts

### 参考资料

- [zshrc 启动速度分析和优化](https://best33.com/283.moe)
- [Profiling Zsh Shell Scripts](https://xebia.com/blog/profiling-zsh-shell-scripts/)
- [zshprof GitHub](https://github.com/raboof/zshprof.git)

### 安装 OCaml 和 opam

1. 安装 OCaml 和 opam：

    ```bash
    sudo apt install -y ocaml opam
    ```

2. 使用 opam 安装 OCaml（推荐）：

    ```bash
    opam init
    eval $(opam env)
    ```

3. 安装指定版本的 OCaml（以最新稳定版本为例）：

    ```bash
    opam switch create 5.1.0
    eval $(opam env)
    ```

4. 检查安装是否成功：

    ```bash
    ocaml --version
    opam --version
    ```

5. 安装 ocamlfind：

    ```bash
    opam install ocamlfind
    ```

### 获取 zshprof 源码并编译

1. 在脚本中添加如下内容进行分析：

    **开始分析（Start）**：

    ```bash
    PS4=$'\\\011%D{%s%6.}\011%x\011%I\011%N\011%e\011'
    exec 3>&2 2>/tmp/zshstart.$$.log
    setopt xtrace prompt_subst
    ```

    **结束分析（End）**：

    ```bash
    unsetopt xtrace
    exec 2>&3 3>&-
    ```

2. 编译并运行分析工具：

    ```bash
    make
    ./log2callgrind < /tmp/zshstart.6560.log > zsh.callgrind
    ```

3. 查看结果：

    ```bash
    kcachegrind zsh.callgrind
    ```

### 注意事项

- 该方法在并行执行时可能会失败，建议在有并行处理时使用 `zprof`。
- 如果使用相同文件名保存不同的日志，`kcachegrind` 可能无法正确处理。

## 在 WSL2 中安装桌面环境（供 Windows 调用）

### 安装 kcachegrind 和 XFCE 桌面环境

1. 安装 `kcachegrind`：

    ```bash
    sudo apt-get install kcachegrind
    ```

2. 安装 XFCE 桌面环境：

    ```bash
    sudo apt-get install xfce4 -y
    ```

3. 安装额外软件：

    ```bash
    sudo apt-get install xfce4-goodies -y
    sudo apt install x11-apps
    ```

### 设置环境变量

1. 设置 D-Bus 和 X11 环境变量：

    ```bash
    export $(dbus-launch)
    export DISPLAY=:0
    ```

### 安装 XLaunch

1. 在 Windows 上安装 XLaunch：
   - [XLaunch下载链接](https://sourceforge.net/projects/vcxsrv/)
