import '../models/event_models.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';

class EventRepository {
  final ApiClient _api = ApiClient.instance;

  Future<PaginatedEvents> getDeviceEvents(
    String deviceId, {
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    String? from,
    String? to,
  }) async {
    final qs = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (from != null) qs['from'] = from;
    if (to != null) qs['to'] = to;
    final query = qs.entries.map((e) => '${e.key}=${e.value}').join('&');
    final data = await _api.get<Map<String, dynamic>>(
      '/devices/$deviceId/events?$query',
    );
    return PaginatedEvents.fromJson(data);
  }
}
