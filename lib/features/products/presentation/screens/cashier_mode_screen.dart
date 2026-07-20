/// حالت صندوق (Cashier Mode)
/// صفحه ساده و بزرگ برای استفاده روزانه پشت پیشخوان
/// با هر اسکن بارکد، نام، قیمت و عکس محصول فوراً نمایش داده می‌شود
/// دکمه‌های بزرگ، قیمت بزرگ، دسترسی سریع به اسکن
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../scanner/presentation/screens/scanner_screen.dart';

class CashierModeScreen extends ConsumerStatefulWidget {
  const CashierModeScreen({super.key});

  @override
  ConsumerState<CashierModeScreen> createState() => _CashierModeScreenState();
}

class _CashierModeScreenState extends ConsumerState<CashierModeScreen>
    with TickerProviderStateMixin {
  ProductEntity? _lastScannedProduct;
  bool _isScanning = false;
  final List<ProductEntity> _scanHistory = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// باز کردن اسکنر بارکد
  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const ScannerScreen(returnBarcodeOnly: true),
      ),
    );

    setState(() => _isScanning = false);

    if (barcode != null && barcode.isNotEmpty) {
      await _lookupProduct(barcode);
    }
  }

  /// جستجوی محصول بر اساس بارکد
  Future<void> _lookupProduct(String barcode) async {
    final useCase = ref.read(getProductByBarcodeUseCaseProvider);
    final product = await useCase(barcode);

    if (mounted) {
      setState(() {
        _lastScannedProduct = product;
        if (product != null) {
          _scanHistory.insert(0, product);
          if (_scanHistory.length > 20) _scanHistory.removeLast();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ─── هدر ساده ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'حالت صندوق',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  // دکمه خروج از حالت صندوق
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // ─── بخش اصلی: نمایش محصول اسکن‌شده ───────────
            Expanded(
              child: _lastScannedProduct != null
                  ? _buildProductDisplay(themeManager)
                  : _buildWaitingState(themeManager),
            ),

            // ─── تاریخچه اسکن‌های اخیر ────────────────────
            if (_scanHistory.length > 1)
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _scanHistory.length - 1,
                  itemBuilder: (context, index) {
                    final product = _scanHistory[index + 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Chip(
                        label: Text(
                          product.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor:
                            themeManager.cardColor.withOpacity(0.8),
                        labelStyle: const TextStyle(color: Colors.white70),
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ),

            // ─── دکمه اسکن بزرگ ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 72,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isScanning ? 1.0 : _pulseAnimation.value,
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 32,
                        ),
                      );
                    },
                  ),
                  label: Text(
                    _isScanning ? 'در حال اسکن...' : 'اسکن بارکد',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeManager.neonColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: themeManager.neonColor.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// نمایش محصول اسکن‌شده (بزرگ و واضح)
  Widget _buildProductDisplay(ThemeManager themeManager) {
    final product = _lastScannedProduct!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تصویر محصول
            if (product.imagePath != null &&
                File(product.imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  File(product.imagePath!),
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: themeManager.neonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: themeManager.neonColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 64,
                  color: themeManager.neonColor.withOpacity(0.5),
                ),
              ),
            const SizedBox(height: 24),

            // نام محصول (بزرگ)
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // قیمت (خیلی بزرگ)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: themeManager.neonColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeManager.neonColor.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeManager.neonColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Text(
                _formatPrice(product.price),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: themeManager.neonColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // بارکد
            Text(
              product.barcode ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.4),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// حالت انتظار (قبل از اولین اسکن)
  Widget _buildWaitingState(ThemeManager themeManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: 100,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 24),
          Text(
            'بارکد محصول را اسکن کنید',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اطلاعات محصول فوراً نمایش داده می‌شود',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.2),
            ),
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
