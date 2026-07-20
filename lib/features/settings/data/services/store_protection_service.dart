/// حالت محافظ فروشگاه (Store Protection Mode)
/// وقتی فعال باشد:
/// - حذف گروهی غیرفعال می‌شود
/// - تغییرات مهم رمز می‌خواهند
/// - بکاپ خودکار فعال می‌شود
/// - هیچ اطلاعاتی بدون اجازه واضح کاربر از بین نمی‌رود
///
/// قانون طلایی Mirza Shop:
/// هر تغییر مهم باید: ۱. ثبت شود  ۲. قابل بازگشت باشد  ۳. نسخه پشتیبان داشته باشد
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider حالت محافظ فروشگاه
final storeProtectionProvider =
    ChangeNotifierProvider<StoreProtectionManager>(
        (ref) => StoreProtectionManager());

class StoreProtectionManager extends ChangeNotifier {
  bool _isEnabled = false;
  bool _autoBackup = true;
  bool _requirePinForDelete = true;
  bool _blockBulkDelete = true;

  bool get isEnabled => _isEnabled;
  bool get autoBackup => _autoBackup;
  bool get requirePinForDelete => _requirePinForDelete;
  bool get blockBulkDelete => _blockBulkDelete;

  /// بارگذاری تنظیمات
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('store_protection_enabled') ?? false;
    _autoBackup = prefs.getBool('store_protection_auto_backup') ?? true;
    _requirePinForDelete =
        prefs.getBool('store_protection_pin_delete') ?? true;
    _blockBulkDelete =
        prefs.getBool('store_protection_block_bulk') ?? true;
    notifyListeners();
  }

  /// فعال/غیرفعال کردن حالت محافظ
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('store_protection_enabled', enabled);
    notifyListeners();
  }

  /// فعال/غیرفعال کردن بکاپ خودکار
  Future<void> setAutoBackup(bool enabled) async {
    _autoBackup = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('store_protection_auto_backup', enabled);
    notifyListeners();
  }

  /// فعال/غیرفعال کردن پین برای حذف
  Future<void> setRequirePinForDelete(bool enabled) async {
    _requirePinForDelete = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('store_protection_pin_delete', enabled);
    notifyListeners();
  }

  /// فعال/غیرفعال کردن بلاک حذف گروهی
  Future<void> setBlockBulkDelete(bool enabled) async {
    _blockBulkDelete = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('store_protection_block_bulk', enabled);
    notifyListeners();
  }

  /// آیا این عملیات حذف مجاز است؟
  bool canDelete({bool isBulk = false}) {
    if (!_isEnabled) return true;
    if (isBulk && _blockBulkDelete) return false;
    return true;
  }
}
