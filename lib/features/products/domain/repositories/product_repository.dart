/// اینترفیس ریپازیتوری محصوالت (لایه Domain)
/// قرارداد بین لایه Domain و Data
/// UseCase ها فقط با این اینترفیس کار می‌کنند، نه با پیاده‌سازی واقعی
library;

import '../entities/product_entity.dart';

abstract class ProductRepository {
  /// دریافت محصوالت با صفحه‌بندی
  Future<List<ProductEntity>> getProducts({int page = 0});

  /// دریافت یک محصول بر اساس شناسه
  Future<ProductEntity?> getProductById(int id);

  /// جستجوی هوشمند محصول
  Future<List<ProductEntity>> searchProducts(String query);

  /// جستجو بر اساس بارکد (دقیق)
  Future<ProductEntity?> getProductByBarcode(String barcode);

  /// دریافت محصوالت یک دسته‌بندی
  Future<List<ProductEntity>> getProductsByCategory(int categoryId);

  /// افزودن محصول جدید
  Future<int> addProduct(ProductEntity product);

  /// ویرایش محصول
  Future<int> updateProduct(ProductEntity product);

  /// حذف محصول
  Future<int> deleteProduct(int id);

  /// تعداد کل محصوالت
  Future<int> getProductCount();

  /// تاریخچه قیمت محصول
  Future<List<Map<String, dynamic>>> getPriceHistory(int productId);
}
