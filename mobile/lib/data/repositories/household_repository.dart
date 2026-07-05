import '../models/household_models.dart';
import '../../core/network/api_client.dart';

class HouseholdRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Household>> list() async {
    final data = await _api.get<Map<String, dynamic>>('/households');
    final list = data['households'] as List<dynamic>? ?? [];
    return list
        .map((e) => Household.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Household> create(String name, {String? timezone}) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/households',
      body: HouseholdCreateRequest(name: name, timezone: timezone).toJson(),
    );
    return Household.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _api.delete<dynamic>('/households/$id');
  }
}
