/// صفحه اصلی (Home Screen)
/// شامل: نوار جستجو، لیست محصوالت، دکمه افزودن، و منوی سه‌نقطه
/// طراحی با سبک Glassmorphism و Material Design 3
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_manager.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/search_bar_widget.dart';
import 'add_product_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  Timer? _searchDebounce;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    // بارگذاری محصوالت هنگام شروع
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// جستجو با تأخیر (Debounce) برای جلوگیری از جستجوی بیش از حد
  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        ref.read(productsProvider.notifier).search(query);
      },
    );
  }

  /// نمایش منوی سه‌نقطه
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionsMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── هدر: عنوان + منو ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // لوگو و نام اپ
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: themeManager.neonColor,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // دکمه منوی سه‌نقطه
                  IconButton(
                    onPressed: _showOptionsMenu,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ─── نوار جستجو ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBarWidget(
                onChanged: _onSearchChanged,
                onSearchActive: (active) =>
                    setState(() => _isSearchActive = active),
              ),
            ),

            const SizedBox(height: 12),

            // ─── لیست محصوالت ─────────────────────────────
            Expanded(
              child: _buildProductsList(productsState, themeManager),
            ),
          ],
        ),
      ),

      // ─── دکمه شناور افزودن محصول (+) ─────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddProduct(),
        backgroundColor: themeManager.neonColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text(
          'محصول جدید',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// ساخت لیست محصوالت بر اساس وضعیت
  Widget _buildProductsList(ProductsState state, ThemeManager themeManager) {
    // حالت بارگذاری اولیه
    if (state.isLoading && state.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00E5FF),
        ),
      );
    }

    // حالت خطا
    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'مشکلی پیش آمد',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(productsProvider.notifier).loadProducts(),
              child: const Text('تلاش دوباره'),
            ),
          ],
        ),
      );
    }

    // حالت خالی (بدون محصول)
    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearchActive
                  ? 'محصولی یافت نشد'
                  : 'هنوز محصولی ثبت نشده',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            if (!_isSearchActive) ...[
              const SizedBox(height: 8),
              Text(
                'با دکمه + اولین محصول خود را اضافه کنید',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // لیست محصوالت
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // بارگذاری بیشتر هنگام رسیدن به انتهای لیست
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          ref.read(productsProvider.notifier).loadMoreProducts();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.products.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          // نشانگر بارگذاری در انتها
          if (index == state.products.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final product = state.products[index];
          return ProductCardWidget(
            product: product,
            index: index,
          );
        },
      ),
    );
  }

  /// رفتن به صفحه افزودن محصول
  void _navigateToAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
  }
}

/// منوی گزینه‌ها (سه‌نقطه)
class _OptionsMenuSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.watch(themeManagerProvider);

    return Container(
      decoration: BoxDecoration(
        color: themeManager.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: themeManager.neonColor.withOpacity(0.3)),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // دستگیره
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // گزینه تنظیمات
          _MenuOption(
            icon: Icons.settings_rounded,
            title: 'تنظیمات',
            subtitle: 'رنگ، فونت، حالت نمایش',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          // گزینه بکاپ
          _MenuOption(
            icon: Icons.backup_rounded,
            title: 'نسخه پشتیبان',
            subtitle: 'ذخیره و بازیابی اطلاعات',
            onTap: () {
              Navigator.pop(context);
              // TODO: رفتن به صفحه بکاپ
            },
          ),

          // گزینه درباره برنامه
          _MenuOption(
            icon: Icons.info_outline_rounded,
            title: 'درباره برنامه',
            subtitle: 'Mirza Shop v${AppConstants.appVersion}',
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mirza Shop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نسخه 1.0.0'),
            const SizedBox(height: 8),
            Text(
              'نرم‌افزار مدیریت محصوالت فروشگاه\nطراحی شده برای سوپرمارکت‌ها، هایپرمارکت‌ها و فروشگاه‌ها',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }
}

/// آیتم منوی گزینه‌ها
class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF00E5FF), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
