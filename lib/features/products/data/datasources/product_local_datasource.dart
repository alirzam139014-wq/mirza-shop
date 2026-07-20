/// منبع داده محلی محصوالت (Local Data Source)
/// مسئول مستقیم ارتباط با دیتابیس SQLite برای عملیات CRUD محصوالت
/// این کلاس پایین‌ترین لایه دسترسی به داده است
library;

import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/product_model.dart';

class ProductLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// دریافت تمام محصوالت با صفحه‌بندی
  Future<List<ProductModel>> getProducts({
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      orderBy: 'createdAt DESC',
      limit: pageSize,
      offset: page * pageSize,
    );
    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  /// دریافت یک محصول بر اساس شناسه
  Future<ProductModel?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  /// جستجوی محصول بر اساس نام، بارکد یا کد محصول
  /// جستجو به صورت هوشمند و بخشی (LIKE) انجام می‌شود
  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final searchTerm = '%$query%';
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'name LIKE ? OR barcode LIKE ? OR productCode LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm],
      orderBy: 'name ASC',
      limit: 50,
    );
    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  /// جستجوی محصول بر اساس بارکد (دقیق)
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  /// دریافت محصوالت یک دسته‌بندی خاص
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  /// افزودن محصول جدید
  /// اگر بارکد تکراری باشد، خطا برمی‌گرداند
  Future<int> insertProduct(ProductModel product) async {
    final db = await _dbHelper.database;

    // بررسی تکراری نبودن بارکد
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      final existing = await getProductByBarcode(product.barcode!);
      if (existing != null) {
        throw Exception('بارکد تکراری است! این بارکد قبلاً ثبت شده است.');
      }
    }

    return await db.insert(AppConstants.tableProducts, product.toMap());
  }

  /// ویرایش محصول موجود
  /// اگر قیمت تغییر کرده باشد، در تاریخچه قیمت ثبت می‌شود
  Future<int> updateProduct(ProductModel product) async {
    final db = await _dbHelper.database;

    // بررسی تغییر قیمت برای ثبت در تاریخچه
    final oldProduct = await getProductById(product.id!);
    if (oldProduct != null && oldProduct.price != product.price) {
      await _savePriceHistory(db, product.id!, oldProduct.price, product.price);
    }

    return await db.update(
      AppConstants.tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// حذف محصول
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// دریافت تعداد کل محصوالت
  Future<int> getProductCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableProducts}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// ذخیره تغییر قیمت در تاریخچه
  Future<void> _savePriceHistory(
    Database db,
    int productId,
    double oldPrice,
    double newPrice,
  ) async {
    await db.insert(AppConstants.tablePriceHistory, {
      'productId': productId,
      'oldPrice': oldPrice,
      'newPrice': newPrice,
      'changedAt': DateTime.now().toIso8601String(),
    });
  }

  /// دریافت تاریخچه قیمت یک محصول
  Future<List<Map<String, dynamic>>> getPriceHistory(int productId) async {
    final db = await _dbHelper.database;
    return await db.query(
      AppConstants.tablePriceHistory,
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'changedAt DESC',
    );
  }
}
