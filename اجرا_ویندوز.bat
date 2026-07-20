@echo off
chcp 65001 >nul
title Mirza Shop - Windows Setup
color 0A

echo.
echo  ╔══════════════════════════════════════╗
echo  ║      Mirza Shop - نصب ویندوز       ║
echo  ╚══════════════════════════════════════╝
echo.

REM بررسی نصب Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo  [ERROR] Flutter نصب نیست!
    echo.
    echo  لطفاً اول Flutter رو نصب کن:
    echo  https://docs.flutter.dev/get-started/install/windows
    echo.
    pause
    exit /b 1
)

echo  [OK] Flutter پیدا شد
echo.

REM ساخت پلتفرم ویندوز
echo  [1/3] ساخت فایل‌های ویندوز...
call flutter create --platforms=windows . --org com.mirzashop --project-name mirza_shop >nul 2>nul
echo  [OK] انجام شد
echo.

REM نصب وابستگی‌ها
echo  [2/3] نصب وابستگی‌ها...
call flutter pub get
echo.

REM اجرا
echo  [3/3] اجرای برنامه...
echo.
echo  ══════════════════════════════════════
echo.
call flutter run -d windows

pause
