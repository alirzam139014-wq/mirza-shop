/// ثابت‌های سراسری اپلیکیشن Mirza Shop
/// شامل نام دیتابیس، کلیدها، و مقادیر پیش‌فرض
class AppConstants {
  AppConstants._();

  // ─── اطلاعات اپلیکیشن ───────────────────────────────────
  static const String appName = 'Mirza Shop';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ─── دیتابیس ───────────────────────────────────────────
  static const String databaseName = 'mirza_shop.db';
  static const int databaseVersion = 1;

  // ─── نام جداول دیتابیس ─────────────────────────────────
  static const String tableProducts = 'products';
  static const String tableCategories = 'categories';
  static const String tableSettings = 'settings';
  static const String tableBackups = 'backups';
  static const String tablePriceHistory = 'price_history';

  // ─── کلیدهای SharedPreferences ──────────────────────────
  static const String keyThemeMode = 'theme_mode';
  static const String keyPrimaryColor = 'primary_color';
  static const String keyNeonColor = 'neon_color';
  static const String keyCardColor = 'card_color';
  static const String keyFontFamily = 'font_family';
  static const String keyFontSize = 'font_size';
  static const String keyBackgroundImage = 'background_image';
  static const String keyViewMode = 'view_mode';
  static const String keyAppLock = 'app_lock';

  // ─── پوشه‌ها ───────────────────────────────────────────
  static const String folderImages = 'images';
  static const String folderBackup = 'backup';
  static const String folderCache = 'cache';

  // ─── مقادیر پیش‌فرض ────────────────────────────────────
  static const int defaultPageSize = 50;
  static const int searchDebounceMs = 300;
  static const int animationDurationMs = 250;
  static const int splashDurationMs = 2000;

  // ─── محدودیت‌ها ────────────────────────────────────────
  static const int maxImageSizeKB = 500;
  static const double imageQuality = 0.85;
  static const int maxProductsForSmoothPerformance = 100000;
}
