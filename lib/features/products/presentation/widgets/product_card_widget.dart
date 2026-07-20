/// ویجت کارت محصول
/// نمایش هر محصول به صورت یک کارت زیبا با افکت Glassmorphism
/// شامل: تصویر، نام، قیمت، دسته‌بندی و بارکد
/// با لمس، صفحه جزئیات باز می‌شود
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../domain/entities/product_entity.dart';
import '../screens/product_detail_screen.dart';

class ProductCardWidget extends ConsumerWidget {
  final ProductEntity product;
  final int index;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.watch(themeManagerProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openProductDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // افکت Glassmorphism
              color: themeManager.cardColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // ─── تصویر محصول ───────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductImage(),
                ),

                const SizedBox(width: 14),

                // ─── اطلاعات محصول ─────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نام محصول
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // قیمت
                      Text(
                        _formatPrice(product.price),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: themeManager.neonColor,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // بارکد
                      if (product.barcode != null &&
                          product.barcode!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.barcode!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // ─── دکمه بیشتر ────────────────────────────
                Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ساخت تصویر محصول
  Widget _buildProductImage() {
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      final file = File(product.imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        );
      }
    }

    // تصویر پیش‌فرض
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF00E5FF),
        size: 28,
      ),
    );
  }

  /// فرمت کردن قیمت به تومان
  String _formatPrice(double price) {
    if (price == 0) return 'رایگان';
    final formatted = price.toStringAsFixed(0);
    // افزودن جداکننده هزارگان
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write('٬');
      }
      buffer.write(formatted[i]);
    }
    return '$buffer تومان';
  }

  /// باز کردن صفحه جزئیات محصول
  void _openProductDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }
}
