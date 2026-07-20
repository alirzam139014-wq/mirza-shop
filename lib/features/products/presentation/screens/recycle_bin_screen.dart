/// سطل زباله محصوالت (Recycle Bin)
/// محصوالت حذف‌شده فوراً نابود نمی‌شوند، ابتدا وارد سطل زباله می‌شوند
/// کاربر می‌تواند بازیابی کند یا برای همیشه حذف کند
/// جلوگیری از حذف اشتباه اطالعات فروشگاه
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/product_entity.dart';

/// مدل محصول حذف‌شده در سطل زباله
class DeletedProduct {
  final ProductEntity product;
  final DateTime deletedAt;

  const DeletedProduct({
    required this.product,
    required this.deletedAt,
  });
}

/// Provider سطل زباله
final recycleBinProvider =
    StateNotifierProvider<RecycleBinNotifier, List<DeletedProduct>>((ref) {
  return RecycleBinNotifier();
});

class RecycleBinNotifier extends StateNotifier<List<DeletedProduct>> {
  RecycleBinNotifier() : super([]);

  /// افزودن محصول به سطل زباله
  void addToBin(ProductEntity product) {
    state = [
      DeletedProduct(product: product, deletedAt: DateTime.now()),
      ...state,
    ];
  }

  /// بازیابی محصول از سطل زباله
  ProductEntity? restore(int index) {
    if (index < 0 || index >= state.length) return null;
    final product = state[index].product;
    state = [...state]..removeAt(index);
    return product;
  }

  /// حذف دائمی یک محصول
  void deletePermanently(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }

  /// خالی کردن سطل زباله
  void emptyBin() {
    state = [];
  }
}

class RecycleBinScreen extends ConsumerWidget {
  const RecycleBinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.watch(themeManagerProvider);
    final deletedProducts = ref.watch(recycleBinProvider);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('سطل زباله'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (deletedProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Color(0xFFEF5350)),
              onPressed: () => _confirmEmptyBin(context, ref),
              tooltip: 'خالی کردن سطل',
            ),
        ],
      ),
      body: deletedProducts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deletedProducts.length,
              itemBuilder: (context, index) {
                final item = deletedProducts[index];
                return _buildDeletedProductCard(
                  context,
                  ref,
                  item,
                  index,
                  themeManager,
                );
              },
            ),
    );
  }

  /// حالت خالی
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            size: 72,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'سطل زباله خالی است',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'محصوالت حذف‌شده اینجا قرار می‌گیرند',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  /// کارت محصول حذف‌شده
  Widget _buildDeletedProductCard(
    BuildContext context,
    WidgetRef ref,
    DeletedProduct item,
    int index,
    ThemeManager themeManager,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: themeManager.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFEF5350).withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // آیکون محصول
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFFEF5350),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // اطلاعات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'حذف: ${AppHelpers.formatDateTime(item.deletedAt)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // دکمه بازیابی
            IconButton(
              onPressed: () {
                ref.read(recycleBinProvider.notifier).restore(index);
                AppHelpers.showSuccess(context, 'محصول بازیابی شد ✓');
              },
              icon: const Icon(
                Icons.restore_rounded,
                color: Color(0xFF4CAF50),
                size: 22,
              ),
              tooltip: 'بازیابی',
            ),

            // دکمه حذف دائمی
            IconButton(
              onPressed: () =>
                  _confirmPermanentDelete(context, ref, index, item),
              icon: Icon(
                Icons.delete_forever_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 22,
              ),
              tooltip: 'حذف دائمی',
            ),
          ],
        ),
      ),
    );
  }

  /// تأیید حذف دائمی
  void _confirmPermanentDelete(
    BuildContext context,
    WidgetRef ref,
    int index,
    DeletedProduct item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف دائمی',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '«${item.product.name}» برای همیشه حذف می‌شود.\nاین عملیات قابل بازگشت نیست.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(recycleBinProvider.notifier)
                  .deletePermanently(index);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف دائمی'),
          ),
        ],
      ),
    );
  }

  /// تأیید خالی کردن سطل
  void _confirmEmptyBin(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('خالی کردن سطل زباله',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'تمام محصوالت سطل زباله برای همیشه حذف می‌شوند.\nاین عملیات قابل بازگشت نیست.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(recycleBinProvider.notifier).emptyBin();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
            ),
            child: const Text('خالی کن'),
          ),
        ],
      ),
    );
  }
}
