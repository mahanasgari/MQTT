import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class DeviceApException implements Exception {
  final String message;
  DeviceApException(this.message);

  @override
  String toString() => message;
}

class DeviceApClient {
  static Future<void> configure({
    required String ssid,
    required String password,
    required String serial,
    required String token,
  }) async {
    final uri = Uri.parse(deviceApConfigureUrl);
    final body = jsonEncode({
      'ssid': ssid,
      'password': password,
      'serial': serial,
      'pairing_token': token,
      'mqtt_host': mqttBrokerHost,
      'mqtt_port': mqttBrokerPort,
    });

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DeviceApException(
          'Device rejected configuration (HTTP ${response.statusCode})',
        );
      }
    } on DeviceApException {
      rethrow;
    } catch (e) {
      throw DeviceApException(
        'Could not reach device at $deviceApConfigureUrl. '
        'Make sure you are connected to the SmartPlug Wi-Fi network.',
      );
    }
  }
}
