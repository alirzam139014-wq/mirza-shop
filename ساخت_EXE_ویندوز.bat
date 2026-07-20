@echo off
chcp 65001 >nul
title Mirza Shop - Build Windows EXE
color 0B

echo.
echo  ╔══════════════════════════════════════╗
echo  ║   Mirza Shop - ساخت EXE ویندوز     ║
echo  ╚══════════════════════════════════════╝
echo.

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo  [ERROR] Flutter نصب نیست!
    pause
    exit /b 1
)

echo  [1/2] آماده‌سازی...
call flutter create --platforms=windows . --org com.mirzashop --project-name mirza_shop >nul 2>nul
call flutter pub get >nul 2>nul

echo  [2/2] ساخت فایل اجرایی...
echo.
call flutter build windows --release

echo.
echo  ══════════════════════════════════════
echo  [OK] فایل EXE ساخته شد!
echo.
echo  مسیر خروجی:
echo  build\windows\x64\runner\Release\mirza_shop.exe
echo.
echo  کل پوشه Release رو کپی کن و هر جا خواستی اجرا کن.
echo  ══════════════════════════════════════
echo.
pause
