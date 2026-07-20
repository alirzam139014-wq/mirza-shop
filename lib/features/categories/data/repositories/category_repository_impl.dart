/// ریپازیتوری دسته‌بندی‌ها
library;

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl({required CategoryLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await _localDataSource.getCategories();
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    return await _localDataSource.getCategoryById(id);
  }

  @override
  Future<int> addCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    return await _localDataSource.insertCategory(model);
  }

  @override
  Future<int> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    return await _localDataSource.updateCategory(model);
  }

  @override
  Future<int> deleteCategory(int id) async {
    return await _localDataSource.deleteCategory(id);
  }
}
