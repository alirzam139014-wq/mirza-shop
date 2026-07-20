/// صفحه نسخه پشتیبان (Backup & Restore)
/// ساخت بکاپ دستی، بازیابی، نمایش لیست بکاپ‌ها، انتقال بین دستگاه‌ها
/// بکاپ خودکار (روزانه/هفتگی/هنگام خروج)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/utils/helpers.dart';
import '../../data/services/backup_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) => BackupService());

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isCreatingBackup = false;
  bool _isRestoring = false;
  List<BackupInfo> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final service = ref.read(backupServiceProvider);
    final backups = await service.getBackups();
    if (mounted) setState(() => _backups = backups);
  }

  /// ساخت نسخه پشتیبان
  Future<void> _createBackup() async {
    setState(() => _isCreatingBackup = true);
    try {
      final service = ref.read(backupServiceProvider);
      final backup = await service.createBackup();
      if (mounted) {
        AppHelpers.showSuccess(
          context,
          'نسخه پشتیبان ساخته شد (${backup.productCount} محصول) ✓',
        );
        _loadBackups();
      }
    } catch (e) {
      if (mounted) AppHelpers.showError(context, 'خطا در ساخت بکاپ: $e');
    }
    setState(() => _isCreatingBackup = false);
  }

  /// بازیابی از بکاپ
  Future<void> _restoreBackup(BackupInfo backup) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      context,
      title: 'بازیابی اطلاعات',
      message:
          'اطلاعات فعلی جایگزین خواهد شد.\nبکاپ: ${AppHelpers.formatDateTime(backup.createdAt)}\nتعداد محصوالت: ${backup.productCount}\n\nادامه می‌دهید؟',
      confirmText: 'بازیابی',
      confirmColor: const Color(0xFF4CAF50),
    );

    if (!confirmed) return;

    setState(() => _isRestoring = true);
    try {
      final service = ref.read(backupServiceProvider);
      await service.restoreBackup(backup.filePath);
      if (mounted) {
        AppHelpers.showSuccess(context, 'اطالعات با موفقیت بازیابی شد ✓');
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'بازیابی انجام نشد. فایل معتبر نیست.');
      }
    }
    setState(() => _isRestoring = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('نسخه پشتیبان'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── دکمه ساخت بکاپ ─────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isCreatingBackup ? null : _createBackup,
              icon: _isCreatingBackup
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.backup_rounded),
              label: Text(
                _isCreatingBackup ? 'در حال ساخت...' : 'ساخت نسخه پشتیبان',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── بکاپ خودکار ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeManager.cardColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.autorenew_rounded,
                    color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('بکاپ خودکار',
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                      SizedBox(height: 2),
                      Text('هنگام خروج از برنامه',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: const Color(0xFF00E5FF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── لیست بکاپ‌ها ───────────────────────────────
          const Text(
            'نسخه‌های پشتیبان',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          if (_backups.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.history_rounded,
                      size: 48, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 12),
                  Text(
                    'هنوز نسخه پشتیبانی ساخته نشده',
                    style: TextStyle(color: Colors.white.withOpacity(0.4)),
                  ),
                ],
              ),
            )
          else
            ..._backups.asMap().entries.map((entry) {
              final index = entry.key;
              final backup = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: themeManager.cardColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.folder_rounded,
                            color: Color(0xFF4CAF50), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${backup.productCount} محصول',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppHelpers.formatDateTime(backup.createdAt),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // دکمه بازیابی
                      IconButton(
                        onPressed: _isRestoring
                            ? null
                            : () => _restoreBackup(backup),
                        icon: const Icon(Icons.restore_rounded,
                            color: Color(0xFF4CAF50), size: 20),
                        tooltip: 'بازیابی',
                      ),
                      // دکمه حذف
                      IconButton(
                        onPressed: () async {
                          final service = ref.read(backupServiceProvider);
                          await service.deleteBackup(index);
                          _loadBackups();
                        },
                        icon: Icon(Icons.delete_outline_rounded,
                            color: Colors.white.withOpacity(0.3), size: 20),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),

          // ─── راهنمای انتقال ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFF00E5FF), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'انتقال به دستگاه جدید',
                      style: TextStyle(
                          color: Color(0xFF00E5FF), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '۱. بکاپ بگیرید\n۲. فایل بکاپ را به دستگاه جدید منتقل کنید\n۳. در دستگاه جدید، بازیابی کنید',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
