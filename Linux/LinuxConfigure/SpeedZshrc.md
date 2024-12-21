# 加速zsh启动

## Profiling zsh shell scripts

> zshrc 启动速度分析和优化https://best33.com/283.moe
> https://xebia.com/blog/profiling-zsh-shell-scripts/
> https://github.com/raboof/zshprof.git

> 安装 OCaml 和 opam：

    sudo apt install -y ocaml opam

> 使用 opam 安装 OCaml（推荐）
> 初始化 opam：

    opam init
    eval $(opam env)

> 安装指定版本的 OCaml（以最新稳定版本为例）：

    opam switch create 5.1.0
    eval $(opam env)

> 检查安装是否成功：

    ocaml --version
    opam --version

> 安装 ocamlfind

    opam install ocamlfind

> 获取zshprof源码并编译

    Add to the script to be profiled:

> Start:

    PS4=$'\\\011%D{%s%6.}\011%x\011%I\011%N\011%e\011'
    exec 3>&2 2>/tmp/zshstart.$$.log
    setopt xtrace prompt_subst

> End:

    unsetopt xtrace
    exec 2>&3 3>&-

> Compile and run the processor:

    make
    ./log2callgrind < /tmp/zshstart.6560.log > zsh.callgrind

> View the result:

    kcachegrind zsh.callgrind

> Limitations:
> This approach is utterly broken when there is any parallellism. You'll have to fall back to zprof when that is the case.
> It seems kcachegrind doesn't like it when you use the same filename for different traces.. careful.

**以下为WSL2安装桌面环境，供Windows调用**
> 安装 kcachegrind

    sudo apt-get install kcachegrind

> 安装XFCE桌面环境

    sudo apt-get install xfce4 -y

> 将必要软件安装到XFCE桌面

    sudo apt-get install xfce4-goodies -y
    sudo apt install x11-apps

> 设置部分环境变量

    export $(dbus-launch)
    export DISPLAY=:0


> Windows安装XLaunch
> https://sourceforge.net/projects/vcxsrv/