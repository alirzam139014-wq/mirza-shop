/// Provider های دسته‌بندی‌ها
/// مدیریت State دسته‌بندی‌ها با Riverpod
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category_entity.dart';

// ─── Provider های DataSource ─────────────────────────────
final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSource();
});

// ─── Provider های Repository ─────────────────────────────
final categoryRepositoryProvider = Provider<CategoryRepositoryImpl>((ref) {
  return CategoryRepositoryImpl(
    localDataSource: ref.watch(categoryLocalDataSourceProvider),
  );
});

// ─── Provider لیست دسته‌بندی‌ها ─────────────────────────
final categoriesProvider =
    FutureProvider<List<CategoryEntity>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategories();
});
