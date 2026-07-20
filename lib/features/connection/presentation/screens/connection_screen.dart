/// صفحه اتصال گوشی به کامپیوتر
/// استفاده از گوشی به عنوان بارکدخوان بی‌سیم
/// ارتباط از طریق Wi-Fi/LAN داخلی بدون نیاز به اینترنت
/// نمایش کد اتصال (QR) روی کامپیوتر، اسکن با گوشی
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../data/services/connection_service.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  /// آیا این دستگاه سرور است (کامپیوتر) یا کلاینت (گوشی)
  final bool isServer;

  const ConnectionScreen({super.key, this.isServer = false});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // اگر سرور است، شروع کن
    if (widget.isServer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(connectionServiceProvider).startServer();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);
    final connectionService = ref.watch(connectionServiceProvider);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('اتصال گوشی به کامپیوتر'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () {
            ref.read(connectionServiceProvider).disconnect();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── وضعیت اتصال ─────────────────────────────
            _buildConnectionStatus(connectionService, themeManager),
            const SizedBox(height: 32),

            if (widget.isServer) ...[
              // ─── حالت سرور (کامپیوتر) ────────────────────
              _buildServerView(connectionService, themeManager),
            ] else ...[
              // ─── حالت کلاینت (گوشی) ─────────────────────
              _buildClientView(connectionService, themeManager),
            ],

            const Spacer(),

            // ─── راهنما ────────────────────────────────────
            _buildGuide(themeManager),
          ],
        ),
      ),
    );
  }

  /// نمایش وضعیت اتصال
  Widget _buildConnectionStatus(
    ConnectionService service,
    ThemeManager themeManager,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (service.status) {
      case ConnectionStatus.connected:
        statusColor = const Color(0xFF4CAF50);
        statusText = 'متصل';
        statusIcon = Icons.check_circle_rounded;
        break;
      case ConnectionStatus.connecting:
        statusColor = const Color(0xFFFF9800);
        statusText = 'در حال اتصال...';
        statusIcon = Icons.sync_rounded;
        break;
      case ConnectionStatus.error:
        statusColor = const Color(0xFFEF5350);
        statusText = 'خطا در اتصال';
        statusIcon = Icons.error_outline_rounded;
        break;
      case ConnectionStatus.disconnected:
        statusColor = Colors.white.withOpacity(0.4);
        statusText = 'قطع';
        statusIcon = Icons.link_off_rounded;
        break;
    }

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: service.status == ConnectionStatus.connected
                ? _pulseAnimation.value
                : 1.0,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: service.status == ConnectionStatus.connected
                        ? [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (service.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// نمای سرور (کامپیوتر) - نمایش کد اتصال
  Widget _buildServerView(
    ConnectionService service,
    ThemeManager themeManager,
  ) {
    return Column(
      children: [
        // کد اتصال (QR)
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeManager.neonColor.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Center(
            child: service.connectionCode != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 100,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.connectionCode!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'این کد را با گوشی اسکن کنید',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// نمای کلاینت (گوشی) - اتصال به سرور
  Widget _buildClientView(
    ConnectionService service,
    ThemeManager themeManager,
  ) {
    final ipController = TextEditingController();
    final portController = TextEditingController(text: '8080');

    return Column(
      children: [
        // فیلد آدرس سرور
        TextField(
          controller: ipController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'آدرس IP کامپیوتر (مثلاً 192.168.1.100)',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: Icon(
              Icons.dns_rounded,
              color: Colors.white.withOpacity(0.4),
            ),
            filled: true,
            fillColor: themeManager.cardColor.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // دکمه اتصال
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: service.status == ConnectionStatus.connecting
                ? null
                : () {
                    final ip = ipController.text.trim();
                    final port =
                        int.tryParse(portController.text.trim()) ?? 8080;
                    if (ip.isNotEmpty) {
                      service.connectToServer(ip, port);
                    }
                  },
            icon: const Icon(Icons.link_rounded),
            label: const Text(
              'اتصال',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeManager.neonColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // یا اسکن QR
        TextButton.icon(
          onPressed: () {
            // TODO: باز کردن اسکنر QR برای خواندن کد اتصال
          },
          icon: Icon(
            Icons.qr_code_scanner_rounded,
            color: themeManager.neonColor,
          ),
          label: Text(
            'یا اسکن کد QR کامپیوتر',
            style: TextStyle(color: themeManager.neonColor),
          ),
        ),
      ],
    );
  }

  /// راهنمای اتصال
  Widget _buildGuide(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeManager.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: themeManager.neonColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'راهنمای اتصال',
                style: TextStyle(
                  color: themeManager.neonColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '۱. برنامه را روی کامپیوتر باز کنید\n'
            '۲. گزینه «اتصال گوشی» را انتخاب کنید\n'
            '۳. کد نمایش‌داده‌شده را با گوشی اسکن کنید\n'
            '۴. حالا با هر اسکن بارکد، اطلاعات روی کامپیوتر نمایش داده می‌شود\n\n'
            '⚡ ارتباط از طریق Wi-Fi داخلی است و نیازی به اینترنت ندارد',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
