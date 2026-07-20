/// UseCase های محصول (لایه Domain)
/// هر UseCase مسئول یک عملیات خاص کسب‌وکاری است
/// این کلاس‌ها منطق اصلی برنامه را بدون وابستگی به UI یا دیتابیس پیاده‌سازی می‌کنند
library;

import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// دریافت لیست محصوالت
class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  Future<List<ProductEntity>> call({int page = 0}) {
    return _repository.getProducts(page: page);
  }
}

/// دریافت یک محصول بر اساس شناسه
class GetProductByIdUseCase {
  final ProductRepository _repository;

  GetProductByIdUseCase(this._repository);

  Future<ProductEntity?> call(int id) {
    return _repository.getProductById(id);
  }
}

/// جستجوی هوشمند محصول
/// بر اساس نام، بارکد یا کد محصول جستجو می‌کند
class SearchProductsUseCase {
  final ProductRepository _repository;

  SearchProductsUseCase(this._repository);

  Future<List<ProductEntity>> call(String query) {
    if (query.trim().isEmpty) return Future.value([]);
    return _repository.searchProducts(query.trim());
  }
}

/// جستجوی محصول بر اساس بارکد (برای اسکنر)
class GetProductByBarcodeUseCase {
  final ProductRepository _repository;

  GetProductByBarcodeUseCase(this._repository);

  Future<ProductEntity?> call(String barcode) {
    return _repository.getProductByBarcode(barcode);
  }
}

/// افزودن محصول جدید
/// ابتدا اعتبارسنجی انجام می‌شود
class AddProductUseCase {
  final ProductRepository _repository;

  AddProductUseCase(this._repository);

  Future<int> call(ProductEntity product) async {
    // اعتبارسنجی محصول
    final error = product.validate();
    if (error != null) {
      throw Exception(error);
    }
    return _repository.addProduct(product);
  }
}

/// ویرایش محصول موجود
class UpdateProductUseCase {
  final ProductRepository _repository;

  UpdateProductUseCase(this._repository);

  Future<int> call(ProductEntity product) async {
    final error = product.validate();
    if (error != null) {
      throw Exception(error);
    }
    // به‌روزرسانی زمان ویرایش
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    return _repository.updateProduct(updatedProduct);
  }
}

/// حذف محصول
class DeleteProductUseCase {
  final ProductRepository _repository;

  DeleteProductUseCase(this._repository);

  Future<int> call(int id) {
    return _repository.deleteProduct(id);
  }
}

/// دریافت تعداد کل محصوالت
class GetProductCountUseCase {
  final ProductRepository _repository;

  GetProductCountUseCase(this._repository);

  Future<int> call() {
    return _repository.getProductCount();
  }
}
