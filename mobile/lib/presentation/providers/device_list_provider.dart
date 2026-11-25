import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/offline_device_cache.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/models/api_error.dart';
import '../../data/models/device_models.dart';
import '../../data/repositories/device_repository.dart';

/// `true` when the device list was loaded from the offline cache because the
/// API was unreachable.  Consumers can use this to show an offline banner.
final deviceListIsOfflineProvider = StateProvider<bool>((ref) => false);

class DeviceListNotifier extends AsyncNotifier<List<Device>> {
  late final DeviceRepository _repo;
  String? _currentHouseholdId;

  /// Bumped on remove / new fetch so in-flight list responses cannot resurrect
  /// rows that the user just deleted.
  int _listEpoch = 0;

  /// Local deletes that must not reappear from a stale response or cache merge.
  /// Cleared when a successful API list confirms the id is gone (or present again
  /// after a soft-delete re-add — see [_reconcileTombstones]).
  final Set<String> _removedIds = {};

  @override
  Future<List<Device>> build() async {
    _repo = DeviceRepository();
    return [];
  }

  Future<List<Device>> _fetch() async {
    return _repo.list(householdId: _currentHouseholdId);
  }

  Future<void> fetch({String? householdId}) async {
    _currentHouseholdId = householdId;
    final epoch = ++_listEpoch;
    state = const AsyncValue.loading();
    try {
      final devices = await _fetch();
      if (epoch != _listEpoch) return;
      await _applyServerList(devices, householdId);
    } catch (e, st) {
      if (epoch != _listEpoch) return;
      final cached = await OfflineDeviceCache.load();
      if (cached != null) {
        ref.read(deviceListIsOfflineProvider.notifier).state = true;
        state = AsyncValue.data(
          _filterCached(excludeDeviceIds(cached, _removedIds)),
        );
      } else {
        ref.read(deviceListIsOfflineProvider.notifier).state = false;
        state = AsyncValue.error(e, st);
      }
    }
    if (epoch == _listEpoch) await _cacheLanIps();
  }

  List<Device> _filterCached(List<Device> cached) {
    final hid = _currentHouseholdId;
    if (hid == null) return cached;
    return cached.where((d) => d.householdId == hid).toList();
  }

  Future<void> refresh() async {
    final epoch = ++_listEpoch;
    try {
      final devices = await _fetch();
      if (epoch != _listEpoch) return;
      await _applyServerList(devices, _currentHouseholdId);
    } catch (e, st) {
      if (epoch != _listEpoch) return;
      final cached = await OfflineDeviceCache.load();
      if (cached != null) {
        ref.read(deviceListIsOfflineProvider.notifier).state = true;
        state = AsyncValue.data(
          _filterCached(excludeDeviceIds(cached, _removedIds)),
        );
      } else {
        ref.read(deviceListIsOfflineProvider.notifier).state = false;
        state = AsyncValue.error(e, st);
      }
    }
    if (epoch == _listEpoch) await _cacheLanIps();
  }

  Future<void> _applyServerList(
    List<Device> devices,
    String? householdId,
  ) async {
    _reconcileTombstones(devices);
    final visible = excludeDeviceIds(devices, _removedIds);
    await _persistCache(visible, householdId);
    ref.read(deviceListIsOfflineProvider.notifier).state = false;
    state = AsyncValue.data(visible);
  }

  void _reconcileTombstones(List<Device> serverDevices) {
    final serverIds = serverDevices.map((d) => d.id).toSet();
    // Confirmed gone on server — drop tombstone.
    _removedIds.removeWhere((id) => !serverIds.contains(id));
  }

  /// Allow a soft-deleted device that was just re-registered to show up even if
  /// a tombstone was still held from a lagging delete response.
  void clearRemovedId(String id) {
    _removedIds.remove(id);
  }

  Future<void> _persistCache(List<Device> devices, String? householdId) async {
    if (householdId == null) {
      await OfflineDeviceCache.save(excludeDeviceIds(devices, _removedIds));
      return;
    }
    final cached = await OfflineDeviceCache.load() ?? [];
    final merged = mergeHouseholdCache(
      cached: cached,
      fetched: devices,
      householdId: householdId,
      excludeIds: _removedIds,
    );
    await OfflineDeviceCache.save(merged);
  }

  /// Remove from the account (API) and from the phone's cached list.
  /// A 404 means it is already gone on the server — still drop it locally.
  Future<bool> removeDevice(String id, {String? serial}) async {
    _listEpoch++;
    _removedIds.add(id);

    final current = state.valueOrNull;
    Device? removedRow;
    if (current != null) {
      for (final d in current) {
        if (d.id == id) {
          removedRow = d;
          break;
        }
      }
      state = AsyncValue.data(current.where((d) => d.id != id).toList());
    }
    await OfflineDeviceCache.removeId(id);
    final serialToClear = serial ?? removedRow?.serial;
    if (serialToClear != null && serialToClear.isNotEmpty) {
      await SecureStorage.clearDeviceLanIp(serialToClear);
    }

    try {
      await _repo.delete(id);
    } on ApiError catch (e) {
      if (!e.isNotFound) {
        // Delete failed — restore so the user can retry.
        _removedIds.remove(id);
        await refresh();
        return false;
      }
    } catch (_) {
      // Offline / unknown — keep local removal; next online sync reconciles.
    }
    return true;
  }

  Future<void> _cacheLanIps() async {
    final devices = state.valueOrNull;
    if (devices == null) return;
    for (final d in devices) {
      final ip = d.lanIp;
      if (ip != null && ip.isNotEmpty) {
        await SecureStorage.saveDeviceLanIp(d.serial, ip);
      }
    }
  }

  void applyLiveUpdate(String deviceId, Map<String, dynamic> data) {
    if (_removedIds.contains(deviceId)) return;
    final lanIp = data['lan_ip'] as String? ?? data['ip'] as String?;
    final wifiSsid = data['wifi_ssid'] as String? ?? data['ssid'] as String?;
    final incomingTs = data['last_changed_at'] as String?;
    final updated = state.whenOrNull(
      data: (devices) => [
        for (final d in devices)
          if (d.id == deviceId)
            d.copyWith(
              lanIp: (lanIp != null && lanIp.isNotEmpty) ? lanIp : null,
              wifiSsid:
                  (wifiSsid != null && wifiSsid.isNotEmpty) ? wifiSsid : null,
              state: () {
                // H2-14: ignore stale power echoes older than current UI state.
                final current = d.state;
                final powerUpdate = data['power'] as String?;
                if (powerUpdate != null &&
                    incomingTs != null &&
                    current != null &&
                    current.lastChangedAt.isNotEmpty) {
                  final incoming = DateTime.tryParse(incomingTs);
                  final existing = DateTime.tryParse(current.lastChangedAt);
                  if (incoming != null &&
                      existing != null &&
                      incoming.isBefore(existing)) {
                    return current.copyWith(
                      connectivity: data['connectivity'] as String?,
                    );
                  }
                }
                if (current != null) {
                  return current.copyWith(
                    power: powerUpdate,
                    connectivity: data['connectivity'] as String?,
                    lastChangedAt: incomingTs,
                  );
                }
                return DeviceState(
                  power: powerUpdate ?? 'off',
                  connectivity: data['connectivity'] as String? ?? 'offline',
                  lastChangedAt: incomingTs ?? '',
                  lastSeenAt: '',
                );
              }(),
            )
          else
            d,
      ],
    );
    if (updated != null) {
      state = AsyncValue.data(updated);
      if (lanIp != null && lanIp.isNotEmpty) {
        final match = updated.where((d) => d.id == deviceId);
        if (match.isNotEmpty) {
          SecureStorage.saveDeviceLanIp(match.first.serial, lanIp);
        }
      }
    }
  }
}

final deviceListProvider =
    AsyncNotifierProvider<DeviceListNotifier, List<Device>>(
  DeviceListNotifier.new,
);
