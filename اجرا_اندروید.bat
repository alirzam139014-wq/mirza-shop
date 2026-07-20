@echo off
chcp 65001 >nul
title Mirza Shop - Android Setup
color 0A

echo.
echo  ╔══════════════════════════════════════╗
echo  ║     Mirza Shop - نصب اندروید        ║
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

REM بررسی اتصال گوشی
echo  [INFO] گوشی رو با USB وصل کن و USB Debugging رو فعال کن
echo.
echo  فعال‌سازی USB Debugging:
echo  تنظیمات گوشی ^> درباره ^> ۷ بار روی Build Number بزن
echo  بعد: تنظیمات ^> Developer Options ^> USB Debugging
echo.
set /p ready="  وقتی گوشی وصل شد، Enter بزن..."

REM ساخت پلتفرم اندروید
echo.
echo  [1/3] ساخت فایل‌های اندروید...
call flutter create --platforms=android . --org com.mirzashop --project-name mirza_shop >nul 2>nul
echo  [OK] انجام شد

REM نصب وابستگی‌ها
echo  [2/3] نصب وابستگی‌ها...
call flutter pub get >nul 2>nul
echo  [OK] انجام شد

REM اجرا روی گوشی
echo  [3/3] نصب و اجرا روی گوشی...
echo.
echo  ══════════════════════════════════════
echo.
call flutter run

pause
