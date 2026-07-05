import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/share_models.dart';
import '../../data/repositories/share_repository.dart';

class DeviceShareListNotifier extends AsyncNotifier<List<Share>> {
  late final ShareRepository _repo;
  String? _deviceId;

  @override
  Future<List<Share>> build() async {
    _repo = ShareRepository();
    return [];
  }

  Future<void> fetch(String deviceId) async {
    _deviceId = deviceId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.listDeviceShares(deviceId));
  }

  Future<void> refresh() async {
    if (_deviceId == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.listDeviceShares(_deviceId!));
  }

  Future<bool> create(String phone, String permission) async {
    if (_deviceId == null) return false;
    try {
      await _repo.create(ShareCreateRequest(
        targetPhone: phone,
        scope: 'device',
        scopeId: _deviceId!,
        permission: permission,
      ));
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> revoke(String id) async {
    try {
      await _repo.revoke(id);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final deviceShareListProvider =
    AsyncNotifierProvider<DeviceShareListNotifier, List<Share>>(
  DeviceShareListNotifier.new,
);

class IncomingShareListNotifier extends AsyncNotifier<List<Share>> {
  late final ShareRepository _repo;

  @override
  Future<List<Share>> build() async {
    _repo = ShareRepository();
    return _fetch();
  }

  Future<List<Share>> _fetch() async {
    return _repo.listIncoming();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<bool> accept(String id) async {
    try {
      await _repo.accept(id);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> decline(String id) async {
    try {
      await _repo.decline(id);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final incomingShareListProvider =
    AsyncNotifierProvider<IncomingShareListNotifier, List<Share>>(
  IncomingShareListNotifier.new,
);
