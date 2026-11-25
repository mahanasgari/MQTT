import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/control_path_resolver.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/models/control_path.dart';
import '../../data/models/device_models.dart';
import 'device_detail_provider.dart';
import 'device_list_provider.dart';

class DeviceControlState {
  final bool isLoading;
  final String? error;
  final String? pendingDeviceId;
  final ControlPath? lastPath;

  const DeviceControlState({
    this.isLoading = false,
    this.error,
    this.pendingDeviceId,
    this.lastPath,
  });
}

class DeviceControlNotifier extends Notifier<DeviceControlState> {
  late final ControlPathResolver _resolver;
  /// Per-device rollback snapshots (H2-02).
  final Map<String, DeviceState?> _savedByDevice = {};

  @override
  DeviceControlState build() {
    _resolver = ControlPathResolver();
    return const DeviceControlState();
  }

  /// Toggle power via SoftAP → LAN → Cloud.
  Future<ControlResult?> togglePower({
    required String deviceId,
    required String serial,
    required String nextPower,
    DeviceState? currentState,
    String? lanIp,
  }) async {
    // Reject concurrent toggles — one in flight at a time (H2-02 / H2-09).
    if (state.isLoading) return null;

    _savedByDevice[deviceId] = currentState;

    state = DeviceControlState(
      isLoading: true,
      pendingDeviceId: deviceId,
      lastPath: state.lastPath,
    );

    _applyOptimisticUpdate(deviceId, nextPower);

    try {
      if (lanIp != null && lanIp.isNotEmpty) {
        await SecureStorage.saveDeviceLanIp(serial, lanIp);
      }

      final result = await _resolver.setPower(
        deviceId: deviceId,
        serial: serial,
        power: nextPower,
        lanIp: lanIp,
      );

      _savedByDevice.remove(deviceId);
      state = DeviceControlState(lastPath: result.path);
      return result;
    } catch (e) {
      _rollback(deviceId);
      _savedByDevice.remove(deviceId);
      state = DeviceControlState(error: e.toString());
      return null;
    }
  }

  @Deprecated('Use togglePower for SoftAP/LAN/cloud routing')
  Future<bool> sendCommand(
    String deviceId,
    String command,
    String value,
    DeviceState? currentState, {
    String? serial,
    String? lanIp,
  }) async {
    if (command != 'power' || serial == null) {
      state = const DeviceControlState(error: 'Unsupported command');
      return false;
    }
    final result = await togglePower(
      deviceId: deviceId,
      serial: serial,
      nextPower: value,
      currentState: currentState,
      lanIp: lanIp,
    );
    return result != null;
  }

  void _applyOptimisticUpdate(String deviceId, String newPower) {
    final now = DateTime.now().toUtc().toIso8601String();
    final update = <String, dynamic>{
      'power': newPower,
      'last_changed_at': now,
    };
    ref.read(deviceListProvider.notifier).applyLiveUpdate(deviceId, update);
    ref.read(deviceDetailProvider.notifier).applyLiveUpdate(deviceId, update);
  }

  void _rollback(String deviceId) {
    final saved = _savedByDevice[deviceId];
    if (saved == null) return;
    final update = <String, dynamic>{
      'power': saved.power,
      'last_changed_at': saved.lastChangedAt,
    };
    ref.read(deviceListProvider.notifier).applyLiveUpdate(deviceId, update);
    ref.read(deviceDetailProvider.notifier).applyLiveUpdate(deviceId, update);
  }

  void clearError() {
    state = DeviceControlState(lastPath: state.lastPath);
  }
}

final deviceControlProvider =
    NotifierProvider<DeviceControlNotifier, DeviceControlState>(
  DeviceControlNotifier.new,
);
