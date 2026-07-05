import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';

class WsMessage {
  final String type;
  final String? deviceId;
  final Map<String, dynamic>? data;
  final String? message;

  const WsMessage({
    required this.type,
    this.deviceId,
    this.data,
    this.message,
  });

  factory WsMessage.fromJson(Map<String, dynamic> json) => WsMessage(
        type: json['type'] as String? ?? '',
        deviceId: json['device_id'] as String?,
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
      );
}

class WebSocketClient {
  WebSocketChannel? _channel;
  final _controller = StreamController<WsMessage>.broadcast();
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  String? _token;
  bool _disposed = false;
  bool _intentionalClose = false;

  Stream<WsMessage> get messages => _controller.stream;
  bool get isConnected => _channel != null;

  Future<void> connect(String token) async {
    _token = token;
    _intentionalClose = false;
    await _doConnect();
  }

  Future<void> _doConnect() async {
    if (_disposed) return;
    try {
      final uri = Uri.parse('$wsBaseUrl/ws?token=$_token');
      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            _controller.add(WsMessage.fromJson(json));
          } catch (_) {}
        },
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
      );
    } catch (_) {
      _onDisconnected();
    }
  }

  void _onDisconnected() {
    _channel = null;
    _subscription?.cancel();
    _subscription = null;
    if (!_intentionalClose && !_disposed) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(AppConstants.wsReconnectDelay, _doConnect);
    }
  }

  void subscribe(List<String> deviceIds) {
    _send({'type': 'subscribe', 'device_ids': deviceIds});
  }

  void unsubscribe(List<String> deviceIds) {
    _send({'type': 'unsubscribe', 'device_ids': deviceIds});
  }

  void _send(Map<String, dynamic> msg) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(msg));
      } catch (_) {}
    }
  }

  Future<void> disconnect() async {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _controller.close();
  }
}
