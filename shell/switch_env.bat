@echo off
chcp 65001 >nul
cd /d "%~dp0"

if "%~1"=="" (
    echo.
    echo 请输入环境模式:
    echo   dev-w  - Web开发模式(localhost)
    echo   dev-a  - Android开发模式(模拟器)
    echo   prod   - 生产环境(HTTP)
    echo   prods  - 生产环境(HTTPS)
    echo   test   - 测试环境
    echo.
    set /p mode="请输入模式: "
) else (
    set mode=%~1
)

powershell -ExecutionPolicy Bypass -File "%~dp0switch_env.ps1" %mode%
pause
