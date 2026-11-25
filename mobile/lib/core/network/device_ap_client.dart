import 'device_http_client.dart';

/// SoftAP provisioning — thin wrapper over [DeviceHttpClient.setup].
class DeviceApClient {
  static Future<void> configure({
    required String ssid,
    required String password,
    required String serial,
    required String token,
  }) {
    return DeviceHttpClient().setup(
      ssid: ssid,
      password: password,
      serial: serial,
      pairingToken: token,
    );
  }
}

typedef DeviceApException = DeviceHttpException;
