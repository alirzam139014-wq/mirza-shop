/// سرویس گزارش خطا (Logging Service)
/// ثبت خطاهای مهم برای رفع مشکل در آینده
/// اطلاعات ثبت‌شده: زمان خطا، بخش مشکل‌دار، نوع خطا
/// برنامه نباید با هیچ خطایی بسته شود
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// سطح لاگ
enum LogLevel {
  info,    // اطلاعاتی
  warning, // هشدار
  error,   // خطا
  fatal,   // خطای بحرانی
}

/// یک رکورد لاگ
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String section;
  final String message;
  final String? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.section,
    required this.message,
    this.stackTrace,
  });

  String toLine() {
    final levelStr = level.name.toUpperCase().padRight(7);
    final time =
        '${timestamp.year}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    return '[$levelStr] $time [$section] $message';
  }
}

/// سرویس لاگ (Singleton)
class LoggingService {
  static final LoggingService instance = LoggingService._init();
  LoggingService._init();

  final List<LogEntry> _recentLogs = [];
  static const int _maxRecentLogs = 100;
  String? _logFilePath;

  /// مقداردهی اولیه
  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory(p.join(dir.path, 'logs'));
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      _logFilePath = p.join(
        logsDir.path,
        'mirza_shop_${DateTime.now().millisecondsSinceEpoch}.log',
      );
    } catch (_) {
      // اگر فایل لاگ ساخته نشد، فقط در حافظه نگه می‌داریم
    }
  }

  /// ثبت لاگ
  Future<void> log(
    LogLevel level,
    String section,
    String message, {
    String? stackTrace,
  }) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      section: section,
      message: message,
      stackTrace: stackTrace,
    );

    // افزودن به لیست اخیر
    _recentLogs.add(entry);
    if (_recentLogs.length > _maxRecentLogs) {
      _recentLogs.removeAt(0);
    }

    // نوشتن در فایل
    if (_logFilePath != null) {
      try {
        final file = File(_logFilePath!);
        await file.writeAsString(
          '${entry.toLine()}\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (_) {
        // خطا نادیده گرفته می‌شود
      }
    }
  }

  /// ثبت اطلاعات
  Future<void> info(String section, String message) =>
      log(LogLevel.info, section, message);

  /// ثبت هشدار
  Future<void> warning(String section, String message) =>
      log(LogLevel.warning, section, message);

  /// ثبت خطا
  Future<void> error(String section, String message, {String? stackTrace}) =>
      log(LogLevel.error, section, message, stackTrace: stackTrace);

  /// ثبت خطای بحرانی
  Future<void> fatal(String section, String message, {String? stackTrace}) =>
      log(LogLevel.fatal, section, message, stackTrace: stackTrace);

  /// دریافت لاگ‌های اخیر
  List<LogEntry> getRecentLogs() => List.unmodifiable(_recentLogs);

  /// پاک کردن لاگ‌ها
  Future<void> clearLogs() async {
    _recentLogs.clear();
    if (_logFilePath != null) {
      try {
        final file = File(_logFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }
}
