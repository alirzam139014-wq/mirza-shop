@echo off
REM این فایل را اجرا کنید تا پروژه آماده شود
REM پیش‌نیاز: Flutter SDK نصب باشد

echo ========================================
echo   Mirza Shop - شروع نصب...
echo ========================================
echo.

REM ۱. نصب وابستگی‌ها
echo [1/2] نصب وابستگی‌ها...
call flutter pub get

REM ۲. ساخت پلتفرم‌ها
echo.
echo [2/2] ساخت فایل‌های پلتفرم...
call flutter create --platforms=android,windows . --org com.mirzashop --project-name mirza_shop

echo.
echo ========================================
echo   آماده است!
echo ========================================
echo.
echo اجرا روی اندروید:   flutter run
echo اجرا روی ویندوز:    flutter run -d windows
echo ساخت APK:           flutter build apk --release
echo ساخت exe ویندوز:    flutter build windows --release
echo.
pause
