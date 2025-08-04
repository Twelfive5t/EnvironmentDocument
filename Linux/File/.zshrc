#===============================================================================
# 调试配置 (如需调试可取消注释)
#===============================================================================
#PS4=$'\\\011%D{%s%6.}\011%x\011%I\011%N\011%e\011'
#exec 3>&2 2>/tmp/zshstart.$$.log
#setopt xtrace prompt_subst

#===============================================================================
# 路径配置
#===============================================================================
# 排除 /mnt 路径及其子路径
fpath=(${fpath:#/mnt*})

#===============================================================================
# Powerlevel10k 即时提示 (必须在文件顶部)
#===============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#===============================================================================
# Oh-My-Zsh 配置
#===============================================================================
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# 主题配置
ZSH_THEME="powerlevel10k/powerlevel10k"

# 插件配置
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  web-search
  z
  extract
  you-should-use
  zsh-ssh
  tldr
  copyfile
  copypath
)

# 加载 Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

#===============================================================================
# 历史记录配置
#===============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

#===============================================================================
# 键盘绑定配置
#===============================================================================
# 单词跳转快捷键
bindkey "^[w" forward-word       # Alt+w → forward-word（跳到下一个单词开头）
bindkey "^[b" backward-word      # Alt+b → backward-word（跳到上一个单词开头）

# 自定义单词结尾跳转
function forward-word-end() {
  zle forward-word       # 向前移动到下一个单词开头
  zle backward-char      # 然后回退一个字符，到达上一个单词的结尾
}
zle -N forward-word-end
bindkey "^[e" forward-word-end   # Alt+e → emulate Vim 的 e：跳到单词结尾

# 方向键绑定 (模拟 Vim 风格)
bindkey "^[h" backward-char                    # Alt+h → ←
bindkey "^[l" forward-char                     # Alt+l → →
bindkey "^[k" history-substring-search-up      # Alt+k → ↑ (支持子字符串搜索)
bindkey "^[j" history-substring-search-down    # Alt+j → ↓ (支持子字符串搜索)

#===============================================================================
# 代理配置函数
#===============================================================================
# 设置代理
proxy()
{
  export ALL_PROXY="http://10.1.61.147:7897"
  export HTTP_PROXY="http://10.1.61.147:7897"
  export HTTPS_PROXY="http://10.1.61.147:7897"
  export NO_PROXY="localhost,127.0.0.1,.example.com"
  export all_proxy="http://10.1.61.147:7897"
  export http_proxy="http://10.1.61.147:7897"
  export https_proxy="http://10.1.61.147:7897"
  export no_proxy="localhost,127.0.0.1,.example.com"
}

# 取消代理
unproxy() {
  unset ALL_PROXY HTTP_PROXY HTTPS_PROXY NO_PROXY
  unset all_proxy http_proxy https_proxy no_proxy
  echo "代理已取消"
}

#===============================================================================
# 环境变量配置
#===============================================================================
export TLDR_LANGUAGE="zh"

# 编辑器配置 (可根据需要取消注释)
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# 语言环境 (可根据需要取消注释)
# export LANG=en_US.UTF-8

#===============================================================================
# 性能优化配置
#===============================================================================
# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

#===============================================================================
# 主题和工具初始化
#===============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# FZF 模糊查找工具
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# OCaml opam 配置
[[ ! -r /root/.opam/opam-init/init.zsh ]] || source /root/.opam/opam-init/init.zsh > /dev/null 2> /dev/null

#===============================================================================
# 调试结束 (与文件开头的调试配置对应)
#===============================================================================
#unsetopt xtrace
#exec 2>&3 3>&-
