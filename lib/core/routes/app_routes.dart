/// مسیرهای (Routes) اپلیکیشن Mirza Shop
/// مدیریت ناوبری بین صفحات با انیمیشن‌های مناسب
library;

import 'package:flutter/material.dart';
import '../../animations/app_animations.dart';
import '../../features/products/presentation/screens/splash_screen.dart';
import '../../features/products/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/settings_screen.dart';
import '../../features/products/domain/entities/product_entity.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';

class AppRoutes {
  AppRoutes._();

  // نام مسیرها
  static const String splash = '/';
  static const String home = '/home';
  static const String addProduct = '/add-product';
  static const String productDetail = '/product-detail';
  static const String settings = '/settings';
  static const String scanner = '/scanner';

  /// ساخت مسیر بر اساس نام
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return PageTransitions.fadeSlideRoute(const SplashScreen());

      case home:
        return PageTransitions.fadeSlideRoute(const HomeScreen());

      case addProduct:
        final product = routeSettings.arguments as ProductEntity?;
        return PageTransitions.slideUpRoute(
          AddProductScreen(existingProduct: product),
        );

      case productDetail:
        final product = routeSettings.arguments as ProductEntity;
        return PageTransitions.zoomRoute(
          ProductDetailScreen(product: product),
        );

      case settings:
        return PageTransitions.fadeSlideRoute(const SettingsScreen());

      case scanner:
        final returnOnly = routeSettings.arguments as bool? ?? false;
        return PageTransitions.slideUpRoute(
          ScannerScreen(returnBarcodeOnly: returnOnly),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('صفحه یافت نشد')),
          ),
        );
    }
  }
}
