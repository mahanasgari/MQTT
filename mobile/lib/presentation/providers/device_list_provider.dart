import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_models.dart';
import '../../data/repositories/device_repository.dart';

class DeviceListNotifier extends AsyncNotifier<List<Device>> {
  late final DeviceRepository _repo;
  String? _currentHouseholdId;

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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetch());
  }

  void applyLiveUpdate(String deviceId, Map<String, dynamic> data) {
    final updated = state.whenOrNull(
      data: (devices) => [
        for (final d in devices)
          if (d.id == deviceId)
            d.copyWith(
              state: d.state != null
                  ? d.state!.copyWith(
                      power: data['power'] as String?,
                      connectivity: data['connectivity'] as String?,
                      lastChangedAt: data['last_changed_at'] as String?,
                    )
                  : DeviceState(
                      power: data['power'] as String? ?? 'off',
                      connectivity:
                          data['connectivity'] as String? ?? 'offline',
                      lastChangedAt: data['last_changed_at'] as String? ?? '',
                      lastSeenAt: '',
                    ),
            )
          else
            d,
      ],
    );
    if (updated != null) {
      state = AsyncValue.data(updated);
    }
  }
}

final deviceListProvider =
    AsyncNotifierProvider<DeviceListNotifier, List<Device>>(
  DeviceListNotifier.new,
);
