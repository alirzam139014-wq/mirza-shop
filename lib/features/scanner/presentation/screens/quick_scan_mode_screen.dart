/// حالت اسکن سریع فروشگاهی (Quick Scan Mode / Fast Store Mode)
/// برای مغازه‌هایی که سرعت مهم است
/// دوربین سریع باز می‌شود، اسکن پشت سر هم امکان‌پذیر است
/// بعد از هر اسکن اطلاعات محصول نمایش داده می‌شود
/// بدون نیاز به رفتن بین صفحات
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/product_providers.dart';

class QuickScanModeScreen extends ConsumerStatefulWidget {
  const QuickScanModeScreen({super.key});

  @override
  ConsumerState<QuickScanModeScreen> createState() =>
      _QuickScanModeScreenState();
}

class _QuickScanModeScreenState extends ConsumerState<QuickScanModeScreen> {
  final MobileScannerController _scannerController =
      MobileScannerController(
    detectionSpeed: DetectionSpeed.unlimited, // اسکن پشت سر هم
    torchEnabled: false,
  );

  ProductEntity? _currentProduct;
  bool _productFound = false;
  int _scanCount = 0;
  bool _isTorchOn = false;
  DateTime? _lastScanTime;

  /// پردازش بارکد اسکن‌شده
  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    // جلوگیری از اسکن تکراری در کمتر از ۱ ثانیه
    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 1000) {
      return;
    }
    _lastScanTime = now;

    final barcode = barcodes.first.rawValue!;

    // ویبره
    HapticFeedback.mediumImpact();

    // جستجو در دیتابیس
    final useCase = ref.read(getProductByBarcodeUseCaseProvider);
    final product = await useCase(barcode);

    if (mounted) {
      setState(() {
        _scanCount++;
        _currentProduct = product;
        _productFound = product != null;
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── دوربین (تمام صفحه) ─────────────────────────
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),

          // ─── اورلی ──────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // ─── هدر ────────────────────────────────────────
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // دکمه خروج
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),

                // عنوان
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'اسکن سریع',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),

                // شمارنده اسکن
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeManager.neonColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeManager.neonColor.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    '$_scanCount',
                    style: TextStyle(
                      color: themeManager.neonColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── کادر اسکن ──────────────────────────────────
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeManager.neonColor.withOpacity(0.6),
                  width: 2,
                ),
              ),
            ),
          ),

          // ─── نتیجه اسکن (پایین صفحه) ────────────────────
          if (_currentProduct != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildResultCard(themeManager),
            )
          else
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'بارکد را مقابل دوربین بگیرید',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // ─── دکمه چراغ‌قوه ──────────────────────────────
          Positioned(
            bottom: _currentProduct != null ? 200 : 80,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                await _scannerController.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isTorchOn
                      ? themeManager.neonColor
                      : Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeManager.neonColor.withOpacity(0.5),
                  ),
                ),
                child: Icon(
                  _isTorchOn
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded,
                  color: _isTorchOn ? Colors.black : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// کارت نتیجه اسکن
  Widget _buildResultCard(ThemeManager themeManager) {
    final product = _currentProduct!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _productFound
              ? const Color(0xFF4CAF50).withOpacity(0.5)
              : const Color(0xFFFF9800).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_productFound) ...[
            // محصول پیدا شد
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50), size: 24),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.barcode ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                // قیمت بزرگ
                Text(
                  _formatPrice(product.price),
                  style: TextStyle(
                    color: themeManager.neonColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else ...[
            // محصول پیدا نشد
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFFF9800), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'این محصول ثبت نشده است',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: رفتن به صفحه ثبت محصول با بارکد پرشده
                  Navigator.pop(context, product.barcode);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('ثبت محصول جدید'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeManager.neonColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
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
    return '$buffer ت';
  }
}
