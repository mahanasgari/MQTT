import 'package:flutter_dotenv/flutter_dotenv.dart';

/// SoftAP default gateway for ESP8266 / ESP32 AP mode.
String get softApBaseUrl =>
    dotenv.env['DEVICE_AP_BASE_URL'] ?? 'http://192.168.4.1';

String get softApSsidPrefix =>
    dotenv.env['DEVICE_AP_SSID_PREFIX'] ?? 'SmartPlug-';

/// Seller MQTT host embedded into device during SoftAP setup (not a home broker).
String get sellerMqttHost =>
    dotenv.env['MQTT_BROKER_HOST'] ?? 'localhost';

int get sellerMqttPort =>
    int.tryParse(dotenv.env['MQTT_BROKER_PORT'] ?? '1883') ?? 1883;

/// Device MQTT principal on seller broker (username usually = serial).
String get sellerMqttDeviceUser =>
    dotenv.env['MQTT_DEVICE_USERNAME'] ?? '';

String get sellerMqttDevicePassword =>
    dotenv.env['MQTT_DEVICE_PASSWORD'] ?? '';

/// Optional lab/default LAN IP (e.g. after first SoftAP setup on this network).
String get deviceDefaultLanIp =>
    dotenv.env['DEVICE_DEFAULT_LAN_IP'] ?? '';

class DeviceHttpPaths {
  static const info = '/v1/info';
  static const state = '/v1/state';
  static const power = '/v1/power';
  static const setup = '/v1/setup';
}
