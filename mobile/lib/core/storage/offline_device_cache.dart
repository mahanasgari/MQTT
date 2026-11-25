import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/device_models.dart';

/// Persists the last-known device list to SharedPreferences so the app can
/// show stale data when the API is unreachable (e.g. no internet, SoftAP or
/// LAN-only mode).
class OfflineDeviceCache {
  OfflineDeviceCache._();

  static const _key = 'offline_device_cache_v1';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  /// Persist [devices] to local storage (full replace).
  static Future<void> save(List<Device> devices) async {
    final prefs = await _prefs;
    final json = jsonEncode(devices.map((d) => d.toJson()).toList());
    await prefs.setString(_key, json);
  }

  /// Return the cached device list, or `null` if nothing is stored.
  static Future<List<Device>?> load() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }

  static Future<void> removeId(String id) async {
    final cached = await load();
    if (cached == null) return;
    await save(cached.where((d) => d.id != id).toList());
  }

  static Future<void> removeIds(Iterable<String> ids) async {
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    final cached = await load();
    if (cached == null) return;
    await save(cached.where((d) => !idSet.contains(d.id)).toList());
  }
}

/// Pure merge used when a household-filtered API list arrives.
/// Keeps devices from other households; replaces the filtered household's rows.
/// [excludeIds] never re-enter the cache (local deletes / tombstones).
List<Device> mergeHouseholdCache({
  required List<Device> cached,
  required List<Device> fetched,
  required String householdId,
  Set<String> excludeIds = const {},
}) {
  final others = cached.where(
    (d) => d.householdId != householdId && !excludeIds.contains(d.id),
  );
  final next = fetched.where((d) => !excludeIds.contains(d.id));
  return [...others, ...next];
}

List<Device> excludeDeviceIds(List<Device> devices, Set<String> excludeIds) {
  if (excludeIds.isEmpty) return devices;
  return devices.where((d) => !excludeIds.contains(d.id)).toList();
}
