/// لایوت مخصوص نسخه ویندوز (Desktop Layout)
/// استفاده از فضای بزرگ صفحه:
/// - سمت چپ: لیست محصوالت
/// - وسط: جستجو و دسته‌بندی‌ها
/// - سمت راست: نمایش جزئیات محصول
/// همچنین شامل حالت صندوق (Cashier Mode) و اتصال گوشی
/// میانبرهای کیبورد: Ctrl+F جستجو، F2 ویرایش، F3 اسکن، Delete حذف
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/search_bar_widget.dart';
import 'add_product_screen.dart';
import 'cashier_mode_screen.dart';
import 'settings_screen.dart';

class DesktopHomeScreen extends ConsumerStatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  ConsumerState<DesktopHomeScreen> createState() =>
      _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends ConsumerState<DesktopHomeScreen> {
  ProductEntity? _selectedProduct;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isCashierMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// مدیریت میانبرهای کیبورد
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Ctrl+F → فوکوس روی جستجو
      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyF) {
        _searchFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      // F3 → اسکن بارکد
      if (event.logicalKey == LogicalKeyboardKey.f3) {
        // TODO: باز کردن اسکنر
        return KeyEventResult.handled;
      }
      // F2 → ویرایش محصول انتخاب‌شده
      if (event.logicalKey == LogicalKeyboardKey.f2 &&
          _selectedProduct != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                AddProductScreen(existingProduct: _selectedProduct),
          ),
        );
        return KeyEventResult.handled;
      }
      // Delete → حذف با تأیید
      if (event.logicalKey == LogicalKeyboardKey.delete &&
          _selectedProduct != null) {
        _confirmDelete();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _confirmDelete() {
    if (_selectedProduct == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف محصول',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'آیا مطمئن هستید که «${_selectedProduct!.name}» حذف شود؟',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(productsProvider.notifier)
                  .deleteProduct(_selectedProduct!.id!);
              setState(() => _selectedProduct = null);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
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

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    // اگر حالت صندوق فعال است
    if (_isCashierMode) {
      return const CashierModeScreen();
    }

    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: themeManager.backgroundColor,
        body: Row(
          children: [
            // ─── پنل سمت راست: لیست محصوالت ───────────────
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // هدر
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.storefront_rounded,
                            color: themeManager.neonColor, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'Mirza Shop',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // دکمه حالت صندوق
                        IconButton(
                          onPressed: () =>
                              setState(() => _isCashierMode = true),
                          icon: const Icon(Icons.point_of_sale_rounded,
                              color: Colors.white70),
                          tooltip: 'حالت صندوق',
                        ),
                        // دکمه تنظیمات
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          ),
                          icon: const Icon(Icons.settings_rounded,
                              color: Colors.white70),
                          tooltip: 'تنظیمات',
                        ),
                      ],
                    ),
                  ),

                  // نوار جستجو
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SearchBarWidget(
                      onChanged: (query) =>
                          ref.read(productsProvider.notifier).search(query),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // لیست محصوالت
                  Expanded(
                    child: _buildProductList(themeManager),
                  ),
                ],
              ),
            ),

            // ─── جداکننده ──────────────────────────────────
            Container(
              width: 1,
              color: Colors.white.withOpacity(0.08),
            ),

            // ─── پنل سمت چپ: جزئیات محصول ──────────────────
            Expanded(
              flex: 2,
              child: _selectedProduct != null
                  ? _buildProductDetail(themeManager)
                  : _buildEmptyDetail(themeManager),
            ),
          ],
        ),

        // دکمه افزودن محصول
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          ),
          backgroundColor: themeManager.neonColor,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add_rounded),
          label: const Text('محصول جدید'),
        ),
      ),
    );
  }

  /// لیست محصوالت (پنل راست)
  Widget _buildProductList(ThemeManager themeManager) {
    final productsState = ref.watch(productsProvider);

    if (productsState.isLoading && productsState.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productsState.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 12),
            Text(
              'محصولی یافت نشد',
              style: TextStyle(color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: productsState.products.length,
      itemBuilder: (context, index) {
        final product = productsState.products[index];
        final isSelected = _selectedProduct?.id == product.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedProduct = product),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? themeManager.neonColor.withOpacity(0.1)
                  : themeManager.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? themeManager.neonColor.withOpacity(0.4)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                // آیکون
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeManager.neonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: themeManager.neonColor.withOpacity(0.6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product.barcode ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatPrice(product.price),
                  style: TextStyle(
                    color: themeManager.neonColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// جزئیات محصول (پنل چپ)
  Widget _buildProductDetail(ThemeManager themeManager) {
    final product = _selectedProduct!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نام
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // قیمت بزرگ
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: themeManager.neonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: themeManager.neonColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              _formatPrice(product.price),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeManager.neonColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // اطلاعات
          _DetailRow(label: 'بارکد', value: product.barcode ?? '—'),
          _DetailRow(label: 'کد محصول', value: product.productCode ?? '—'),
          _DetailRow(
            label: 'تاریخ ثبت',
            value:
                '${product.createdAt.year}/${product.createdAt.month}/${product.createdAt.day}',
          ),
          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'توضیحات:',
              style:
                  TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              product.description!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],

          const Spacer(),

          // دکمه‌ها
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddProductScreen(existingProduct: product),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('ویرایش (F2)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeManager.neonColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: const Text('حذف (Del)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFEF5350).withOpacity(0.15),
                    foregroundColor: const Color(0xFFEF5350),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFEF5350)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// حالت خالی پنل جزئیات
  Widget _buildEmptyDetail(ThemeManager themeManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 56,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 12),
          Text(
            'یک محصول را انتخاب کنید',
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return 'رایگان';
    final formatted = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) buffer.write('٬');
      buffer.write(formatted[i]);
    }
    return '$buffer تومان';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
