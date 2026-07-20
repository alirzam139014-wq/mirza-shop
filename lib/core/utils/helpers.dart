/// توابع کمکی سراسری اپلیکیشن Mirza Shop
/// شامل: فرمت قیمت، فرمت تاریخ، مدیریت فایل، اعتبارسنجی
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

class AppHelpers {
  AppHelpers._();

  static const _uuid = Uuid();

  /// فرمت کردن قیمت به تومان با جداکننده هزارگان
  static String formatPrice(double price) {
    if (price == 0) return 'رایگان';
    final formatted = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write('٬');
      }
      buffer.write(formatted[i]);
    }
    return '$buffer تومان';
  }

  /// فرمت کردن تاریخ به شمسی (ساده)
  static String formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// فرمت کردن تاریخ و زمان
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// تولید شناسه یکتا
  static String generateId() => _uuid.v4();

  /// دریافت مسیر پوشه تصاویر محصوالت
  static Future<String> getImagesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir =
        Directory(p.join(dir.path, AppConstants.folderImages));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir.path;
  }

  /// ذخیره تصویر محصول و برگرداندن مسیر
  static Future<String?> saveProductImage(String sourcePath) async {
    try {
      final imagesDir = await getImagesDir();
      final fileName = '${_uuid.v4()}.jpg';
      final destPath = p.join(imagesDir, fileName);
      final sourceFile = File(sourcePath);
      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      return null;
    }
  }

  /// حذف تصویر محصول
  static Future<void> deleteProductImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // خطا نادیده گرفته می‌شود
    }
  }

  /// اعتبارسنجی بارکد (فقط عدد باشد)
  static bool isValidBarcode(String barcode) {
    return RegExp(r'^\d{4,20}$').hasMatch(barcode);
  }

  /// اعتبارسنجی قیمت
  static bool isValidPrice(String price) {
    final value = double.tryParse(price);
    return value != null && value >= 0;
  }

  /// نمایش SnackBar موفقیت
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF4CAF50), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// نمایش SnackBar خطا
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFEF5350), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// نمایش دیالوگ تأیید
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأیید',
    String cancelText = 'انصراف',
    Color confirmColor = const Color(0xFFEF5350),
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(message,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText,
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
