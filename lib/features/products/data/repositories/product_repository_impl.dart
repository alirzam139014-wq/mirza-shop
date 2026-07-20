/// ریپازیتوری محصوالت (لایه Data)
/// پلی بین لایه Domain و DataSource
/// مسئول هماهنگی بین منابع داده مختلف و ارائه داده تمیز به UseCase ها
library;

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl({required ProductLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<ProductEntity>> getProducts({int page = 0}) async {
    final models = await _localDataSource.getProducts(page: page);
    return models; // ProductModel خودش ProductEntity را extend می‌کند
  }

  @override
  Future<ProductEntity?> getProductById(int id) async {
    return await _localDataSource.getProductById(id);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    return await _localDataSource.searchProducts(query);
  }

  @override
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    return await _localDataSource.getProductByBarcode(barcode);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(int categoryId) async {
    return await _localDataSource.getProductsByCategory(categoryId);
  }

  @override
  Future<int> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    return await _localDataSource.insertProduct(model);
  }

  @override
  Future<int> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    return await _localDataSource.updateProduct(model);
  }

  @override
  Future<int> deleteProduct(int id) async {
    return await _localDataSource.deleteProduct(id);
  }

  @override
  Future<int> getProductCount() async {
    return await _localDataSource.getProductCount();
  }

  @override
  Future<List<Map<String, dynamic>>> getPriceHistory(int productId) async {
    return await _localDataSource.getPriceHistory(productId);
  }
}
