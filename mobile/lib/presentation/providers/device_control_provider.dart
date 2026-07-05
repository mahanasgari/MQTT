import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_models.dart';
import '../../data/repositories/device_repository.dart';
import 'device_detail_provider.dart';
import 'device_list_provider.dart';

class DeviceControlState {
  final bool isLoading;
  final String? error;
  final String? pendingDeviceId;

  const DeviceControlState({
    this.isLoading = false,
    this.error,
    this.pendingDeviceId,
  });
}

class DeviceControlNotifier extends Notifier<DeviceControlState> {
  late final DeviceRepository _repo;
  DeviceState? _savedState;

  @override
  DeviceControlState build() {
    _repo = DeviceRepository();
    return const DeviceControlState();
  }

  Future<bool> sendCommand(
    String deviceId,
    String command,
    String value,
    DeviceState? currentState,
  ) async {
    final newPower = command == 'power' ? value : null;

    _savedState = currentState;

    state = DeviceControlState(
      isLoading: true,
      pendingDeviceId: deviceId,
    );

    if (newPower != null) {
      _applyOptimisticUpdate(deviceId, newPower);
    }

    try {
      await _repo.control(deviceId, command, value);
      state = const DeviceControlState();
      return true;
    } catch (e) {
      if (newPower != null) {
        _rollback(deviceId);
      }
      state = DeviceControlState(error: e.toString());
      return false;
    }
  }

  void _applyOptimisticUpdate(String deviceId, String newPower) {
    final now = DateTime.now().toUtc().toIso8601String();
    final update = <String, dynamic>{
      'power': newPower,
      'last_changed_at': now,
    };
    ref.read(deviceListProvider.notifier).applyLiveUpdate(deviceId, update);
    ref.read(deviceDetailProvider.notifier).applyLiveUpdate(update);
  }

  void _rollback(String deviceId) {
    if (_savedState == null) return;
    final update = <String, dynamic>{
      'power': _savedState!.power,
      'last_changed_at': _savedState!.lastChangedAt,
    };
    ref.read(deviceListProvider.notifier).applyLiveUpdate(deviceId, update);
    ref.read(deviceDetailProvider.notifier).applyLiveUpdate(update);
  }

  void clearError() {
    state = const DeviceControlState();
  }
}

final deviceControlProvider =
    NotifierProvider<DeviceControlNotifier, DeviceControlState>(
  DeviceControlNotifier.new,
);
