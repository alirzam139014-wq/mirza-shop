/// Provider های محصوالت (لایه Presentation)
/// مدیریت State محصوالت با استفاده از Riverpod
/// این Provider ها پلی بین UI و UseCase ها هستند
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/product_usecases.dart';

// ─── Provider های DataSource ─────────────────────────────
final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSource();
});

final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSource();
});

// ─── Provider های Repository ─────────────────────────────
final productRepositoryProvider = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(
    localDataSource: ref.watch(productLocalDataSourceProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepositoryImpl>((ref) {
  return CategoryRepositoryImpl(
    localDataSource: ref.watch(categoryLocalDataSourceProvider),
  );
});

// ─── Provider های UseCase ────────────────────────────────
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

final getProductByBarcodeUseCaseProvider =
    Provider<GetProductByBarcodeUseCase>((ref) {
  return GetProductByBarcodeUseCase(ref.watch(productRepositoryProvider));
});

final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  return AddProductUseCase(ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(ref.watch(productRepositoryProvider));
});

// ─── Provider لیست محصوالت ───────────────────────────────
/// State محصوالت شامل: لیست، وضعیت بارگذاری، و خطا
class ProductsState {
  final List<ProductEntity> products;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  ProductsState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Notifier مدیریت State محصوالت
class ProductsNotifier extends StateNotifier<ProductsState> {
  final GetProductsUseCase _getProducts;
  final SearchProductsUseCase _searchProducts;
  final AddProductUseCase _addProduct;
  final UpdateProductUseCase _updateProduct;
  final DeleteProductUseCase _deleteProduct;

  int _currentPage = 0;

  ProductsNotifier({
    required GetProductsUseCase getProducts,
    required SearchProductsUseCase searchProducts,
    required AddProductUseCase addProduct,
    required UpdateProductUseCase updateProduct,
    required DeleteProductUseCase deleteProduct,
  })  : _getProducts = getProducts,
        _searchProducts = searchProducts,
        _addProduct = addProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        super(const ProductsState());

  /// بارگذاری محصوالت (صفحه اول)
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    _currentPage = 0;
    try {
      final products = await _getProducts(page: 0);
      state = state.copyWith(
        products: products,
        isLoading: false,
        hasMore: products.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// بارگذاری صفحه بعدی (برای اسکرول بی‌نهایت)
  Future<void> loadMoreProducts() async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    _currentPage++;
    try {
      final moreProducts = await _getProducts(page: _currentPage);
      state = state.copyWith(
        products: [...state.products, ...moreProducts],
        isLoading: false,
        hasMore: moreProducts.length >= 50,
      );
    } catch (e) {
      _currentPage--;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// جستجوی محصوالت
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      loadProducts();
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _searchProducts(query);
      state = state.copyWith(
        products: results,
        isLoading: false,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// افزودن محصول جدید
  Future<bool> addProduct(ProductEntity product) async {
    try {
      await _addProduct(product);
      await loadProducts(); // تازه‌سازی لیست
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// ویرایش محصول
  Future<bool> updateProduct(ProductEntity product) async {
    try {
      await _updateProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// حذف محصول
  Future<bool> deleteProduct(int id) async {
    try {
      await _deleteProduct(id);
      // حذف از لیست محلی بدون بارگذاری مجدد
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Provider اصلی محصوالت
final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(
    getProducts: ref.watch(getProductsUseCaseProvider),
    searchProducts: ref.watch(searchProductsUseCaseProvider),
    addProduct: ref.watch(addProductUseCaseProvider),
    updateProduct: ref.watch(updateProductUseCaseProvider),
    deleteProduct: ref.watch(deleteProductUseCaseProvider),
  );
});

// ─── Provider دسته‌بندی‌ها ───────────────────────────────
final categoriesProvider =
    FutureProvider<List<CategoryEntity>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategories();
});
