/// ویجت فیلتر و مرتب‌سازی محصوالت
/// فیلتر بر اساس: دسته‌بندی، محدوده قیمت، جدیدترین، دارای تصویر
/// مرتب‌سازی: الفبایی (آ-ی / ی-آ)، ارزان‌ترین، گران‌ترین، جدیدترین
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/product_providers.dart';

/// حالت مرتب‌سازی
enum SortMode {
  newest,      // جدیدترین
  nameAsc,     // الفبایی آ-ی
  nameDesc,    // الفبایی ی-آ
  priceAsc,    // ارزان‌ترین
  priceDesc,   // گران‌ترین
}

/// Provider حالت مرتب‌سازی
final sortModeProvider = StateProvider<SortMode>((ref) => SortMode.newest);

/// Provider فیلتر دسته‌بندی
final categoryFilterProvider = StateProvider<int?>((ref) => null);

/// Provider فیلتر "فقط دارای تصویر"
final hasImageFilterProvider = StateProvider<bool>((ref) => false);

class FilterSortWidget extends ConsumerWidget {
  const FilterSortWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.watch(themeManagerProvider);
    final sortMode = ref.watch(sortModeProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // ─── دکمه مرتب‌سازی ─────────────────────────
            _FilterChip(
              icon: Icons.sort_rounded,
              label: _getSortLabel(sortMode),
              isSelected: true,
              color: themeManager.neonColor,
              onTap: () => _showSortDialog(context, ref),
            ),
            const SizedBox(width: 8),

            // ─── فیلتر دسته‌بندی ──────────────────────────
            _FilterChip(
              icon: Icons.category_rounded,
              label: selectedCategory != null
                  ? 'دسته: انتخاب شده'
                  : 'همه دسته‌ها',
              isSelected: selectedCategory != null,
              color: themeManager.neonColor,
              onTap: () => _showCategoryFilter(context, ref, categoriesAsync),
            ),
            const SizedBox(width: 8),

            // ─── فیلتر دارای تصویر ────────────────────────
            _FilterChip(
              icon: Icons.image_rounded,
              label: 'با تصویر',
              isSelected: ref.watch(hasImageFilterProvider),
              color: themeManager.neonColor,
              onTap: () {
                final current = ref.read(hasImageFilterProvider);
                ref.read(hasImageFilterProvider.notifier).state = !current;
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(SortMode mode) {
    switch (mode) {
      case SortMode.newest:
        return 'جدیدترین';
      case SortMode.nameAsc:
        return 'آ - ی';
      case SortMode.nameDesc:
        return 'ی - آ';
      case SortMode.priceAsc:
        return 'ارزان‌ترین';
      case SortMode.priceDesc:
        return 'گران‌ترین';
    }
  }

  /// نمایش دیالوگ مرتب‌سازی
  void _showSortDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مرتب‌سازی',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _SortOption(
                title: 'جدیدترین',
                icon: Icons.access_time_rounded,
                isSelected: ref.read(sortModeProvider) == SortMode.newest,
                onTap: () {
                  ref.read(sortModeProvider.notifier).state = SortMode.newest;
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'الفبایی (آ تا ی)',
                icon: Icons.sort_by_alpha_rounded,
                isSelected:
                    ref.read(sortModeProvider) == SortMode.nameAsc,
                onTap: () {
                  ref.read(sortModeProvider.notifier).state = SortMode.nameAsc;
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'الفبایی (ی تا آ)',
                icon: Icons.sort_by_alpha_rounded,
                isSelected:
                    ref.read(sortModeProvider) == SortMode.nameDesc,
                onTap: () {
                  ref.read(sortModeProvider.notifier).state =
                      SortMode.nameDesc;
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'ارزان‌ترین',
                icon: Icons.arrow_downward_rounded,
                isSelected:
                    ref.read(sortModeProvider) == SortMode.priceAsc,
                onTap: () {
                  ref.read(sortModeProvider.notifier).state =
                      SortMode.priceAsc;
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'گران‌ترین',
                icon: Icons.arrow_upward_rounded,
                isSelected:
                    ref.read(sortModeProvider) == SortMode.priceDesc,
                onTap: () {
                  ref.read(sortModeProvider.notifier).state =
                      SortMode.priceDesc;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// نمایش فیلتر دسته‌بندی
  void _showCategoryFilter(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فیلتر دسته‌بندی',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // همه
              _SortOption(
                title: 'همه دسته‌ها',
                icon: Icons.apps_rounded,
                isSelected: ref.read(categoryFilterProvider) == null,
                onTap: () {
                  ref.read(categoryFilterProvider.notifier).state = null;
                  Navigator.pop(context);
                },
              ),

              // دسته‌بندی‌ها
              categoriesAsync.when(
                data: (categories) => Column(
                  children: categories.map((cat) {
                    return _SortOption(
                      title: '${cat.icon ?? ''} ${cat.name}',
                      icon: null,
                      isSelected:
                          ref.read(categoryFilterProvider) == cat.id,
                      onTap: () {
                        ref.read(categoryFilterProvider.notifier).state =
                            cat.id;
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// چیپ فیلتر
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : const Color(0xFF2A2A2A).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.white54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// گزینه مرتب‌سازی
class _SortOption extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF00E5FF)
                    : Colors.white54,
              ),
            if (icon != null) const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00E5FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
