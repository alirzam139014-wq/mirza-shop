/// صفحه جزئیات محصول
/// نمایش کامل اطلاعات محصول: تصویر بزرگ، نام، قیمت، بارکد، کد، دسته‌بندی، توضیحات
/// دکمه‌ها: ویرایش، حذف، اشتراک‌گذاری
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import 'add_product_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar با تصویر بزرگ ─────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: themeManager.cardColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // دکمه اشتراک‌گذاری
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _shareProduct(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(themeManager),
            ),
          ),

          // ─── محتوای صفحه ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نام محصول
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // قیمت
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: themeManager.neonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeManager.neonColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _formatPrice(product.price),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeManager.neonColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── اطلاعات تفصیلی ──────────────────────
                  _InfoSection(
                    title: 'اطلاعات محصول',
                    children: [
                      _InfoRow(
                        icon: Icons.qr_code_rounded,
                        label: 'بارکد',
                        value: product.barcode ?? '—',
                        onLongPress: product.barcode != null
                            ? () => _copyToClipboard(
                                context, product.barcode!)
                            : null,
                      ),
                      _InfoRow(
                        icon: Icons.tag_rounded,
                        label: 'کد محصول',
                        value: product.productCode ?? '—',
                      ),
                      _InfoRow(
                        icon: Icons.category_rounded,
                        label: 'دسته‌بندی',
                        value: 'دسته‌بندی محصول',
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'تاریخ ثبت',
                        value: _formatDate(product.createdAt),
                      ),
                      _InfoRow(
                        icon: Icons.update_rounded,
                        label: 'آخرین ویرایش',
                        value: _formatDate(product.updatedAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── توضیحات ─────────────────────────────
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    _InfoSection(
                      title: 'توضیحات',
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            product.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ─── دکمه‌های عملیات ─────────────────────
                  Row(
                    children: [
                      // دکمه ویرایش
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _editProduct(context),
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          label: const Text('ویرایش'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeManager.neonColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // دکمه حذف
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _confirmDelete(context, ref),
                          icon: const Icon(Icons.delete_rounded, size: 20),
                          label: const Text('حذف'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFEF5350).withOpacity(0.15),
                            foregroundColor: const Color(0xFFEF5350),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFEF5350),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// تصویر بزرگ محصول در بالای صفحه
  Widget _buildHeroImage(ThemeManager themeManager) {
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      final file = File(product.imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: double.infinity,
          height: 280,
          fit: BoxFit.cover,
        );
      }
    }

    // تصویر پیش‌فرض
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeManager.neonColor.withOpacity(0.15),
            themeManager.backgroundColor,
          ],
        ),
      ),
      child: Icon(
        Icons.storefront_rounded,
        size: 80,
        color: themeManager.neonColor.withOpacity(0.4),
      ),
    );
  }

  /// فرمت کردن قیمت
  String _formatPrice(double price) {
    if (price == 0) return 'رایگان';
    final formatted = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write('٬');
      }
      buffer.write(formatted[i]);
    }
    return '$buffer تومان';
  }

  /// فرمت کردن تاریخ
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// کپی در کلیپ‌بورد
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('کپی شد ✓'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// اشتراک‌گذاری اطلاعات محصول
  void _shareProduct(BuildContext context) {
    final info = '''
🏪 ${product.name}
💰 ${_formatPrice(product.price)}
📦 بارکد: ${product.barcode ?? '—'}
🏷️ کد: ${product.productCode ?? '—'}
📝 ${product.description ?? ''}

— Mirza Shop
''';
    Clipboard.setData(ClipboardData(text: info));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اطلاعات محصول کپی شد ✓')),
    );
  }

  /// رفتن به صفحه ویرایش
  void _editProduct(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddProductScreen(existingProduct: product),
      ),
    );
  }

  /// تأیید حذف محصول
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف محصول',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید «${product.name}» را حذف کنید؟',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(productsProvider.notifier)
                  .deleteProduct(product.id!);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('محصول حذف شد ✓'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// بخش اطلاعات
class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A).withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// ردیف اطلاعات
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onLongPress;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.4)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
