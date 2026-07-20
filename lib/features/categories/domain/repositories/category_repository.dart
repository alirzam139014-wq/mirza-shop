/// اینترفیس ریپازیتوری دسته‌بندی‌ها
library;

import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryEntity?> getCategoryById(int id);
  Future<int> addCategory(CategoryEntity category);
  Future<int> updateCategory(CategoryEntity category);
  Future<int> deleteCategory(int id);
}
