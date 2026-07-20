/// نقطه شروع اپلیکیشن Mirza Shop
/// این فایل اولین فایلی است که هنگام اجرای برنامه اجرا می‌شود
/// شامل: مقداردهی دیتابیس، بررسی Onboarding، قفل برنامه، و اجرای اپ
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/database_helper.dart';
import 'core/theme/theme_manager.dart';
import 'core/services/logging_service.dart';
import 'features/products/presentation/screens/splash_screen.dart';
import 'features/products/presentation/screens/onboarding_screen.dart';
import 'features/products/presentation/screens/home_screen.dart';
import 'features/products/presentation/screens/desktop_home_screen.dart';
import 'features/settings/presentation/screens/app_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تنظیم جهت صفحه
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // مقداردهی اولیه دیتابیس
  await DatabaseHelper.instance.database;

  // مقداردهی سرویس لاگ
  await LoggingService.instance.init();
  await LoggingService.instance.info('App', 'Mirza Shop شروع شد');

  // بارگذاری تنظیمات تم
  // (داخل ThemeManager انجام می‌شود)

  runApp(
    const ProviderScope(
      child: MirzaShopApp(),
    ),
  );
}

/// ویجت اصلی اپلیکیشن
class MirzaShopApp extends ConsumerStatefulWidget {
  const MirzaShopApp({super.key});

  @override
  ConsumerState<MirzaShopApp> createState() => _MirzaShopAppState();
}

class _MirzaShopAppState extends ConsumerState<MirzaShopApp> {
  bool _showOnboarding = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // بارگذاری تنظیمات تم
    await ref.read(themeManagerProvider).loadThemeSettings();

    // بررسی آیا Onboarding قبلاً دیده شده
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      _showOnboarding = !onboardingDone;
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    return MaterialApp(
      title: 'Mirza Shop',
      debugShowCheckedModeBanner: false,

      // تم تاریک (پیش‌فرض)
      darkTheme: themeManager.darkTheme,

      // تم روشن
      theme: themeManager.lightTheme,

      // حالت تم بر اساس تنظیمات کاربر
      themeMode: themeManager.themeMode,

      // صفحه شروع
      home: !_isReady
          ? const _LoadingScreen()
          : _showOnboarding
              ? const OnboardingScreen()
              : _buildMainScreen(),

      // پشتیبانی از RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }

  /// ساخت صفحه اصلی بر اساس پلتفرم
  Widget _buildMainScreen() {
    // نسخه ویندوز: لایوت دسکتاپ با پنل دو طرفه
    // نسخه موبایل: لایوت استاندارد
    final homeScreen =
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ? const DesktopHomeScreen()
            : const HomeScreen();

    // اگر قفل برنامه فعال باشد، AppLockScreen دور صفحه اصلی قرار می‌گیرد
    return AppLockScreen(child: homeScreen);
  }
}

/// صفحه بارگذاری اولیه (قبل از آماده شدن اپ)
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00E5FF),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
