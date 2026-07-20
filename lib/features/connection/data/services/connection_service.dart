/// سرویس ارتباط گوشی و کامپیوتر
/// ارتباط از طریق شبکه لوکال (Wi-Fi/LAN) بدون نیاز به اینترنت
/// پروتکل: WebSocket / Local Socket
///
/// روند کار:
/// 1. برنامه ویندوز باز می‌شود
/// 2. گزینه "اتصال گوشی" انتخاب می‌شود
/// 3. یک کد اتصال (QR) نمایش داده می‌شود
/// 4. گوشی آن را اسکن می‌کند
/// 5. ارتباط برقرار می‌شود
/// 6. با هر اسکن بارکد، اطلاعات لحظه‌ای روی کامپیوتر نمایش داده می‌شود
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// وضعیت اتصال
enum ConnectionStatus {
  disconnected, // قطع
  connecting,   // در حال اتصال
  connected,    // متصل
  error,        // خطا
}

/// پیام‌های ارسالی بین گوشی و کامپیوتر
class ConnectionMessage {
  final String type; // 'barcode_scan', 'product_info', 'ping', 'pong'
  final Map<String, dynamic> data;

  const ConnectionMessage({required this.type, required this.data});

  String toJson() => jsonEncode({'type': type, 'data': data});

  factory ConnectionMessage.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ConnectionMessage(
      type: map['type'] as String,
      data: map['data'] as Map<String, dynamic>,
    );
  }
}

/// Provider وضعیت اتصال
final connectionServiceProvider =
    ChangeNotifierProvider<ConnectionService>((ref) => ConnectionService());

class ConnectionService extends ChangeNotifier {
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _connectionCode;
  String? _errorMessage;
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  WebSocket? _webSocket;

  // Stream برای دریافت پیام‌ها
  final StreamController<ConnectionMessage> _messageController =
      StreamController<ConnectionMessage>.broadcast();

  Stream<ConnectionMessage> get messages => _messageController.stream;
  ConnectionStatus get status => _status;
  String? get connectionCode => _connectionCode;
  String? get errorMessage => _errorMessage;

  /// شروع سرور (نسخه ویندوز/کامپیوتر)
  /// یک سوکت محلی باز می‌کند و کد اتصال تولید می‌کند
  Future<void> startServer({int port = 8080}) async {
    try {
      _status = ConnectionStatus.connecting;
      notifyListeners();

      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _connectionCode = _generateConnectionCode(port);
      _status = ConnectionStatus.connected;
      notifyListeners();

      _serverSocket!.listen((socket) {
        _clientSocket = socket;
        socket.listen(
          (data) {
            final message = ConnectionMessage.fromJson(utf8.decode(data));
            _messageController.add(message);
          },
          onError: (error) {
            _handleDisconnection();
          },
          onDone: () {
            _handleDisconnection();
          },
        );
      });
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = 'خطا در شروع سرور: $e';
      notifyListeners();
    }
  }

  /// اتصال به سرور (نسخه گوشی)
  Future<void> connectToServer(String host, int port) async {
    try {
      _status = ConnectionStatus.connecting;
      notifyListeners();

      _clientSocket = await Socket.connect(host, port,
          timeout: const Duration(seconds: 5));

      _clientSocket!.listen(
        (data) {
          final message = ConnectionMessage.fromJson(utf8.decode(data));
          _messageController.add(message);
        },
        onError: (error) {
          _handleDisconnection();
        },
        onDone: () {
          _handleDisconnection();
        },
      );

      _status = ConnectionStatus.connected;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = 'اتصال برقرار نشد. دوباره تلاش کنید.';
      notifyListeners();
    }
  }

  /// ارسال بارکد اسکن‌شده از گوشی به کامپیوتر
  void sendBarcode(String barcode) {
    _send(ConnectionMessage(
      type: 'barcode_scan',
      data: {'barcode': barcode},
    ));
  }

  /// ارسال اطلاعات محصول از کامپیوتر به گوشی
  void sendProductInfo(Map<String, dynamic> productData) {
    _send(ConnectionMessage(
      type: 'product_info',
      data: productData,
    ));
  }

  /// ارسال پیام
  void _send(ConnectionMessage message) {
    try {
      _clientSocket?.add(utf8.encode(message.toJson()));
      _webSocket?.add(message.toJson());
    } catch (e) {
      _handleDisconnection();
    }
  }

  /// مدیریت قطع ارتباط
  void _handleDisconnection() {
    _status = ConnectionStatus.disconnected;
    _clientSocket = null;
    notifyListeners();
    // تلاش برای اتصال مجدد می‌تواند اینجا اضافه شود
  }

  /// تولید کد اتصال (برای نمایش QR)
  String _generateConnectionCode(int port) {
    // در نسخه نهایی، IP لوکال + پورت به صورت QR نمایش داده می‌شود
    return 'MIRZA:$port';
  }

  /// قطع ارتباط
  Future<void> disconnect() async {
    await _clientSocket?.close();
    await _serverSocket?.close();
    await _webSocket?.close();
    _clientSocket = null;
    _serverSocket = null;
    _webSocket = null;
    _status = ConnectionStatus.disconnected;
    _connectionCode = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _messageController.close();
    super.dispose();
  }
}
