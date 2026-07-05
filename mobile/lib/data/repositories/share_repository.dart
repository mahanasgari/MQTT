import '../models/share_models.dart';
import '../../core/network/api_client.dart';

class ShareRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Share>> listDeviceShares(String deviceId) async {
    final data =
        await _api.get<Map<String, dynamic>>('/devices/$deviceId/shares');
    final list = data['shares'] as List<dynamic>? ?? [];
    return list
        .map((e) => Share.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Share>> listMyShares() async {
    final data = await _api.get<Map<String, dynamic>>('/shares');
    final list = data['shares'] as List<dynamic>? ?? [];
    return list
        .map((e) => Share.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Share>> listIncoming() async {
    final data = await _api.get<Map<String, dynamic>>('/shares/incoming');
    final list = data['shares'] as List<dynamic>? ?? [];
    return list
        .map((e) => Share.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(ShareCreateRequest req) async {
    await _api.post<dynamic>('/shares', body: req.toJson());
  }

  Future<void> accept(String id) async {
    await _api.patch<dynamic>(
      '/shares/$id',
      body: ShareUpdateRequest(status: 'accepted').toJson(),
    );
  }

  Future<void> decline(String id) async {
    await _api.patch<dynamic>(
      '/shares/$id',
      body: ShareUpdateRequest(status: 'declined').toJson(),
    );
  }

  Future<void> revoke(String id) async {
    await _api.delete<dynamic>('/shares/$id');
  }
}
