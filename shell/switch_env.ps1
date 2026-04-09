# ===========================================
# Flutter 环境切换脚本
# 使用方法: .\switch_env.ps1 <模式>
# 示例: .\switch_env.ps1 dev-a
# ===========================================

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Mode
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "config.txt"
$targetFile = Join-Path $scriptDir "..\code\common_base_mobile_flutter\lib\config\app_config.dart"

function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Flutter 环境切换工具" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "可用模式:" -ForegroundColor Green
    
    if (Test-Path $configFile) {
        $configs = Get-Content $configFile | Where-Object { $_ -match "^[^#]" -and $_ -match "\|" }
        foreach ($config in $configs) {
            $parts = $config -split "\|"
            if ($parts.Count -ge 4) {
                Write-Host "  $($parts[0].PadRight(8)) - $($parts[3])" -ForegroundColor White
            }
        }
    }
    
    Write-Host ""
    Write-Host "使用方法: .\switch_env.ps1 <模式>" -ForegroundColor Yellow
    Write-Host "示例:     .\switch_env.ps1 dev-a" -ForegroundColor Yellow
    Write-Host ""
}

function Show-CurrentEnv {
    if (Test-Path $targetFile) {
        $content = Get-Content $targetFile -Raw
        if ($content -match "static const String apiBaseUrl = '([^']+)';") {
            $currentApi = $matches[1]
        }
        if ($content -match "static const String wsBaseUrl = '([^']+)';") {
            $currentWs = $matches[1]
        }
        Write-Host ""
        Write-Host "当前环境:" -ForegroundColor Green
        Write-Host "  API URL: $currentApi" -ForegroundColor White
        Write-Host "  WS  URL: $currentWs" -ForegroundColor White
        Write-Host ""
    }
}

if ([string]::IsNullOrWhiteSpace($Mode) -or $Mode -eq "help" -or $Mode -eq "-h" -or $Mode -eq "--help") {
    Show-Help
    Show-CurrentEnv
    exit 0
}

if (-not (Test-Path $configFile)) {
    Write-Host "错误: 配置文件 config.txt 不存在!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $targetFile)) {
    Write-Host "错误: 目标文件 app_config.dart 不存在!" -ForegroundColor Red
    exit 1
}

$configs = Get-Content $configFile | Where-Object { $_ -match "^[^#]" -and $_ -match "\|" }
$found = $false
$apiUrl = ""
$wsUrl = ""
$description = ""

foreach ($config in $configs) {
    $parts = $config -split "\|"
    if ($parts.Count -ge 3 -and $parts[0].Trim() -eq $Mode) {
        $found = $true
        $apiUrl = $parts[1].Trim()
        $wsUrl = $parts[2].Trim()
        if ($parts.Count -ge 4) {
            $description = $parts[3].Trim()
        }
        break
    }
}

if (-not $found) {
    Write-Host "错误: 未找到模式 '$Mode'!" -ForegroundColor Red
    Write-Host "请检查 config.txt 文件中的配置。" -ForegroundColor Yellow
    Show-Help
    exit 1
}

$content = Get-Content $targetFile -Raw

# 替换 URL（注意：正则中单引号需双写）
$newContent = $content -replace "static const String apiBaseUrl = '[^'']+';", "static const String apiBaseUrl = '$apiUrl';"
$newContent = $newContent -replace "static const String wsBaseUrl = '[^'']+';", "static const String wsBaseUrl = '$wsUrl';"

Set-Content -Path $targetFile -Value $newContent -NoNewline -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  环境切换成功!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "模式: $Mode" -ForegroundColor Cyan
if ($description) {
    Write-Host "描述: $description" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "API URL: $apiUrl" -ForegroundColor Yellow
Write-Host "WS  URL: $wsUrl" -ForegroundColor Yellow
Write-Host ""