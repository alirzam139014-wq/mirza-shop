# این فایل را اجرا کنید تا پروژه آماده شود
# پیش‌نیاز: Flutter SDK نصب باشد (https://docs.flutter.dev/get-started/install)

echo "🏪 Mirza Shop - شروع نصب..."
echo ""

# ۱. نصب وابستگی‌ها
echo "📦 نصب وابستگی‌ها..."
flutter pub get

# ۲. ساخت پلتفرم‌ها
echo ""
echo "📱 ساخت فایل‌های پلتفرم..."
flutter create --platforms=android,windows . --org com.mirzashop --project-name mirza_shop

echo ""
echo "✅ آماده است!"
echo ""
echo "اجرا روی اندروید:"
echo "  flutter run"
echo ""
echo "اجرا روی ویندوز:"
echo "  flutter run -d windows"
echo ""
echo "ساخت APK:"
echo "  flutter build apk --release"
echo ""
echo "ساخت exe ویندوز:"
echo "  flutter build windows --release"
