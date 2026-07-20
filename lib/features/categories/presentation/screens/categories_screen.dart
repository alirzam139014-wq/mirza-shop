/// صفحه مدیریت دسته‌بندی‌ها
/// نمایش، افزودن، ویرایش و حذف دسته‌بندی‌ها
/// امکان ساخت دسته جدید با نام، آیکون و رنگ اختصاصی
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_providers.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/models/category_model.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final CategoryLocalDataSource _dataSource = CategoryLocalDataSource();

  /// نمایش دیالوگ افزودن/ویرایش دسته‌بندی
  void _showCategoryDialog({CategoryEntity? category}) {
    final nameController =
        TextEditingController(text: category?.name ?? '');
    String? selectedIcon = category?.icon;
    String selectedColor = category?.color ?? '#00E5FF';

    final icons = [
      '🍕', '🥛', '🥤', '🍿', '✏️', '🧴', '🧼', '💄',
      '🥫', '🥜', '🌶️', '🧃', '🍊', '🍫', '🫧', '🍵',
      '☕', '🍚', '🫒', '🍬', '🍝', '📦', '🧹', '🪥',
      '👕', '👟', '📱', '💊', '🔧', '🎁',
    ];

    final colors = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
      '#FFEAA7', '#DDA0DD', '#98D8C8', '#F7DC6F',
      '#BB8FCE', '#D4AC0D', '#E74C3C', '#2ECC71',
      '#F39C12', '#8D6E63', '#00BCD4', '#4CAF50',
      '#00E5FF', '#FF9800', '#9C27B0', '#607D8B',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                category != null ? 'ویرایش دسته‌بندی' : 'دسته‌بندی جدید',
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نام دسته
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'نام دسته‌بندی',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // انتخاب آیکون
                    const Text(
                      'آیکون:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((icon) {
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedIcon = icon),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedIcon == icon
                                  ? const Color(0xFF00E5FF).withOpacity(0.2)
                                  : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedIcon == icon
                                    ? const Color(0xFF00E5FF)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child:
                                  Text(icon, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // انتخاب رنگ
                    const Text(
                      'رنگ:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((color) {
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                  color.replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('انصراف',
                      style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;

                    final now = DateTime.now();
                    if (category != null) {
                      await _dataSource.updateCategory(CategoryModel(
                        id: category.id,
                        name: nameController.text.trim(),
                        icon: selectedIcon,
                        color: selectedColor,
                        createdAt: category.createdAt,
                      ));
                    } else {
                      await _dataSource.insertCategory(CategoryModel(
                        name: nameController.text.trim(),
                        icon: selectedIcon ?? '📦',
                        color: selectedColor,
                        createdAt: now,
                      ));
                    }

                    Navigator.pop(dialogContext);
                    ref.invalidate(categoriesProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(category != null ? 'ذخیره' : 'افزودن'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// حذف دسته‌بندی با تأیید
  void _deleteCategory(CategoryEntity category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف دسته‌بندی',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'آیا مطمئن هستید؟ محصوالت این دسته بدون دسته‌بندی می‌شوند.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dataSource.deleteCategory(category.id!);
              Navigator.pop(dialogContext);
              ref.invalidate(categoriesProvider);
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
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('دسته‌بندی‌ها'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final color = Color(
                int.parse(category.color.replaceFirst('#', '0xFF')));

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: Key(category.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_rounded,
                      color: Color(0xFFEF5350)),
                ),
                confirmDismiss: (_) async {
                  _deleteCategory(category);
                  return false;
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: themeManager.cardColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            category.icon ?? '📦',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _showCategoryDialog(category: category),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: themeManager.neonColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('دسته جدید'),
      ),
    );
  }
}
