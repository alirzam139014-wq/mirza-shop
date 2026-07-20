/// صفحه افزودن / ویرایش محصول
/// فیلدها: نام، قیمت، بارکد (با اسکن)، کد محصول، دسته‌بندی، توضیحات، تصویر
/// دکمه ذخیره فقط زمانی فعال می‌شود که اطلاعات ضروری کامل باشند
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/product_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  /// اگر محصول موجود باشد، حالت ویرایش فعال است
  final ProductEntity? existingProduct;

  const AddProductScreen({super.key, this.existingProduct});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  String? _imagePath;
  bool _isSaving = false;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    // پر کردن فیلدها در حالت ویرایش
    if (_isEditing) {
      final p = widget.existingProduct!;
      _nameController.text = p.name;
      _priceController.text = p.price.toStringAsFixed(0);
      _barcodeController.text = p.barcode ?? '';
      _codeController.text = p.productCode ?? '';
      _descriptionController.text = p.description ?? '';
      _selectedCategoryId = p.categoryId;
      _imagePath = p.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// انتخاب تصویر از گالری
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      _showError('خطا در انتخاب تصویر');
    }
  }

  /// اسکن بارکد با دوربین
  Future<void> _scanBarcode() async {
    // TODO: باز کردن صفحه اسکنر بارکد
    // در نسخه نهایی از mobile_scanner استفاده می‌شود
    _showError('اسکنر بارکد در نسخه بعدی فعال می‌شود');
  }

  /// ذخیره محصول (افزودن یا ویرایش)
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final product = ProductEntity(
      id: _isEditing ? widget.existingProduct!.id : null,
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      productCode: _codeController.text.trim().isEmpty
          ? null
          : _codeController.text.trim(),
      categoryId: _selectedCategoryId,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imagePath: _imagePath,
      createdAt: _isEditing ? widget.existingProduct!.createdAt : now,
      updatedAt: now,
    );

    bool success;
    if (_isEditing) {
      success =
          await ref.read(productsProvider.notifier).updateProduct(product);
    } else {
      success =
          await ref.read(productsProvider.notifier).addProduct(product);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'محصول با موفقیت ویرایش شد ✓'
                : 'محصول با موفقیت ذخیره شد ✓',
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(productsProvider).error;
      _showError(error ?? 'مشکلی پیش آمد. دوباره تلاش کنید.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF5350),
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
        title: Text(_isEditing ? 'ویرایش محصول' : 'افزودن محصول جدید'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── انتخاب تصویر ──────────────────────────────
            _buildImagePicker(themeManager),
            const SizedBox(height: 24),

            // ─── نام محصول ─────────────────────────────────
            _buildTextField(
              controller: _nameController,
              label: 'نام محصول *',
              hint: 'مثلاً: نوشابه کوکاکولا خانواده',
              icon: Icons.label_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'نام محصول الزامی است';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ─── قیمت ──────────────────────────────────────
            _buildTextField(
              controller: _priceController,
              label: 'قیمت (تومان) *',
              hint: 'مثلاً: 45000',
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'قیمت الزامی است';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'قیمت باید عدد معتبر باشد';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ─── بارکد ─────────────────────────────────────
            _buildBarcodeField(themeManager),
            const SizedBox(height: 16),

            // ─── کد محصول ──────────────────────────────────
            _buildTextField(
              controller: _codeController,
              label: 'کد محصول (اختیاری)',
              hint: 'کد داخلی محصول',
              icon: Icons.tag_rounded,
            ),
            const SizedBox(height: 16),

            // ─── دسته‌بندی ─────────────────────────────────
            _buildCategorySelector(categoriesAsync, themeManager),
            const SizedBox(height: 16),

            // ─── توضیحات ───────────────────────────────────
            _buildTextField(
              controller: _descriptionController,
              label: 'توضیحات (اختیاری)',
              hint: 'توضیحات اضافی درباره محصول...',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // ─── دکمه ذخیره ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeManager.neonColor,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor:
                      themeManager.neonColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _isEditing ? 'ذخیره تغییرات' : 'ثبت محصول',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// بخش انتخاب تصویر
  Widget _buildImagePicker(ThemeManager themeManager) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeManager.neonColor.withOpacity(0.4),
              width: 2,
              style: BorderStyle.solid,
            ),
            color: themeManager.cardColor.withOpacity(0.5),
          ),
          child: _imagePath != null && File(_imagePath!).existsSync()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    File(_imagePath!),
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: themeManager.neonColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'انتخاب تصویر',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// فیلد بارکد با دکمه اسکن
  Widget _buildBarcodeField(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'بارکد',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _barcodeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'بارکد محصول',
                  prefixIcon: Icon(
                    Icons.qr_code_rounded,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // دکمه اسکن بارکد
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: themeManager.neonColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeManager.neonColor.withOpacity(0.4),
                ),
              ),
              child: IconButton(
                onPressed: _scanBarcode,
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: themeManager.neonColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// انتخاب دسته‌بندی
  Widget _buildCategorySelector(
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    ThemeManager themeManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'دسته‌بندی',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        categoriesAsync.when(
          data: (categories) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: themeManager.cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedCategoryId,
                isExpanded: true,
                dropdownColor: themeManager.cardColor,
                hint: Text(
                  'انتخاب دسته‌بندی',
                  style: TextStyle(color: Colors.white.withOpacity(0.4)),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Row(
                      children: [
                        Text(cat.icon ?? '📦'),
                        const SizedBox(width: 8),
                        Text(
                          cat.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('خطا در بارگذاری دسته‌بندی‌ها'),
        ),
      ],
    );
  }

  /// ساخت فیلد متنی استاندارد
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.white.withOpacity(0.4))
                : null,
          ),
        ),
      ],
    );
  }
}
