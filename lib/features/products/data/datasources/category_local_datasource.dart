/// منبع داده محلی دسته‌بندی‌ها
/// مسئول عملیات CRUD دسته‌بندی‌ها در دیتابیس SQLite
library;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// دریافت تمام دسته‌بندی‌ها
  Future<List<CategoryModel>> getCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableCategories,
      orderBy: 'name ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// دریافت یک دسته‌بندی بر اساس شناسه
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  /// افزودن دسته‌بندی جدید
  Future<int> insertCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.tableCategories, category.toMap());
  }

  /// ویرایش دسته‌بندی
  Future<int> updateCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// حذف دسته‌بندی
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
