import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_models.dart';
import '../../data/repositories/device_repository.dart';

class DeviceDetailNotifier extends AsyncNotifier<Device> {
  late final DeviceRepository _repo;
  String? _deviceId;

  @override
  Future<Device> build() async {
    _repo = DeviceRepository();
    return Future.error('Call fetch(id) first');
  }

  Future<void> fetch(String deviceId) async {
    _deviceId = deviceId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.get(deviceId));
  }

  Future<void> refresh() async {
    if (_deviceId == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.get(_deviceId!));
  }

  Future<bool> updateName(String name) async {
    if (_deviceId == null) return false;
    try {
      await _repo.updateName(_deviceId!, name);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  void applyLiveUpdate(Map<String, dynamic> data) {
    final updated = state.whenOrNull(
      data: (device) => device.copyWith(
        state: device.state != null
            ? device.state!.copyWith(
                power: data['power'] as String?,
                connectivity: data['connectivity'] as String?,
                lastChangedAt: data['last_changed_at'] as String?,
              )
            : DeviceState(
                power: data['power'] as String? ?? 'off',
                connectivity: data['connectivity'] as String? ?? 'offline',
                lastChangedAt: data['last_changed_at'] as String? ?? '',
                lastSeenAt: '',
              ),
      ),
    );
    if (updated != null) {
      state = AsyncValue.data(updated);
    }
  }
}

final deviceDetailProvider =
    AsyncNotifierProvider<DeviceDetailNotifier, Device>(
  DeviceDetailNotifier.new,
);
