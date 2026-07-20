/// صفحه تاریخچه قیمت‌ها
/// هر بار که قیمت یک محصول تغییر کند، قیمت قبلی در جدول جداگانه ذخیره می‌شود
/// کاربر می‌تواند سابقه تغییر قیمت هر کالا را ببیند
/// این قابلیت در تنظیمات قابل غیرفعال کردن است
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';

class PriceHistoryScreen extends ConsumerStatefulWidget {
  final int productId;
  final String productName;

  const PriceHistoryScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  ConsumerState<PriceHistoryScreen> createState() =>
      _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends ConsumerState<PriceHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        AppConstants.tablePriceHistory,
        where: 'productId = ?',
        whereArgs: [widget.productId],
        orderBy: 'changedAt DESC',
      );
      if (mounted) {
        setState(() {
          _history = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('تاریخچه قیمت: ${widget.productName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(themeManager),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'تاریخچه‌ای وجود ندارد',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'با تغییر قیمت، تاریخچه ثبت می‌شود',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ThemeManager themeManager) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final oldPrice = (item['oldPrice'] as num).toDouble();
        final newPrice = (item['newPrice'] as num).toDouble();
        final changedAt = DateTime.parse(item['changedAt'] as String);
        final isIncrease = newPrice > oldPrice;
        final diff = newPrice - oldPrice;
        final percent =
            oldPrice > 0 ? ((diff / oldPrice) * 100).toStringAsFixed(1) : '0';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeManager.cardColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isIncrease
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF4CAF50))
                    .withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // آیکون افزایش/کاهش
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isIncrease
                            ? const Color(0xFFEF5350)
                            : const Color(0xFF4CAF50))
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isIncrease
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: isIncrease
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF4CAF50),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // اطلاعات تغییر
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _formatPrice(oldPrice),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.5),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatPrice(newPrice),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${changedAt.year}/${changedAt.month.toString().padLeft(2, '0')}/${changedAt.day.toString().padLeft(2, '0')} - ${changedAt.hour.toString().padLeft(2, '0')}:${changedAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                ),

                // درصد تغییر
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isIncrease
                            ? const Color(0xFFEF5350)
                            : const Color(0xFF4CAF50))
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isIncrease ? '+' : ''}$percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isIncrease
                          ? const Color(0xFFEF5350)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) buffer.write('٬');
      buffer.write(formatted[i]);
    }
    return '$buffer ت';
  }
}
