/// مدل محصول (Model) - لایه Data
/// این کلاس مسئول تبدیل داده بین دیتابیس و Entity است
/// شامل متدهای fromJson و toJson برای ارتباط با SQLite
library;

import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    required super.name,
    required super.price,
    super.barcode,
    super.productCode,
    super.categoryId,
    super.description,
    super.imagePath,
    required super.createdAt,
    required super.updatedAt,
  });

  /// تبدیل از Map دیتابیس به مدل
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      barcode: map['barcode'] as String?,
      productCode: map['productCode'] as String?,
      categoryId: map['categoryId'] as int?,
      description: map['description'] as String?,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// تبدیل مدل به Map برای ذخیره در دیتابیس
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'barcode': barcode,
      'productCode': productCode,
      'categoryId': categoryId,
      'description': description,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// تبدیل Entity به Model
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      barcode: entity.barcode,
      productCode: entity.productCode,
      categoryId: entity.categoryId,
      description: entity.description,
      imagePath: entity.imagePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
