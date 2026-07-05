import '../models/device_models.dart';
import '../../core/network/api_client.dart';

class DeviceRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Device>> list({String? householdId}) async {
    final qs = <String, String>{};
    if (householdId != null) qs['household_id'] = householdId;
    final query = qs.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = '/devices${query.isNotEmpty ? '?$query' : ''}';
    final data = await _api.get<Map<String, dynamic>>(path);
    final list = data['devices'] as List<dynamic>? ?? [];
    return list
        .map((e) => Device.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Device> get(String id) async {
    final data = await _api.get<Map<String, dynamic>>('/devices/$id');
    return Device.fromJson(data);
  }

  Future<void> updateName(String id, String name) async {
    await _api.patch<dynamic>('/devices/$id', body: {'name': name});
  }

  Future<void> control(String id, String command, String value) async {
    await _api.patch<dynamic>(
      '/devices/$id/control',
      body: DeviceControlRequest(command: command, value: value).toJson(),
    );
  }

  Future<void> delete(String id) async {
    await _api.delete<dynamic>('/devices/$id');
  }
}
