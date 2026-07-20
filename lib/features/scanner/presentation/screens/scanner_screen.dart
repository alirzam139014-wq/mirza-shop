/// صفحه اسکنر بارکد
/// دو حالت:
/// 1. هنگام ثبت محصول: بارکد اسکن شده داخل فیلد قرار می‌گیرد
/// 2. جستجوی مستقیم: بعد از اسکن، اطلاعات محصول نمایش داده می‌شود
/// طراحی: کادر اسکن نئون، انیمیشن خط اسکن، دکمه چراغ‌قوه
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/product_providers.dart';

/// نتیجه اسکن بارکد
class ScanResult {
  final String barcode;
  final ProductEntity? product;
  final bool found;

  const ScanResult({
    required this.barcode,
    this.product,
    this.found = false,
  });
}

class ScannerScreen extends ConsumerStatefulWidget {
  /// اگر true باشد، بارکد اسکن‌شده به صفحه افزودن محصول برمی‌گردد
  final bool returnBarcodeOnly;

  const ScannerScreen({
    super.key,
    this.returnBarcodeOnly = false,
  });

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with TickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );

  bool _isTorchOn = false;
  bool _isProcessing = false;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    // انیمیشن خط اسکن نئون
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );
    _scanLineController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  /// پردازش بارکد اسکن‌شده
  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final barcode = barcodes.first.rawValue!;
    setState(() => _isProcessing = true);

    // ویبره هنگام شناسایی
    // HapticFeedback.mediumImpact();

    if (widget.returnBarcodeOnly) {
      // حالت اول: فقط بارکد را برگردان
      Navigator.pop(context, barcode);
      return;
    }

    // حالت دوم: جستجو در دیتابیس
    final useCase = ref.read(getProductByBarcodeUseCaseProvider);
    final product = await useCase(barcode);

    if (!mounted) return;

    if (product != null) {
      // محصول پیدا شد - نمایش اطلاعات
      _showProductFound(product);
    } else {
      // محصول پیدا نشد
      _showProductNotFound(barcode);
    }

    setState(() => _isProcessing = false);
  }

  /// نمایش اطلاعات محصول یافت‌شده
  void _showProductFound(ProductEntity product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProductFoundSheet(product: product),
    );
  }

  /// نمایش پیام "محصول ثبت نشده"
  void _showProductNotFound(String barcode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductNotFoundSheet(
        barcode: barcode,
        onRegisterNew: () {
          Navigator.pop(context);
          Navigator.pop(context, barcode);
        },
      ),
    );
  }

  /// روشن/خاموش کردن چراغ‌قوه
  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── دوربین ──────────────────────────────────────
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),

          // ─── اورلی تیره ─────────────────────────────────
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                // کادر شفاف اسکن
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.red, // رنگ مهم نیست، فقط برای srcOut
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── کادر اسکن نئون ─────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      // گوشه‌های نئون
                      _buildCorner(themeManager, Alignment.topRight, true, true),
                      _buildCorner(themeManager, Alignment.topLeft, true, false),
                      _buildCorner(themeManager, Alignment.bottomRight, false, true),
                      _buildCorner(themeManager, Alignment.bottomLeft, false, false),

                      // خط اسکن متحرک
                      Positioned(
                        left: 20,
                        right: 20,
                        top: 20 + (_scanLineAnimation.value * 240),
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeManager.neonColor.withOpacity(0),
                                themeManager.neonColor,
                                themeManager.neonColor.withOpacity(0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeManager.neonColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ─── دکمه‌های کنترل ─────────────────────────────
          Positioned(
            top: 60,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // دکمه چراغ‌قوه
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleTorch,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isTorchOn
                        ? themeManager.neonColor
                        : Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeManager.neonColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isTorchOn
                        ? Icons.flashlight_on_rounded
                        : Icons.flashlight_off_rounded,
                    color: _isTorchOn ? Colors.black : Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // متن راهنما
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'بارکد را مقابل دوربین قرار دهید',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),

          // نشانگر پردازش
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E5FF),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ساخت گوشه‌های نئون کادر اسکن
  Widget _buildCorner(
    ThemeManager themeManager,
    Alignment alignment,
    bool isTop,
    bool isRight,
  ) {
    return Align(
      alignment: alignment,
      child: CustomPaint(
        size: const Size(40, 40),
        painter: _CornerPainter(
          color: themeManager.neonColor,
          isTop: isTop,
          isRight: isRight,
        ),
      ),
    );
  }
}

/// نقاش گوشه‌های کادر اسکن
class _CornerPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isRight;

  _CornerPainter({
    required this.color,
    required this.isTop,
    required this.isRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isTop && !isRight) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (!isTop && isRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// شیت نمایش محصول یافت‌شده
class _ProductFoundSheet extends StatelessWidget {
  final ProductEntity product;

  const _ProductFoundSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const SizedBox(height: 20),

          // آیکون موفقیت
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // نام محصول
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // قیمت
          Text(
            _formatPrice(product.price),
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF00E5FF),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // بارکد
          Text(
            'بارکد: ${product.barcode}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
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

/// شیت "محصول ثبت نشده"
class _ProductNotFoundSheet extends StatelessWidget {
  final String barcode;
  final VoidCallback onRegisterNew;

  const _ProductNotFoundSheet({
    required this.barcode,
    required this.onRegisterNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // آیکون هشدار
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF9800),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'این محصول ثبت نشده است',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'بارکد: $barcode',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),

          // دکمه ثبت محصول جدید
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRegisterNew,
              icon: const Icon(Icons.add_rounded),
              label: const Text('ثبت محصول جدید'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // دکمه اسکن مجدد
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'اسکن مجدد',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
