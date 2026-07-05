import '../../core/network/api_client.dart';
import '../../core/network/device_ap_client.dart';
import '../models/device_models.dart';
import '../models/provisioning_models.dart';

class ProvisioningRepository {
  final ApiClient _api = ApiClient.instance;

  Future<PairingTokenResponse> createPairingToken({
    String? householdId,
    String? serial,
  }) async {
    final body = ProvisionPairingTokenRequest(
      householdId: householdId,
      serial: serial?.toUpperCase(),
    );
    final data = await _api.post<Map<String, dynamic>>(
      '/devices/pairing-token',
      body: body.toJson(),
    );
    return PairingTokenResponse.fromJson(data);
  }

  Future<Device> register(String serial, String token, {String? name}) async {
    final body = DeviceRegisterRequest(serial: serial, token: token, name: name);
    final data = await _api.post<Map<String, dynamic>>(
      '/devices/register',
      body: body.toJson(),
    );
    return Device.fromJson(data);
  }

  Future<void> link(String deviceId, String householdId, {String? name}) async {
    final body = DeviceLinkRequest(householdId: householdId, name: name);
    await _api.patch<dynamic>(
      '/devices/$deviceId/link',
      body: body.toJson(),
    );
  }

  Future<void> configureDeviceAp({
    required String ssid,
    required String password,
    required String serial,
    required String token,
  }) {
    return DeviceApClient.configure(
      ssid: ssid,
      password: password,
      serial: serial,
      token: token,
    );
  }

  Future<List<Device>> getUnlinked() async {
    final data = await _api.get<Map<String, dynamic>>('/devices?linked=false');
    final list = data['devices'] as List<dynamic>? ?? [];
    return list
        .map((e) => Device.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
