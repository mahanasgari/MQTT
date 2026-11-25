import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_models.dart';
import '../../data/repositories/device_repository.dart';

class DeviceDetailNotifier extends AsyncNotifier<Device> {
  late final DeviceRepository _repo;
  String? _deviceId;
  int _fetchGen = 0;

  @override
  Future<Device> build() async {
    _repo = DeviceRepository();
    ref.onDispose(() => _fetchGen++);
    // Stay loading until [fetch] — avoids flashing a fake error on first paint (H2-08).
    return Completer<Device>().future;
  }

  Future<void> fetch(String deviceId) async {
    _deviceId = deviceId;
    final gen = ++_fetchGen;
    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() => _repo.get(deviceId));
    if (gen != _fetchGen) return;
    state = next;
  }

  Future<void> refresh() async {
    if (_deviceId == null) return;
    final gen = ++_fetchGen;
    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() => _repo.get(_deviceId!));
    if (gen != _fetchGen) return;
    state = next;
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

  void applyLiveUpdate(String deviceId, Map<String, dynamic> data) {
    // H2-01: ignore updates for a different device than the open detail.
    if (_deviceId == null || _deviceId != deviceId) return;
    final lanIp = data['lan_ip'] as String? ?? data['ip'] as String?;
    final wifiSsid = data['wifi_ssid'] as String? ?? data['ssid'] as String?;
    final updated = state.whenOrNull(
      data: (device) => device.copyWith(
        lanIp: (lanIp != null && lanIp.isNotEmpty) ? lanIp : null,
        wifiSsid:
            (wifiSsid != null && wifiSsid.isNotEmpty) ? wifiSsid : null,
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
