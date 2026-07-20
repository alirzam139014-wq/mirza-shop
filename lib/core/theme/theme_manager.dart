/// مدیریت تم و ظاهر اپلیکیشن Mirza Shop
/// کاربر می‌تواند رنگ‌ها، فونت، حالت تاریک/روشن و پس‌زمینه را تغییر دهد
/// تمام تغییرات بدون نیاز به بستن برنامه اعمال می‌شوند
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Provider مدیریت تم
final themeManagerProvider =
    ChangeNotifierProvider<ThemeManager>((ref) => ThemeManager());

class ThemeManager extends ChangeNotifier {
  // ─── متغیرهای تم ───────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.dark;
  Color _primaryColor = const Color(0xFF00E5FF); // آبی نئون
  Color _neonColor = const Color(0xFF00E5FF);
  Color _cardColor = const Color(0xFF2A2A2A); // خاکستری روشن
  Color _backgroundColor = const Color(0xFF121212); // مشکی مات
  String _fontFamily = 'Vazir';
  double _fontSize = 14.0;
  String? _backgroundImage;

  // ─── Getters ───────────────────────────────────────────
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Color get neonColor => _neonColor;
  Color get cardColor => _cardColor;
  Color get backgroundColor => _backgroundColor;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  String? get backgroundImage => _backgroundImage;

  /// بارگذاری تنظیمات تم از حافظه
  Future<void> loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeStr = prefs.getString(AppConstants.keyThemeMode) ?? 'dark';
    _themeMode = themeModeStr == 'light' ? ThemeMode.light : ThemeMode.dark;

    final primaryColorVal = prefs.getInt(AppConstants.keyPrimaryColor);
    if (primaryColorVal != null) _primaryColor = Color(primaryColorVal);

    final neonColorVal = prefs.getInt(AppConstants.keyNeonColor);
    if (neonColorVal != null) _neonColor = Color(neonColorVal);

    final cardColorVal = prefs.getInt(AppConstants.keyCardColor);
    if (cardColorVal != null) _cardColor = Color(cardColorVal);

    _fontFamily = prefs.getString(AppConstants.keyFontFamily) ?? 'Vazir';
    _fontSize = prefs.getDouble(AppConstants.keyFontSize) ?? 14.0;
    _backgroundImage = prefs.getString(AppConstants.keyBackgroundImage);

    notifyListeners();
  }

  // ─── تغییر حالت تم ─────────────────────────────────────
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyThemeMode,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    notifyListeners();
  }

  /// تغییر بین حالت تاریک و روشن
  Future<void> toggleTheme() async {
    setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  // ─── تغییر رنگ اصلی ────────────────────────────────────
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyPrimaryColor, color.value);
    notifyListeners();
  }

  // ─── تغییر رنگ نئون ────────────────────────────────────
  Future<void> setNeonColor(Color color) async {
    _neonColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyNeonColor, color.value);
    notifyListeners();
  }

  // ─── تغییر رنگ کارت‌ها ─────────────────────────────────
  Future<void> setCardColor(Color color) async {
    _cardColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyCardColor, color.value);
    notifyListeners();
  }

  // ─── تغییر فونت ────────────────────────────────────────
  Future<void> setFontFamily(String font) async {
    _fontFamily = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyFontFamily, font);
    notifyListeners();
  }

  // ─── تغییر اندازه فونت ─────────────────────────────────
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyFontSize, size);
    notifyListeners();
  }

  // ─── تغییر تصویر پس‌زمینه ──────────────────────────────
  Future<void> setBackgroundImage(String? path) async {
    _backgroundImage = path;
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString(AppConstants.keyBackgroundImage, path);
    } else {
      await prefs.remove(AppConstants.keyBackgroundImage);
    }
    notifyListeners();
  }

  // ─── تم تاریک ──────────────────────────────────────────
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: _backgroundColor,
      primaryColor: _primaryColor,
      cardColor: _cardColor,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _neonColor,
        surface: _cardColor,
        error: const Color(0xFFEF5350),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: _fontSize + 4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: _cardColor.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _neonColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardColor.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _neonColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _neonColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _neonColor,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: _fontSize, fontFamily: _fontFamily),
        bodyLarge: TextStyle(fontSize: _fontSize + 2, fontFamily: _fontFamily),
        titleLarge: TextStyle(
          fontSize: _fontSize + 6,
          fontWeight: FontWeight.bold,
          fontFamily: _fontFamily,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _cardColor,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── تم روشن ───────────────────────────────────────────
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.light(
        primary: _primaryColor,
        secondary: _neonColor,
        surface: Colors.white,
        error: const Color(0xFFEF5350),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: _fontSize + 4,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: _fontSize, fontFamily: _fontFamily),
        bodyLarge: TextStyle(fontSize: _fontSize + 2, fontFamily: _fontFamily),
        titleLarge: TextStyle(
          fontSize: _fontSize + 6,
          fontWeight: FontWeight.bold,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }
}
