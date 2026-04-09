# =============================================
# 自定义 PowerShell 提示符脚本
# 功能：仅显示当前文件夹名称
# 使用：执行此脚本后，提示符将变为 "-> 文件夹名 "
# =============================================

function prompt {
    $path = Get-Location
    $lastFolder = Split-Path $path -Leaf
    if ($lastFolder) {
        "-> $lastFolder "
    } else {
        "-> $path "
    }
}

Write-Host "提示符已切换为简洁模式 (-> 当前文件夹名)" -ForegroundColor Green