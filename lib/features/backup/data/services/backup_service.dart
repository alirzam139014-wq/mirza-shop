/// سرویس نسخه پشتیبان (Backup)
/// مسئول ساخت، ذخیره و بازیابی نسخه‌های پشتیبان
/// اطلاعات بکاپ: محصوالت، دسته‌بندی‌ها، تنظیمات ظاهری، مسیر تصاویر
library;

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';

/// اطلاعات یک نسخه پشتیبان
class BackupInfo {
  final String filePath;
  final String appVersion;
  final int productCount;
  final DateTime createdAt;

  const BackupInfo({
    required this.filePath,
    required this.appVersion,
    required this.productCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'filePath': filePath,
        'appVersion': appVersion,
        'productCount': productCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BackupInfo.fromMap(Map<String, dynamic> map) => BackupInfo(
        filePath: map['filePath'] as String,
        appVersion: map['appVersion'] as String,
        productCount: map['productCount'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// دریافت مسیر پوشه بکاپ
  Future<String> _getBackupDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, AppConstants.folderBackup));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  /// ساخت نسخه پشتیبان
  /// خروجی: مسیر فایل بکاپ
  Future<BackupInfo> createBackup() async {
    final db = await _dbHelper.database;
    final backupDir = await _getBackupDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(backupDir, 'backup_$timestamp.json');

    // خواندن تمام داده‌ها
    final products = await db.query(AppConstants.tableProducts);
    final categories = await db.query(AppConstants.tableCategories);
    final settings = await db.query(AppConstants.tableSettings);

    // ساخت JSON بکاپ
    final backupData = {
      'appVersion': AppConstants.appVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'productCount': products.length,
      'data': {
        'products': products,
        'categories': categories,
        'settings': settings,
      },
    };

    // نوشتن فایل
    final file = File(filePath);
    await file.writeAsString(
      jsonEncode(backupData),
      flush: true,
    );

    // ثبت در جدول بکاپ‌ها
    final backupInfo = BackupInfo(
      filePath: filePath,
      appVersion: AppConstants.appVersion,
      productCount: products.length,
      createdAt: DateTime.now(),
    );

    await db.insert(AppConstants.tableBackups, backupInfo.toMap());

    return backupInfo;
  }

  /// بازیابی از نسخه پشتیبان
  /// ⚠️ اطلاعات فعلی جایگزین خواهند شد
  Future<void> restoreBackup(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('فایل بکاپ یافت نشد');
    }

    try {
      final content = await file.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;
      final data = backupData['data'] as Map<String, dynamic>;

      final db = await _dbHelper.database;

      // شروع تراکنش
      await db.transaction((txn) async {
        // پاک کردن داده‌های فعلی
        await txn.delete(AppConstants.tableProducts);
        await txn.delete(AppConstants.tableCategories);
        await txn.delete(AppConstants.tableSettings);

        // بازیابی دسته‌بندی‌ها
        final categories =
            (data['categories'] as List).cast<Map<String, dynamic>>();
        for (final cat in categories) {
          await txn.insert(AppConstants.tableCategories, cat);
        }

        // بازیابی محصوالت
        final products =
            (data['products'] as List).cast<Map<String, dynamic>>();
        for (final product in products) {
          await txn.insert(AppConstants.tableProducts, product);
        }

        // بازیابی تنظیمات
        final settings =
            (data['settings'] as List).cast<Map<String, dynamic>>();
        for (final setting in settings) {
          await txn.insert(AppConstants.tableSettings, setting);
        }
      });
    } catch (e) {
      throw Exception('بازیابی انجام نشد. فایل معتبر نیست.');
    }
  }

  /// دریافت لیست بکاپ‌های موجود
  Future<List<BackupInfo>> getBackups() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableBackups,
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => BackupInfo.fromMap(m)).toList();
  }

  /// حذف یک بکاپ
  Future<void> deleteBackup(int index) async {
    final db = await _dbHelper.database;
    final backups = await getBackups();
    if (index >= 0 && index < backups.length) {
      final backup = backups[index];
      // حذف فایل
      final file = File(backup.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      // حذف از دیتابیس
      await db.delete(
        AppConstants.tableBackups,
        where: 'filePath = ?',
        whereArgs: [backup.filePath],
      );
    }
  }
}
