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
  web-search
  z
  extract
  you-should-use
  zsh-ssh
  tldr
  copyfile
  copypath
  zsh-history-substring-search
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
# 使用 Emacs 模式（默认）
bindkey -e

bindkey '^[h' backward-kill-word # ALT-H - delete last word
# ALT-C - cd into the selected directory
# CTRL-R - Paste the selected command from history into the command line
# CTRL-T - Paste the selected file path(s) into the command line

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
