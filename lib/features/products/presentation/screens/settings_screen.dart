/// صفحه تنظیمات
/// کاربر می‌تواند: رنگ اصلی، رنگ نئون، فونت، اندازه فونت،
/// تصویر پس‌زمینه، حالت تاریک/روشن را تغییر دهد
/// تمام تغییرات بدون نیاز به بستن برنامه اعمال می‌شوند
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('تنظیمات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── بخش ظاهر ────────────────────────────────────
          _SectionTitle(title: 'ظاهر برنامه'),
          const SizedBox(height: 12),

          // حالت تاریک / روشن
          _SettingsCard(
            child: Row(
              children: [
                const Icon(Icons.dark_mode_rounded,
                    color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('حالت تاریک',
                      style:
                          TextStyle(color: Colors.white, fontSize: 15)),
                ),
                Switch(
                  value: themeManager.themeMode == ThemeMode.dark,
                  onChanged: (_) => themeManager.toggleTheme(),
                  activeColor: const Color(0xFF00E5FF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // رنگ اصلی
          _SettingsCard(
            child: Row(
              children: [
                const Icon(Icons.palette_rounded,
                    color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('رنگ اصلی',
                      style:
                          TextStyle(color: Colors.white, fontSize: 15)),
                ),
                GestureDetector(
                  onTap: () => _showColorPicker(
                    context,
                    themeManager.primaryColor,
                    (color) => themeManager.setPrimaryColor(color),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: themeManager.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // رنگ نئون
          _SettingsCard(
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('رنگ نئون',
                      style:
                          TextStyle(color: Colors.white, fontSize: 15)),
                ),
                GestureDetector(
                  onTap: () => _showColorPicker(
                    context,
                    themeManager.neonColor,
                    (color) => themeManager.setNeonColor(color),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: themeManager.neonColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // اندازه فونت
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields_rounded,
                        color: Color(0xFF00E5FF), size: 22),
                    const SizedBox(width: 12),
                    const Text('اندازه فونت',
                        style:
                            TextStyle(color: Colors.white, fontSize: 15)),
                    const Spacer(),
                    Text(
                      '${themeManager.fontSize.toInt()}',
                      style: const TextStyle(
                          color: Color(0xFF00E5FF), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: themeManager.fontSize,
                  min: 12,
                  max: 20,
                  divisions: 8,
                  activeColor: themeManager.neonColor,
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (value) => themeManager.setFontSize(value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── بخش داده‌ها ─────────────────────────────────
          _SectionTitle(title: 'داده‌ها'),
          const SizedBox(height: 12),

          // نسخه پشتیبان
          _SettingsCard(
            child: InkWell(
              onTap: () {
                // TODO: رفتن به صفحه بکاپ
              },
              child: Row(
                children: [
                  const Icon(Icons.backup_rounded,
                      color: Color(0xFF4CAF50), size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('نسخه پشتیبان',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('ذخیره و بازیابی اطلاعات',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded,
                      color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // پاکسازی حافظه
          _SettingsCard(
            child: InkWell(
              onTap: () {
                // TODO: پاکسازی فایل‌های موقت
              },
              child: Row(
                children: [
                  const Icon(Icons.cleaning_services_rounded,
                      color: Color(0xFFFF9800), size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('پاکسازی حافظه',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('حذف فایل‌های موقت و اضافی',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded,
                      color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ─── بخش امنیت ───────────────────────────────────
          _SectionTitle(title: 'امنیت'),
          const SizedBox(height: 12),

          _SettingsCard(
            child: Row(
              children: [
                const Icon(Icons.lock_rounded,
                    color: Color(0xFF9C27B0), size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('قفل برنامه',
                          style:
                              TextStyle(color: Colors.white, fontSize: 15)),
                      SizedBox(height: 2),
                      Text('رمز عبور، پین‌کد یا اثر انگشت',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: فعال‌سازی قفل
                  },
                  activeColor: const Color(0xFF9C27B0),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── درباره برنامه ───────────────────────────────
          _SettingsCard(
            child: InkWell(
              onTap: () => _showAbout(context),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF00E5FF), size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('درباره Mirza Shop',
                        style:
                            TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                  Icon(Icons.chevron_left_rounded,
                      color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// نمایش انتخابگر رنگ
  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    final colors = [
      const Color(0xFF00E5FF), // آبی نئون
      const Color(0xFF00FF88), // سبز نئون
      const Color(0xFFFF6B6B), // قرمز
      const Color(0xFFFFD93D), // زرد
      const Color(0xFF6C5CE7), // بنفش
      const Color(0xFFFF9800), // نارنجی
      const Color(0xFFE91E63), // صورتی
      const Color(0xFF4CAF50), // سبز
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'انتخاب رنگ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentColor.value == color.value
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mirza Shop',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نسخه 1.0.0',
                style: TextStyle(color: Color(0xFF00E5FF))),
            const SizedBox(height: 12),
            Text(
              'نرم‌افزار مدیریت محصوالت فروشگاه\n\n'
              'طراحی شده برای سوپرمارکت‌ها، هایپرمارکت‌ها،\n'
              'لوازم تحریری، آرایشی، لبنیات و مواد غذایی\n\n'
              'کاملاً آفلاین | بدون نیاز به اینترنت',
              style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }
}

/// عنوان بخش تنظیمات
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00E5FF),
      ),
    );
  }
}

/// کارت تنظیمات
class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}
