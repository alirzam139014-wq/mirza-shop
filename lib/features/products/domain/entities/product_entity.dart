/// موجودیت محصول (Entity)
/// این کلاس نماینده یک محصول در لایه Domain است
/// بدون وابستگی به دیتابیس یا UI - فقط منطق خالص کسب‌وکار
class ProductEntity {
  final int? id;
  final String name;
  final double price;
  final String? barcode;
  final String? productCode;
  final int? categoryId;
  final String? description;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    this.id,
    required this.name,
    required this.price,
    this.barcode,
    this.productCode,
    this.categoryId,
    this.description,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// کپی با تغییرات (برای ویرایش محصول)
  ProductEntity copyWith({
    int? id,
    String? name,
    double? price,
    String? barcode,
    String? productCode,
    int? categoryId,
    String? description,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
      productCode: productCode ?? this.productCode,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// بررسی اعتبار محصول قبل از ذخیره
  String? validate() {
    if (name.trim().isEmpty) {
      return 'نام محصول نباید خالی باشد';
    }
    if (price < 0) {
      return 'قیمت باید عدد معتبر باشد';
    }
    return null; // معتبر است
  }
}
