@echo off
chcp 65001 >nul
title Mirza Shop - Build APK
color 0B

echo.
echo  ╔══════════════════════════════════════╗
echo  ║    Mirza Shop - ساخت APK اندروید    ║
echo  ╚══════════════════════════════════════╝
echo.

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo  [ERROR] Flutter نصب نیست!
    pause
    exit /b 1
)

echo  [1/2] آماده‌سازی...
call flutter create --platforms=android . --org com.mirzashop --project-name mirza_shop >nul 2>nul
call flutter pub get >nul 2>nul

echo  [2/2] ساخت APK...
echo  (چند دقیقه صبر کن)
echo.
call flutter build apk --release

echo.
echo  ══════════════════════════════════════
echo  [OK] فایل APK ساخته شد!
echo.
echo  مسیر خروجی:
echo  build\app\outputs\flutter-apk\app-release.apk
echo.
echo  این فایل رو ببر روی گوشی و نصب کن.
echo  ══════════════════════════════════════
echo.
pause
