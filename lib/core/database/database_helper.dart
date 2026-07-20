/// مدیریت دیتابیس SQLite اپلیکیشن Mirza Shop
/// این کلاس مسئول ساخت، باز کردن و مدیریت دیتابیس محلی است
/// از الگوی Singleton استفاده شده تا فقط یک نمونه از دیتابیس وجود داشته باشد
library;

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  // ─── Singleton ─────────────────────────────────────────
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// دریافت نمونه دیتابیس (اگر ساخته نشده باشد، ساخته می‌شود)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// مقداردهی اولیه دیتابیس
  Future<Database> _initDatabase() async {
    // برای ویندوز از FFI استفاده می‌شود
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// ساخت جداول دیتابیس هنگام اولین اجرا
  Future<void> _onCreate(Database db, int version) async {
    // ─── جدول دسته‌بندی‌ها ─────────────────────────────
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        color TEXT DEFAULT '#00E5FF',
        createdAt TEXT NOT NULL
      )
    ''');

    // ─── جدول محصوالت ──────────────────────────────────
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProducts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        barcode TEXT,
        productCode TEXT,
        categoryId INTEGER,
        description TEXT,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES ${AppConstants.tableCategories}(id) ON DELETE SET NULL
      )
    ''');

    // ─── ایندکس‌ها برای جستجوی سریع ────────────────────
    await db.execute('''
      CREATE INDEX idx_products_name ON ${AppConstants.tableProducts}(name)
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX idx_products_barcode ON ${AppConstants.tableProducts}(barcode) WHERE barcode IS NOT NULL
    ''');
    await db.execute('''
      CREATE INDEX idx_products_code ON ${AppConstants.tableProducts}(productCode)
    ''');
    await db.execute('''
      CREATE INDEX idx_products_category ON ${AppConstants.tableProducts}(categoryId)
    ''');

    // ─── جدول تنظیمات ──────────────────────────────────
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSettings} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // ─── جدول نسخه‌های پشتیبان ─────────────────────────
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBackups} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filePath TEXT NOT NULL,
        appVersion TEXT NOT NULL,
        productCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // ─── جدول تاریخچه قیمت‌ها ──────────────────────────
    await db.execute('''
      CREATE TABLE ${AppConstants.tablePriceHistory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        oldPrice REAL NOT NULL,
        newPrice REAL NOT NULL,
        changedAt TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES ${AppConstants.tableProducts}(id) ON DELETE CASCADE
      )
    ''');

    // ─── درج دسته‌بندی‌های پیش‌فرض ─────────────────────
    await _insertDefaultCategories(db);
  }

  /// درج دسته‌بندی‌های پیش‌فرض
  Future<void> _insertDefaultCategories(Database db) async {
    final categories = [
      {'name': 'خوراکی', 'icon': '🍕', 'color': '#FF6B6B'},
      {'name': 'لبنیات', 'icon': '🥛', 'color': '#4ECDC4'},
      {'name': 'نوشیدنی', 'icon': '🥤', 'color': '#45B7D1'},
      {'name': 'تنقلات', 'icon': '🍿', 'color': '#96CEB4'},
      {'name': 'لوازم تحریر', 'icon': '✏️', 'color': '#FFEAA7'},
      {'name': 'مواد شوینده', 'icon': '🧴', 'color': '#DDA0DD'},
      {'name': 'بهداشتی', 'icon': '🧼', 'color': '#98D8C8'},
      {'name': 'آرایشی', 'icon': '💄', 'color': '#F7DC6F'},
      {'name': 'کنسرو', 'icon': '🥫', 'color': '#BB8FCE'},
      {'name': 'خشکبار', 'icon': '🥜', 'color': '#D4AC0D'},
      {'name': 'ادویه', 'icon': '🌶️', 'color': '#E74C3C'},
      {'name': 'نوشابه', 'icon': '🧃', 'color': '#2ECC71'},
      {'name': 'آبمیوه', 'icon': '🍊', 'color': '#F39C12'},
      {'name': 'شکلات', 'icon': '🍫', 'color': '#8D6E63'},
      {'name': 'آدامس', 'icon': '🫧', 'color': '#00BCD4'},
      {'name': 'چای', 'icon': '🍵', 'color': '#4CAF50'},
      {'name': 'قهوه', 'icon': '☕', 'color': '#795548'},
      {'name': 'برنج', 'icon': '🍚', 'color': '#FFF9C4'},
      {'name': 'روغن', 'icon': '🫒', 'color': '#CDDC39'},
      {'name': 'قند و شکر', 'icon': '🍬', 'color': '#F8BBD0'},
      {'name': 'ماکارونی', 'icon': '🍝', 'color': '#FFCC02'},
      {'name': 'سایر', 'icon': '📦', 'color': '#90A4AE'},
    ];

    final now = DateTime.now().toIso8601String();
    for (final cat in categories) {
      await db.insert(AppConstants.tableCategories, {
        'name': cat['name'],
        'icon': cat['icon'],
        'color': cat['color'],
        'createdAt': now,
      });
    }
  }

  /// ارتقای دیتابیس هنگام تغییر نسخه
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // در نسخه‌های بعدی، تغییرات دیتابیس اینجا اضافه می‌شود
  }

  /// بستن دیتابیس
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
