/// صفحه قفل برنامه (App Lock)
/// امکان فعال‌سازی رمز عبور، پین‌کد یا اثر انگشت
/// قفل هنگام باز شدن برنامه فعال می‌شود
/// محافظت از اطلاعات فروشگاه در برابر دسترسی غیرمجاز
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_manager.dart';

/// Provider قفل برنامه
final appLockProvider =
    ChangeNotifierProvider<AppLockManager>((ref) => AppLockManager());

class AppLockManager extends ChangeNotifier {
  bool _isLockEnabled = false;
  String _pin = '';
  bool _useBiometric = false;

  bool get isLockEnabled => _isLockEnabled;
  bool get useBiometric => _useBiometric;

  /// بارگذاری تنظیمات قفل
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    _pin = prefs.getString('app_lock_pin') ?? '';
    _useBiometric = prefs.getBool('app_lock_biometric') ?? false;
    notifyListeners();
  }

  /// فعال/غیرفعال کردن قفل
  Future<void> setLockEnabled(bool enabled) async {
    _isLockEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', enabled);
    notifyListeners();
  }

  /// تنظیم پین‌کد
  Future<void> setPin(String pin) async {
    _pin = pin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lock_pin', pin);
    notifyListeners();
  }

  /// فعال/غیرفعال کردن اثر انگشت
  Future<void> setBiometric(bool enabled) async {
    _useBiometric = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_biometric', enabled);
    notifyListeners();
  }

  /// بررسی پین واردشده
  bool verifyPin(String input) => input == _pin;
}

class AppLockScreen extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockScreen({super.key, required this.child});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String _enteredPin = '';
  bool _isError = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkLock();
  }

  Future<void> _checkLock() async {
    final lockManager = ref.read(appLockProvider);
    await lockManager.loadSettings();

    if (!lockManager.isLockEnabled) {
      setState(() => _isAuthenticated = true);
      return;
    }

    // تلاش برای احراز هویت بیومتریک
    if (lockManager.useBiometric) {
      await _authenticateBiometric();
    }
  }

  /// احراز هویت با اثر انگشت
  Future<void> _authenticateBiometric() async {
    try {
      final localAuth = LocalAuthentication();
      final canCheck = await localAuth.canCheckBiometrics;
      if (!canCheck) return;

      final authenticated = await localAuth.authenticate(
        localizedReason: 'برای ورود به Mirza Shop اثر انگشت خود را اسکن کنید',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        setState(() => _isAuthenticated = true);
      }
    } catch (e) {
      // خطا نادیده گرفته می‌شود، کاربر می‌تواند پین وارد کند
    }
  }

  /// ورود پین
  void _onPinDigit(String digit) {
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += digit;
      _isError = false;
    });

    // بررسی خودکار وقتی ۴ رقم کامل شد
    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  /// بررسی پین
  void _verifyPin() {
    final lockManager = ref.read(appLockProvider);
    if (lockManager.verifyPin(_enteredPin)) {
      setState(() => _isAuthenticated = true);
    } else {
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
      HapticFeedback.heavyImpact();
    }
  }

  /// حذف آخرین رقم
  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _isError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // اگر قفل غیرفعال است یا احراز هویت انجام شده
    if (_isAuthenticated) {
      return widget.child;
    }

    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // لوگو
            Icon(
              Icons.storefront_rounded,
              size: 48,
              color: themeManager.neonColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mirza Shop',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // نقطه‌های پین
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length
                        ? (_isError
                            ? const Color(0xFFEF5350)
                            : themeManager.neonColor)
                        : Colors.transparent,
                    border: Border.all(
                      color: _isError
                          ? const Color(0xFFEF5350)
                          : themeManager.neonColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // پیام خطا
            if (_isError)
              const Text(
                'پین‌کد اشتباه است',
                style: TextStyle(color: Color(0xFFEF5350), fontSize: 14),
              ),

            const SizedBox(height: 40),

            // کیبورد پین
            _buildPinPad(themeManager),

            const Spacer(),

            // دکمه اثر انگشت
            if (ref.watch(appLockProvider).useBiometric)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: IconButton(
                  onPressed: _authenticateBiometric,
                  icon: Icon(
                    Icons.fingerprint_rounded,
                    size: 40,
                    color: themeManager.neonColor.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// کیبورد عددی پین
  Widget _buildPinPad(ThemeManager themeManager) {
    return Column(
      children: [
        _buildPinRow(['1', '2', '3'], themeManager),
        const SizedBox(height: 16),
        _buildPinRow(['4', '5', '6'], themeManager),
        const SizedBox(height: 16),
        _buildPinRow(['7', '8', '9'], themeManager),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80, height: 64),
            _buildPinButton('0', themeManager),
            SizedBox(
              width: 80,
              height: 64,
              child: IconButton(
                onPressed: _onBackspace,
                icon: Icon(
                  Icons.backspace_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinRow(List<String> digits, ThemeManager themeManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits
          .map((digit) => _buildPinButton(digit, themeManager))
          .toList(),
    );
  }

  Widget _buildPinButton(String digit, ThemeManager themeManager) {
    return SizedBox(
      width: 80,
      height: 64,
      child: TextButton(
        onPressed: () => _onPinDigit(digit),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
        ),
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
