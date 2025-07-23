"=============================================================================
" Vim 配置文件
"=============================================================================

"-----------------------------------------------------------------------------
" 基础设置
"-----------------------------------------------------------------------------
set nocompatible            " 不兼容vi模式
filetype on                 " 开启文件类型检测
filetype plugin on          " 载入文件类型插件
filetype plugin indent on   " 为特定文件类型载入相关缩进文件

"-----------------------------------------------------------------------------
" Vundle 插件管理
"-----------------------------------------------------------------------------
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'taglist.vim'
Plugin 'The-NERD-tree'
Plugin 'indentLine.vim'
Plugin 'delimitMate.vim'

call vundle#end()

"-----------------------------------------------------------------------------
" YouCompleteMe 配置 - 语句补全插件
"-----------------------------------------------------------------------------
set runtimepath+=~/.vim/bundle/YouCompleteMe
autocmd InsertLeave * if pumvisible() == 0|pclose|endif " 离开插入模式后自动关闭预览窗口
let g:ycm_collect_identifiers_from_tags_files = 1           " 开启 YCM基于标签引擎
let g:ycm_collect_identifiers_from_comments_and_strings = 1 " 注释与字符串中的内容也用于补全
let g:syntastic_ignore_files=[".*\.py$"]
let g:ycm_seed_identifiers_with_syntax = 1                  " 语法关键字补全
let g:ycm_complete_in_comments = 1                          " 在注释输入中也能补全
let g:ycm_complete_in_strings = 1                           " 在字符串输入中也能补全
let g:ycm_confirm_extra_conf = 0                            " 关闭加载.ycm_extra_conf.py提示
let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']  " 映射按键,没有这个会拦截掉tab
let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']
let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
let g:ycm_show_diagnostics_ui = 0                           " 禁用语法检查
let g:ycm_min_num_of_chars_for_completion=2                 " 从第2个键入字符就开始罗列匹配项
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"     " 回车即选中当前项
nnoremap <c-j> :YcmCompleter GoToDefinitionElseDeclaration<CR> " 跳转到定义处

"-----------------------------------------------------------------------------
" vim-airline 配置 - 优化vim界面
"-----------------------------------------------------------------------------
set t_Co=256
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ' '
let g:airline#extensions#tabline#buffer_nr_show = 1

"-----------------------------------------------------------------------------
" TagList 配置 - ctags支持，F3快捷键显示程序中的各种tags，包括变量和函数等
"-----------------------------------------------------------------------------
map <F3> :TlistToggle<CR>   " F3快捷键切换TagList
let Tlist_Use_Right_Window=1 " 在右侧窗口显示
let Tlist_Show_One_File=1   " 只显示当前文件的tags
let Tlist_Exit_OnlyWindow=1 " 如果TagList是最后一个窗口，则退出vim
let Tlist_WinWidt=25        " 设置TagList窗口宽度

"-----------------------------------------------------------------------------
" NERDTree 配置 - F2快捷键显示当前目录树
"-----------------------------------------------------------------------------
map <F2> :NERDTreeToggle<CR> " F2快捷键切换目录树
let NERDTreeWinSize=25      " 设置NERDTree窗口宽度

"-----------------------------------------------------------------------------
" 键盘映射
"-----------------------------------------------------------------------------
" 基础操作
nmap <leader>w :w!<cr>      " Leader+w 强制保存
nmap <leader>f :find<cr>    " Leader+f 查找文件

" 复制粘贴
map <C-A> ggVGY             " Ctrl+A 全选并复制
map! <C-A> <Esc>ggVGY       " 插入模式下 Ctrl+A 全选并复制
vmap <C-c> "+y              " 选中状态下 Ctrl+c 复制到系统剪贴板
map <F12> gg=G              " F12 自动格式化整个文件

" Buffer 切换
nnoremap [b :bp<CR>         " [b 切换到上一个buffer
nnoremap ]b :bn<CR>         " ]b 切换到下一个buffer
map <leader>1 :b 1<CR>      " Leader+数字 快速切换到指定buffer
map <leader>2 :b 2<CR>
map <leader>3 :b 3<CR>
map <leader>4 :b 4<CR>
map <leader>5 :b 5<CR>
map <leader>6 :b 6<CR>
map <leader>7 :b 7<CR>
map <leader>8 :b 8<CR>
map <leader>9 :b 9<CR>

" quickfix模式 - C/C++编译
autocmd FileType c,cpp map <buffer> <leader><space> :w<cr>:make<cr>

"-----------------------------------------------------------------------------
" 编辑器外观设置
"-----------------------------------------------------------------------------
set syntax=on               " 语法高亮
set cursorline              " 突出显示当前行
set ruler                   " 显示状态栏标尺（行号、列号）
set magic                   " 设置魔术，用于正则表达式
set guioptions-=T           " 隐藏工具栏（GUI模式）
set guioptions-=m           " 隐藏菜单栏（GUI模式）
set showmatch               " 高亮显示匹配的括号
set matchtime=1             " 匹配括号高亮时间（十分之一秒）
set cmdheight=2             " 命令行高度设为2行

" 光标形状设置
let &t_SI = "\e[6 q"        " 插入模式：线状光标
let &t_EI = "\e[2 q"        " 普通模式：块状光标
let &t_SR = "\e[4 q"        " 替换模式：下划线光标

" 状态栏设置 - 显示文件信息、行列信息、百分比等
set statusline=[%F]%y%r%m%*%=[Line:%l/%L,Column:%c][%p%%]

"-----------------------------------------------------------------------------
" 缩进和制表符设置
"-----------------------------------------------------------------------------
set autoindent              " 自动缩进（新行保持当前行缩进）
set cindent                 " C程序自动缩进
set smartindent             " 智能缩进（根据语法智能判断）
set tabstop=4               " Tab键显示宽度为4个空格
set softtabstop=4           " 软制表符宽度为4
set shiftwidth=4            " 自动缩进时使用4个空格
set noexpandtab             " 不用空格代替制表符（保持Tab字符）
set smarttab                " 智能制表符（行首使用shiftwidth，其他地方使用tabstop）

"-----------------------------------------------------------------------------
" 搜索设置
"-----------------------------------------------------------------------------
set hlsearch                " 搜索结果高亮显示
set incsearch               " 搜索时逐字符高亮匹配
set ignorecase              " 搜索时忽略大小写
set gdefault                " 替换时默认全局替换（无需每次加g）

"-----------------------------------------------------------------------------
" 文件和编码设置
"-----------------------------------------------------------------------------
set autoread                " 文件在外部被修改时自动重新载入
set autowrite               " 切换buffer时自动保存当前文件
set nobackup                " 不创建备份文件
set noswapfile              " 不生成交换文件
set clipboard=unnamed       " 使用系统剪贴板
set enc=utf-8               " 内部编码使用UTF-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936 " 文件编码检测顺序
set langmenu=zh_CN.UTF-8    " 菜单语言设置为中文
set helplang=cn             " 帮助文档语言设置为中文

"-----------------------------------------------------------------------------
" 折叠设置
"-----------------------------------------------------------------------------
set foldcolumn=0            " 不显示折叠列
set foldmethod=indent       " 基于缩进进行折叠
set foldlevel=10            " 打开文件时折叠级别
set foldenable              " 开启代码折叠功能

"-----------------------------------------------------------------------------
" 其他实用设置
"-----------------------------------------------------------------------------
set noeb                    " 去掉错误提示声音（no error bells）
set confirm                 " 处理未保存或只读文件时弹出确认对话框
set completeopt=longest,menu " 代码补全选项：最长匹配+菜单
set history=1000            " 命令历史记录数量
set report=0                " 报告修改行数的阈值（0表示总是报告）
set fillchars=vert:\ ,stl:\ ,stlnc:\ " 分割窗口的填充字符
set scrolloff=3             " 光标距离顶部和底部保持3行距离
set iskeyword+=_,$,@,%,#,-  " 定义单词分隔符（这些字符不会分割单词）
set linespace=0             " 字符间额外的像素行数
set wildmenu                " 增强模式的命令行自动补全
set backspace=2             " 退格键正常处理indent、eol、start
set whichwrap+=<,>,h,l      " 允许光标键和退格键跨越行边界
set mouse=a                 " 启用鼠标支持（所有模式）
set selection=exclusive     " 选择模式设置
set selectmode=mouse,key    " 选择模式：鼠标和键盘
set viminfo+=!              " 保存全局变量到viminfo文件

" make 设置 - 编译C++程序
:set makeprg=g++\ -Wall\ \ %

" 高亮显示普通txt文件（需要txt.vim脚本）
au BufRead,BufNewFile *  setfiletype txt

"-----------------------------------------------------------------------------
" 自动补全括号
"-----------------------------------------------------------------------------
:inoremap ( ()<ESC>i        " 输入(时自动补全)并将光标移到中间
:inoremap ) <c-r>=ClosePair(')')<CR>  " 输入)时智能处理
:inoremap [ []<ESC>i        " 输入[时自动补全]并将光标移到中间
:inoremap ] <c-r>=ClosePair(']')<CR>  " 输入]时智能处理
:inoremap " ""<ESC>i        " 输入"时自动补全"并将光标移到中间
:inoremap ' ''<ESC>i        " 输入'时自动补全'并将光标移到中间

" 智能括号闭合函数：如果下一个字符是对应的闭合字符，则跳过；否则插入
function! ClosePair(char)
	if getline('.')[col('.') - 1] == a:char
		return "\<Right>"
	else
		return a:char
	endif
endfunction