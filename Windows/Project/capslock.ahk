#Requires AutoHotkey v2.0

; ==============================================================================
; 基础设置
; ==============================================================================
SetWorkingDir(A_ScriptDir)
SetCapsLockState("AlwaysOff")
SendMode("Input")

; ==============================================================================
; CapsLock 核心逻辑 (修复连按变 Alt 激活菜单问题)
; ==============================================================================
*CapsLock:: {
    ; 1. 发送 Alt 按下
    ; {Blind}: 允许配合 Shift/Ctrl 等键使用
    ; DownR: 告诉系统这是重映射，减少干扰
    Send("{Blind}{LAlt DownR}")

    ; 2. 等待 CapsLock 松开
    KeyWait("CapsLock")

    ; 3. 发送 Alt 松开
    Send("{Blind}{LAlt Up}")

    ; 4. 如果期间没有按过其他键 (说明是单独点击)，补发 Esc
    if (A_PriorKey = "CapsLock") {
        Send("{Esc}")
    }
}

; 【防干扰补丁】
; 屏蔽左 Alt 键单独按下时激活菜单的功能 (发送一个垃圾码 vkE8)
; 这能完美解决“连按 CapsLock 导致菜单栏闪烁”的问题
~LAlt::Send("{Blind}{vkE8}")


; ==============================================================================
; Win + HJKL 映射为方向键 (Vim 风格)
; ==============================================================================

; <# 表示仅限左 Win 键 (防止干扰系统原本的 Win+L 锁屏等热键)
; 如果你习惯用右 Win，可以去掉 <，或者改成 >#

<#h::Send("{Left}")   ; Win + h -> 左
<#j::Send("{Down}")   ; Win + j -> 下
<#k::Send("{Up}")     ; Win + k -> 上
<#l::Send("{Right}")  ; Win + l -> 右

; 注意：Win+L 默认是 Windows 的锁屏快捷键。
; 计算机\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System
; 新建一下DisableLockWorkstation格式为DWORD(32),值为1