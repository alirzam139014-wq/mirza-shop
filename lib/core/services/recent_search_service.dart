/// سرویس جستجوهای اخیر
/// برنامه آخرین جستجوهای کاربر را ذخیره می‌کند
/// تا دفعه بعد سریع‌تر پیدا شوند
/// نمایش پیشنهاد هنگام تایپ
library;

import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchService {
  static const String _key = 'recent_searches';
  static const int _maxItems = 10;

  /// دریافت جستجوهای اخیر
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// افزودن جستجوی جدید
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    var searches = prefs.getStringList(_key) ?? [];

    // حذف تکراری
    searches.remove(query.trim());

    // افزودن به ابتدا
    searches.insert(0, query.trim());

    // محدود کردن تعداد
    if (searches.length > _maxItems) {
      searches = searches.sublist(0, _maxItems);
    }

    await prefs.setStringList(_key, searches);
  }

  /// حذف یک جستجو
  Future<void> removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    var searches = prefs.getStringList(_key) ?? [];
    searches.remove(query);
    await prefs.setStringList(_key, searches);
  }

  /// پاک کردن تمام جستجوهای اخیر
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// پیشنهاد بر اساس تایپ فعلی
  Future<List<String>> getSuggestions(String prefix) async {
    if (prefix.trim().isEmpty) return [];
    final searches = await getRecentSearches();
    return searches
        .where((s) => s.startsWith(prefix.trim()))
        .take(5)
        .toList();
  }
}
