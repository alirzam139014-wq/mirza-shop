/// تم‌های آماده (Preset Themes)
/// کاربر می‌تواند یکی از تم‌های آماده را انتخاب کند
/// یا تم شخصی خودش را بسازد و ذخیره کند
/// تم‌ها: Neon Blue, Cyber Dark, Glass Black, Purple Night, Emerald
library;

import 'package:flutter/material.dart';

/// مدل تم آماده
class PresetTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color neonColor;
  final Color cardColor;
  final Color backgroundColor;
  final IconData icon;

  const PresetTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.neonColor,
    required this.cardColor,
    required this.backgroundColor,
    required this.icon,
  });
}

/// لیست تم‌های آماده
class AppThemes {
  AppThemes._();

  static const List<PresetTheme> presetThemes = [
    // آبی نئون (پیش‌فرض)
    PresetTheme(
      id: 'neon_blue',
      name: 'Neon Blue',
      primaryColor: Color(0xFF00E5FF),
      neonColor: Color(0xFF00E5FF),
      cardColor: Color(0xFF2A2A2A),
      backgroundColor: Color(0xFF121212),
      icon: Icons.water_drop_rounded,
    ),

    // سایبر دارک
    PresetTheme(
      id: 'cyber_dark',
      name: 'Cyber Dark',
      primaryColor: Color(0xFFFF6B6B),
      neonColor: Color(0xFFFF6B6B),
      cardColor: Color(0xFF1E1E2E),
      backgroundColor: Color(0xFF0D0D1A),
      icon: Icons.shield_rounded,
    ),

    // گلس بلک
    PresetTheme(
      id: 'glass_black',
      name: 'Glass Black',
      primaryColor: Color(0xFFE0E0E0),
      neonColor: Color(0xFFBDBDBD),
      cardColor: Color(0xFF1A1A1A),
      backgroundColor: Color(0xFF000000),
      icon: Icons.blur_on_rounded,
    ),

    // بنفش شب
    PresetTheme(
      id: 'purple_night',
      name: 'Purple Night',
      primaryColor: Color(0xFFBB86FC),
      neonColor: Color(0xFFBB86FC),
      cardColor: Color(0xFF2D2040),
      backgroundColor: Color(0xFF1A1025),
      icon: Icons.nights_stay_rounded,
    ),

    // زمرد
    PresetTheme(
      id: 'emerald',
      name: 'Emerald',
      primaryColor: Color(0xFF00FF88),
      neonColor: Color(0xFF00FF88),
      cardColor: Color(0xFF1A2E22),
      backgroundColor: Color(0xFF0D1A12),
      icon: Icons.eco_rounded,
    ),

    // طلایی
    PresetTheme(
      id: 'golden',
      name: 'Golden',
      primaryColor: Color(0xFFFFD700),
      neonColor: Color(0xFFFFD700),
      cardColor: Color(0xFF2E2A1A),
      backgroundColor: Color(0xFF1A170D),
      icon: Icons.star_rounded,
    ),

    // نارنجی آتشین
    PresetTheme(
      id: 'fire_orange',
      name: 'Fire Orange',
      primaryColor: Color(0xFFFF9800),
      neonColor: Color(0xFFFF9800),
      cardColor: Color(0xFF2E221A),
      backgroundColor: Color(0xFF1A120D),
      icon: Icons.local_fire_department_rounded,
    ),

    // صورتی نئون
    PresetTheme(
      id: 'neon_pink',
      name: 'Neon Pink',
      primaryColor: Color(0xFFFF4081),
      neonColor: Color(0xFFFF4081),
      cardColor: Color(0xFF2E1A24),
      backgroundColor: Color(0xFF1A0D14),
      icon: Icons.favorite_rounded,
    ),
  ];

  /// دریافت تم بر اساس شناسه
  static PresetTheme? getThemeById(String id) {
    try {
      return presetThemes.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
