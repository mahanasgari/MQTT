import '../constants/device_endpoints.dart';
import '../storage/secure_storage.dart';
import '../../data/models/control_path.dart';
import '../../data/repositories/device_repository.dart';
import 'device_http_client.dart';

/// Cloud (MQTT via API) first, then LAN, then SoftAP.
/// SoftAP is only a last-resort / setup path — not the default control mode.
class ControlPathResolver {
  ControlPathResolver({
    DeviceHttpClient? http,
    DeviceRepository? cloud,
  })  : _http = http ?? DeviceHttpClient(),
        _cloud = cloud ?? DeviceRepository();

  final DeviceHttpClient _http;
  final DeviceRepository _cloud;

  Future<ControlResult> setPower({
    required String deviceId,
    required String serial,
    required String power,
    String? lanIp,
  }) async {
    final token = await SecureStorage.deviceLocalToken(serial);
    var cachedIp = lanIp ?? await SecureStorage.deviceLanIp(serial);
    if ((cachedIp == null || cachedIp.isEmpty) &&
        deviceDefaultLanIp.isNotEmpty) {
      cachedIp = deviceDefaultLanIp;
    }

    final forced = await SecureStorage.preferredControlPath(serial);
    final lastOk = await SecureStorage.lastControlPath(serial);
    // Forced preference (SoftAP/LAN/Cloud) tries that path only; Auto reorders
    // by last successful path.
    final order = forced != null && forced.isNotEmpty
        ? _forcedPath(forced)
        : _orderedPaths(lastOk);

    Object? lastError;
    for (final path in order) {
      try {
        if (path == ControlPath.softAp) {
          final info = await _http.getInfo(
            softApBaseUrl,
            token: token,
            timeout: const Duration(milliseconds: 350),
          );
          // H2-03: never command a plug whose serial we could not verify.
          if (info.serial.isNotEmpty &&
              info.serial.toUpperCase() == serial.toUpperCase()) {
            final applied = await _http.setPower(
              softApBaseUrl,
              power,
              token: token,
            );
            await SecureStorage.saveLastControlPath(serial, 'softAp');
            return ControlResult(path: ControlPath.softAp, power: applied);
          }
        } else if (path == ControlPath.lan) {
          if (cachedIp == null || cachedIp.isEmpty) continue;
          final base =
              cachedIp.startsWith('http') ? cachedIp : 'http://$cachedIp';
          final info = await _http.getInfo(
            base,
            token: token,
            timeout: const Duration(milliseconds: 450),
          );
          if (info.serial.isNotEmpty &&
              info.serial.toUpperCase() == serial.toUpperCase()) {
            final applied = await _http.setPower(base, power, token: token);
            await SecureStorage.saveDeviceLanIp(serial, cachedIp);
            await SecureStorage.saveLastControlPath(serial, 'lan');
            return ControlResult(path: ControlPath.lan, power: applied);
          }
        } else if (path == ControlPath.cloud) {
          await _cloud.control(deviceId, 'power', power);
          await SecureStorage.saveLastControlPath(serial, 'cloud');
          return ControlResult(path: ControlPath.cloud, power: power);
        }
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? Exception('All control paths failed');
  }

  List<ControlPath> _forcedPath(String key) {
    final pref = switch (key) {
      'softAp' => ControlPath.softAp,
      'lan' => ControlPath.lan,
      'cloud' => ControlPath.cloud,
      _ => null,
    };
    if (pref == null) {
      return const [
        ControlPath.cloud,
        ControlPath.lan,
        ControlPath.softAp,
      ];
    }
    return [pref];
  }

  List<ControlPath> _orderedPaths(String? preferred) {
    const defaultOrder = [
      ControlPath.cloud,
      ControlPath.lan,
      ControlPath.softAp,
    ];
    final pref = switch (preferred) {
      'softAp' => ControlPath.softAp,
      'lan' => ControlPath.lan,
      'cloud' => ControlPath.cloud,
      _ => null,
    };
    if (pref == null) return defaultOrder;
    return [pref, ...defaultOrder.where((p) => p != pref)];
  }
}
