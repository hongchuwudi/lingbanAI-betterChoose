# ===========================================
# Flutter + Spring Boot 环境切换脚本
# 使用方法: .\switch_env.ps1 <模式>
# 示例: .\switch_env.ps1 dev-a
# ===========================================

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Mode
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "config.txt"
$flutterConfigFile = Join-Path $scriptDir "..\code\common_base_mobile_flutter\lib\config\app_config.dart"
$springBootConfigFile = Join-Path $scriptDir "..\code\common-base-server\cb-service\src\main\resources\application.yml"

# 模式与 Spring Boot profile 的映射
$profileMapping = @{
    "dev-w" = "dev"
    "dev-a" = "dev"
    "prod"  = "prod"
    "prods" = "prod"
    "test"  = "prod"
}

function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Flutter + Spring Boot 环境切换工具" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "可用模式:" -ForegroundColor Green
    
    if (Test-Path $configFile) {
        $configs = Get-Content $configFile | Where-Object { $_ -match "^[^#]" -and $_ -match "\|" }
        foreach ($config in $configs) {
            $parts = $config -split "\|"
            if ($parts.Count -ge 4) {
                $springProfile = $profileMapping[$parts[0].Trim()]
                Write-Host "  $($parts[0].PadRight(8)) - $($parts[3]) (Spring: $springProfile)" -ForegroundColor White
            }
        }
    }
    
    Write-Host ""
    Write-Host "使用方法: .\switch_env.ps1 <模式>" -ForegroundColor Yellow
    Write-Host "示例:     .\switch_env.ps1 dev-a" -ForegroundColor Yellow
    Write-Host ""
}

function Show-CurrentEnv {
    Write-Host ""
    Write-Host "当前 Flutter 环境:" -ForegroundColor Green
    if (Test-Path $flutterConfigFile) {
        $content = Get-Content $flutterConfigFile -Raw
        if ($content -match "static const String apiBaseUrl = '([^']+)';") {
            Write-Host "  API URL: $($matches[1])" -ForegroundColor White
        }
        if ($content -match "static const String wsBaseUrl = '([^']+)';") {
            Write-Host "  WS  URL: $($matches[1])" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Write-Host "当前 Spring Boot 环境:" -ForegroundColor Green
    if (Test-Path $springBootConfigFile) {
        $ymlContent = Get-Content $springBootConfigFile -Raw
        if ($ymlContent -match "active:\s*(\w+)") {
            Write-Host "  Profile: $($matches[1])" -ForegroundColor White
        }
    }
    Write-Host ""
}

if ([string]::IsNullOrWhiteSpace($Mode) -or $Mode -eq "help" -or $Mode -eq "-h" -or $Mode -eq "--help") {
    Show-Help
    Show-CurrentEnv
    exit 0
}

# 检查配置文件
if (-not (Test-Path $configFile)) {
    Write-Host "错误: 配置文件 config.txt 不存在!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $flutterConfigFile)) {
    Write-Host "错误: Flutter 配置文件 app_config.dart 不存在!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $springBootConfigFile)) {
    Write-Host "错误: Spring Boot 配置文件 application.yml 不存在!" -ForegroundColor Red
    exit 1
}

# 读取配置
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
    Show-Help
    exit 1
}

# 获取 Spring Boot profile
$springProfile = $profileMapping[$Mode]
if (-not $springProfile) {
    $springProfile = "dev"
}

# ===========================================
# 1. 更新 Flutter 配置
# ===========================================
$flutterContent = Get-Content $flutterConfigFile -Raw
$flutterContent = $flutterContent -replace "static const String apiBaseUrl = '[^'']+';", "static const String apiBaseUrl = '$apiUrl';"
$flutterContent = $flutterContent -replace "static const String wsBaseUrl = '[^'']+';", "static const String wsBaseUrl = '$wsUrl';"
Set-Content -Path $flutterConfigFile -Value $flutterContent -NoNewline -Encoding UTF8

Write-Host "✅ Flutter 配置已更新" -ForegroundColor Green

# ===========================================
# 2. 更新 Spring Boot 配置
# ===========================================
$ymlContent = Get-Content $springBootConfigFile -Raw

# 替换 active profile
# 匹配格式: active: dev 或 active: prod 等
$ymlContent = $ymlContent -replace "active:\s*\w+", "active: $springProfile"

Set-Content -Path $springBootConfigFile -Value $ymlContent -NoNewline -Encoding UTF8

Write-Host "✅ Spring Boot 配置已更新 (profile: $springProfile)" -ForegroundColor Green

# ===========================================
# 3. 显示结果
# ===========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  环境切换成功!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "模式: $Mode" -ForegroundColor Cyan
if ($description) {
    Write-Host "描述: $description" -ForegroundColor Cyan
}
Write-Host "Spring Profile: $springProfile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flutter API URL: $apiUrl" -ForegroundColor Yellow
Write-Host "Flutter WS  URL: $wsUrl" -ForegroundColor Yellow
Write-Host ""

# 提示后续操作
Write-Host "后续操作:" -ForegroundColor Magenta
Write-Host "  1. Flutter: flutter clean && flutter pub get" -ForegroundColor White
Write-Host "  2. Spring Boot: 重新打包或重启服务" -ForegroundColor White
Write-Host ""