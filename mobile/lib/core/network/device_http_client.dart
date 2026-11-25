import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/device_endpoints.dart';

class DeviceHttpException implements Exception {
  final String message;
  DeviceHttpException(this.message);

  @override
  String toString() => message;
}

class DeviceInfo {
  final String serial;
  final String? fw;
  final String mode;
  final String power;
  final bool mqtt;
  final String? ip;

  const DeviceInfo({
    required this.serial,
    required this.mode,
    required this.power,
    this.fw,
    this.mqtt = false,
    this.ip,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        serial: json['serial'] as String? ?? '',
        fw: json['fw'] as String?,
        mode: json['mode'] as String? ?? 'unknown',
        power: json['power'] as String? ?? 'off',
        mqtt: json['mqtt'] == true,
        ip: json['ip'] as String?,
      );
}

/// Direct HTTP to the plug (SoftAP or LAN). No MQTT on the phone.
class DeviceHttpClient {
  DeviceHttpClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String baseUrl, String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      h['X-Device-Token'] = token;
    }
    return h;
  }

  Future<DeviceInfo> getInfo(
    String baseUrl, {
    String? token,
    Duration timeout = const Duration(milliseconds: 400),
  }) async {
    try {
      final response = await _client
          .get(_uri(baseUrl, DeviceHttpPaths.info), headers: _headers(token: token))
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DeviceHttpException('info HTTP ${response.statusCode}');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return DeviceInfo.fromJson(body);
    } on DeviceHttpException {
      rethrow;
    } catch (_) {
      throw DeviceHttpException('Device not reachable at $baseUrl');
    }
  }

  Future<String> setPower(
    String baseUrl,
    String power, {
    String? token,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    try {
      final response = await _client
          .post(
            _uri(baseUrl, DeviceHttpPaths.power),
            headers: _headers(token: token),
            body: jsonEncode({'power': power}),
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DeviceHttpException('power HTTP ${response.statusCode}');
      }
      if (response.body.isEmpty) return power;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['power'] as String? ?? power;
    } on DeviceHttpException {
      rethrow;
    } catch (_) {
      throw DeviceHttpException('Could not set power at $baseUrl');
    }
  }

  Future<void> setup({
    required String ssid,
    required String password,
    required String serial,
    required String pairingToken,
    String? baseUrl,
    String? deviceToken,
  }) async {
    final root = baseUrl ?? softApBaseUrl;
    final body = jsonEncode({
      'ssid': ssid,
      'password': password,
      'serial': serial,
      'pairing_token': pairingToken,
      'mqtt_host': sellerMqttHost,
      'mqtt_port': sellerMqttPort,
      'mqtt_user': sellerMqttDeviceUser.isNotEmpty
          ? sellerMqttDeviceUser
          : serial,
      if (sellerMqttDevicePassword.isNotEmpty)
        'mqtt_pass': sellerMqttDevicePassword,
      if (deviceToken != null) 'local_token': deviceToken,
    });

    try {
      final response = await _client
          .post(
            _uri(root, DeviceHttpPaths.setup),
            headers: _headers(),
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DeviceHttpException(
          'Device rejected setup (HTTP ${response.statusCode})',
        );
      }
    } on DeviceHttpException {
      rethrow;
    } catch (_) {
      throw DeviceHttpException(
        'Could not reach device at $root. '
        'Connect your phone to the SmartPlug Wi‑Fi first.',
      );
    }
  }
}
