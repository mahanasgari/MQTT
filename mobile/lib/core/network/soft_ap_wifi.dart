import 'package:flutter/services.dart';
import '../constants/device_endpoints.dart';
import 'device_http_client.dart';
import 'nearby_wifi.dart';
import 'soft_ap_ssid.dart';

enum SoftApWifiErrorCode {
  unsupported,
  permission,
  unavailable,
  notReachable,
  settings,
  unknown,
}

class SoftApWifiException implements Exception {
  final SoftApWifiErrorCode code;
  final String message;
  SoftApWifiException(this.message, {this.code = SoftApWifiErrorCode.unknown});

  @override
  String toString() => message;
}

/// Joins the plug setup Wi‑Fi from the app (Android WifiNetworkSpecifier)
/// and binds HTTP to 192.168.4.1. No browser.
class SoftApWifi {
  SoftApWifi._();

  static const _channel = MethodChannel('smartplug/softap_wifi');

  static String ssidFromSerial(String serial) =>
      softApSsidFromSerial(serial, prefix: softApSsidPrefix);

  static Future<List<NearbyWifi>> scanNetworks() async {
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('scanNetworks');
      final parsed = (raw ?? const [])
          .whereType<Map>()
          .map(NearbyWifi.fromMap);
      return mergeWifiScans(parsed);
    } on MissingPluginException {
      return const [];
    } on PlatformException catch (e) {
      final code = e.code == 'PERMISSION'
          ? SoftApWifiErrorCode.permission
          : SoftApWifiErrorCode.unknown;
      throw SoftApWifiException(
        e.message ?? 'Could not list Wi‑Fi networks.',
        code: code,
      );
    }
  }

  static Future<List<NearbyWifi>> scanPlugHotspots() async {
    final all = await scanNetworks();
    return all
        .where((n) => n.ssid.toUpperCase().startsWith(softApSsidPrefix.toUpperCase()))
        .toList();
  }

  static Future<String?> currentSsid() async {
    try {
      final ssid = await _channel.invokeMethod<String>('currentSsid');
      if (ssid == null || ssid.isEmpty || ssid == '<unknown ssid>') {
        return null;
      }
      if (ssid.startsWith(softApSsidPrefix)) return null;
      return ssid;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static Future<bool> isDeviceReachable({
    Duration timeout = const Duration(milliseconds: 800),
  }) async {
    try {
      await DeviceHttpClient().getInfo(softApBaseUrl, timeout: timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<DeviceInfo?> tryGetInfo({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    try {
      return await DeviceHttpClient().getInfo(softApBaseUrl, timeout: timeout);
    } catch (_) {
      return null;
    }
  }

  /// System dialog: "Connect to device?". Stays in the app — not a browser.
  static Future<void> connect(String ssid) async {
    try {
      await _channel.invokeMethod<void>('connectToSsid', {'ssid': ssid});
    } on MissingPluginException {
      throw SoftApWifiException(
        'This build cannot join Wi‑Fi from the app.',
        code: SoftApWifiErrorCode.unsupported,
      );
    } on PlatformException catch (e) {
      final code = switch (e.code) {
        'UNSUPPORTED' => SoftApWifiErrorCode.unsupported,
        'UNAVAILABLE' => SoftApWifiErrorCode.unavailable,
        'PERMISSION' => SoftApWifiErrorCode.permission,
        _ => SoftApWifiErrorCode.unavailable,
      };
      throw SoftApWifiException(
        e.message ?? 'Could not join $ssid. Approve the Connect prompt.',
        code: code,
      );
    }
  }

  static Future<void> disconnect() async {
    try {
      await _channel.invokeMethod<void>('disconnect');
    } on MissingPluginException {
      // ignore
    } on PlatformException {
      // ignore
    }
  }

  static Future<bool> hasInternet() async {
    try {
      return await _channel.invokeMethod<bool>('hasInternet') ?? false;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return false;
    }
  }

  /// Leave SoftAP, forget plug hotspots, rejoin home Wi‑Fi, wait for internet.
  static Future<bool> restoreInternet({
    String? preferredSsid,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final ok = await _channel.invokeMethod<bool>('restoreInternet', {
        'preferredSsid': preferredSsid,
        'timeoutMs': timeout.inMilliseconds,
      });
      return ok ?? false;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openWifiSettings() async {
    try {
      await _channel.invokeMethod<void>('openWifiSettings');
    } on MissingPluginException {
      throw SoftApWifiException(
        'Cannot open Wi‑Fi settings from the app.',
        code: SoftApWifiErrorCode.settings,
      );
    } on PlatformException catch (e) {
      throw SoftApWifiException(
        e.message ?? 'Cannot open Wi‑Fi settings.',
        code: SoftApWifiErrorCode.settings,
      );
    }
  }
}
