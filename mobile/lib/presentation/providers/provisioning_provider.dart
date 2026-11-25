import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_models.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/provisioning_repository.dart';
import '../utils/provision_error.dart';
import 'device_list_provider.dart';
import 'household_provider.dart';

class ProvisioningState {
  final bool isClaiming;
  final bool isLinking;
  final bool isPolling;
  final bool isProvisioning;
  final Device? registeredDevice;
  final List<Device> unlinkedDevices;
  final String? error;
  final String? claimedDeviceId;
  /// Pairing token fetched while online, before joining SoftAP.
  final String? pendingPairingToken;
  final String? pendingSerial;
  final String? pendingName;
  /// Existing device: send Wi‑Fi only, do not re-register.
  final bool wifiOnly;

  const ProvisioningState({
    this.isClaiming = false,
    this.isLinking = false,
    this.isPolling = false,
    this.isProvisioning = false,
    this.registeredDevice,
    this.unlinkedDevices = const [],
    this.error,
    this.claimedDeviceId,
    this.pendingPairingToken,
    this.pendingSerial,
    this.pendingName,
    this.wifiOnly = false,
  });
}

class ProvisioningNotifier extends Notifier<ProvisioningState> {
  late final ProvisioningRepository _repo;
  late final DeviceRepository _devices;
  Timer? _pollTimer;
  int _cloudWaitEpoch = 0;

  @override
  ProvisioningState build() {
    _repo = ProvisioningRepository();
    _devices = DeviceRepository();
    ref.onDispose(() => _pollTimer?.cancel());
    return const ProvisioningState();
  }

  Future<bool> claimDevice(String serial, String token, {String? name}) async {
    state = ProvisioningState(isClaiming: true, error: null);
    try {
      final device = await _repo.register(serial, token, name: name);
      state = ProvisioningState(
        registeredDevice: device,
        claimedDeviceId: device.id,
        isClaiming: false,
      );
      ref.read(deviceListProvider.notifier).clearRemovedId(device.id);
      ref.read(deviceListProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = ProvisioningState(
        isClaiming: false,
        error: mapProvisionException(e),
      );
      return false;
    }
  }

  String? _preferredHouseholdId() {
    final list = ref.read(householdListProvider).valueOrNull;
    if (list == null || list.isEmpty) return null;
    return list.first.id;
  }

  Future<String?> fetchPairingToken(String serial) async {
    state = ProvisioningState(
      isClaiming: true,
      error: null,
      registeredDevice: state.registeredDevice,
      claimedDeviceId: state.claimedDeviceId,
    );
    try {
      final response = await _repo.createPairingToken(
        serial: serial,
        householdId: _preferredHouseholdId(),
      );
      state = ProvisioningState(
        registeredDevice: state.registeredDevice,
        claimedDeviceId: state.claimedDeviceId,
      );
      return response.token;
    } catch (e) {
      state = ProvisioningState(
        error: mapProvisionException(e),
        registeredDevice: state.registeredDevice,
        claimedDeviceId: state.claimedDeviceId,
      );
      return null;
    }
  }

  /// Call while the phone still has internet — before joining SoftAP.
  Future<bool> prepareApOnline({
    required String serial,
    String? name,
  }) async {
    final normalizedSerial = serial.trim().toUpperCase();
    state = ProvisioningState(
      isProvisioning: true,
      error: null,
      pendingSerial: normalizedSerial,
      pendingName: name,
    );
    try {
      final tokenResponse = await _repo.createPairingToken(
        serial: normalizedSerial,
        householdId: _preferredHouseholdId(),
      );
      state = ProvisioningState(
        pendingPairingToken: tokenResponse.token,
        pendingSerial: normalizedSerial,
        pendingName: name,
        wifiOnly: false,
      );
      return true;
    } catch (e) {
      state = ProvisioningState(
        error: mapProvisionException(e),
        pendingSerial: normalizedSerial,
        pendingName: name,
        wifiOnly: false,
      );
      return false;
    }
  }

  /// Change Wi‑Fi on a plug that is already in the account (no new pairing token).
  void prepareWifiChange({required String serial, String? name}) {
    state = ProvisioningState(
      pendingSerial: serial.trim().toUpperCase(),
      pendingName: name,
      pendingPairingToken: '',
      wifiOnly: true,
    );
  }

  /// SoftAP-only: push Wi‑Fi creds + cached pairing token to the plug.
  Future<bool> sendApWifiCreds({
    required String ssid,
    required String password,
  }) async {
    final token = state.pendingPairingToken ?? '';
    final serial = state.pendingSerial;
    final wifiOnly = state.wifiOnly;
    if (serial == null || serial.isEmpty) {
      state = ProvisioningState(
        error: ProvisionErrorCode.missingSerial,
        pendingPairingToken: token,
        pendingSerial: serial,
        pendingName: state.pendingName,
        wifiOnly: wifiOnly,
      );
      return false;
    }
    if (!wifiOnly && token.isEmpty) {
      state = ProvisioningState(
        error: ProvisionErrorCode.missingToken,
        pendingPairingToken: token,
        pendingSerial: serial,
        pendingName: state.pendingName,
        wifiOnly: wifiOnly,
      );
      return false;
    }

    state = ProvisioningState(
      isProvisioning: true,
      pendingPairingToken: token,
      pendingSerial: serial,
      pendingName: state.pendingName,
      wifiOnly: wifiOnly,
    );

    try {
      await _repo.configureDeviceAp(
        ssid: ssid,
        password: password,
        serial: serial,
        token: token,
      );
      state = ProvisioningState(
        pendingPairingToken: token,
        pendingSerial: serial,
        pendingName: state.pendingName,
        wifiOnly: wifiOnly,
      );
      return true;
    } catch (e) {
      state = ProvisioningState(
        error: mapProvisionException(e),
        pendingPairingToken: token,
        pendingSerial: serial,
        pendingName: state.pendingName,
        wifiOnly: wifiOnly,
      );
      return false;
    }
  }

  /// After SoftAP: rejoin home Wi‑Fi / internet, then register with cloud.
  Future<Device?> finishApCloudRegister({
    Duration interval = const Duration(seconds: 3),
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final token = state.pendingPairingToken;
    final serial = state.pendingSerial;
    final name = state.pendingName;
    if (token == null || serial == null) {
      state = const ProvisioningState(
        error: ProvisionErrorCode.missingToken,
      );
      return null;
    }

    state = ProvisioningState(
      isPolling: true,
      pendingPairingToken: token,
      pendingSerial: serial,
      pendingName: name,
      wifiOnly: state.wifiOnly,
    );

    final epoch = ++_cloudWaitEpoch;
    final stopwatch = Stopwatch()..start();
    Object? lastError;
    while (stopwatch.elapsed < timeout) {
      if (epoch != _cloudWaitEpoch) return null;
      try {
        final device = await _repo.register(serial, token, name: name);
        if (epoch != _cloudWaitEpoch) return null;
        state = ProvisioningState(
          isPolling: true,
          registeredDevice: device,
          claimedDeviceId: device.id,
          pendingPairingToken: token,
          pendingSerial: serial,
          pendingName: name,
        );
        ref.read(deviceListProvider.notifier).clearRemovedId(device.id);
        // H1-03: do not celebrate until MQTT/online is proven.
        final online = await waitUntilDeviceOnline(
          deviceId: device.id,
          epoch: epoch,
        );
        if (epoch != _cloudWaitEpoch) return null;
        if (online != null) {
          ref.read(deviceListProvider.notifier).refresh();
          return online;
        }
        return null;
      } catch (e) {
        lastError = e;
        if (isFatalRegisterError(e)) break;
        await Future.delayed(interval);
      }
    }

    if (epoch != _cloudWaitEpoch) return null;
    state = ProvisioningState(
      error: lastError != null
          ? mapProvisionException(lastError)
          : ProvisionErrorCode.timeout,
      pendingPairingToken: token,
      pendingSerial: serial,
      pendingName: name,
      wifiOnly: state.wifiOnly,
    );
    return null;
  }

  /// Poll cloud state until the plug reports online, or time out (H1-03).
  /// Pass [epoch] to share cancellation with [finishApCloudRegister] / Change Wi‑Fi wait.
  Future<Device?> waitUntilDeviceOnline({
    String? deviceId,
    String? serial,
    int? epoch,
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final waitEpoch = epoch ?? ++_cloudWaitEpoch;
    final id = deviceId ?? state.claimedDeviceId ?? state.registeredDevice?.id;
    final wantSerial = (serial ?? state.pendingSerial)?.toUpperCase();

    state = ProvisioningState(
      isPolling: true,
      registeredDevice: state.registeredDevice,
      claimedDeviceId: state.claimedDeviceId ?? id,
      pendingPairingToken: state.pendingPairingToken,
      pendingSerial: state.pendingSerial ?? wantSerial,
      pendingName: state.pendingName,
      wifiOnly: state.wifiOnly,
    );

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      if (waitEpoch != _cloudWaitEpoch) return null;
      try {
        Device? device;
        if (id != null && id.isNotEmpty) {
          device = await _devices.get(id);
        } else if (wantSerial != null && wantSerial.isNotEmpty) {
          final list = await _devices.list();
          for (final d in list) {
            if (d.serial.toUpperCase() == wantSerial) {
              device = d;
              break;
            }
          }
        }
        if (device != null && device.state?.isOnline == true) {
          state = ProvisioningState(
            registeredDevice: device,
            claimedDeviceId: device.id,
          );
          ref.read(deviceListProvider.notifier).clearRemovedId(device.id);
          ref.read(deviceListProvider.notifier).refresh();
          return device;
        }
      } catch (_) {
        // Keep polling through transient network blips after SoftAP.
      }
      await Future.delayed(interval);
    }

    if (waitEpoch != _cloudWaitEpoch) return null;
    state = ProvisioningState(
      error: ProvisionErrorCode.pollTimeout,
      registeredDevice: state.registeredDevice,
      claimedDeviceId: state.claimedDeviceId ?? id,
      pendingPairingToken: state.pendingPairingToken,
      pendingSerial: state.pendingSerial ?? wantSerial,
      pendingName: state.pendingName,
      wifiOnly: state.wifiOnly,
    );
    return null;
  }

  /// Legacy one-shot path (token → SoftAP → register). Prefer the split APIs above.
  Future<Device?> startApProvisioning({
    required String ssid,
    required String password,
    required String serial,
    String? name,
  }) async {
    final ok = await prepareApOnline(serial: serial, name: name);
    if (!ok) return null;
    final sent = await sendApWifiCreds(ssid: ssid, password: password);
    if (!sent) return null;
    return finishApCloudRegister();
  }

  Future<bool> linkDevice(String householdId, {String? name}) async {
    final deviceId = state.claimedDeviceId ?? state.registeredDevice?.id;
    if (deviceId == null) {
      state = const ProvisioningState(
        error: ProvisionErrorCode.missingToken,
      );
      return false;
    }
    state = ProvisioningState(
      isLinking: true,
      claimedDeviceId: deviceId,
      registeredDevice: state.registeredDevice,
      error: null,
    );
    try {
      await _repo.link(deviceId, householdId, name: name);
      ref.read(deviceListProvider.notifier).refresh();
      state = ProvisioningState(
        isLinking: false,
        claimedDeviceId: deviceId,
        registeredDevice: state.registeredDevice,
      );
      return true;
    } catch (e) {
      state = ProvisioningState(
        isLinking: false,
        claimedDeviceId: deviceId,
        registeredDevice: state.registeredDevice,
        error: mapProvisionException(e),
      );
      return false;
    }
  }

  Future<Device?> pollForUnlinkedDevice({
    Duration interval = const Duration(seconds: 5),
    Duration timeout = const Duration(seconds: 60),
  }) async {
    state = ProvisioningState(isPolling: true);
    final stopwatch = Stopwatch()..start();
    try {
      while (stopwatch.elapsed < timeout) {
        final devices = await _repo.getUnlinked();
        if (devices.isNotEmpty) {
          final device = devices.first;
          state = ProvisioningState(
            isPolling: false,
            registeredDevice: device,
            claimedDeviceId: device.id,
            unlinkedDevices: devices,
          );
          return device;
        }
        await Future.delayed(interval);
      }
      state = ProvisioningState(
        isPolling: false,
        error: ProvisionErrorCode.pollTimeout,
      );
      return null;
    } catch (e) {
      state = ProvisioningState(
        isPolling: false,
        error: mapProvisionException(e),
      );
      return null;
    }
  }

  void cancelCloudWait() {
    _cloudWaitEpoch++;
    // Clear polling so UI does not treat cancel as a hard failure (H2-03/H2-05).
    if (state.isPolling || state.isProvisioning) {
      state = ProvisioningState(
        registeredDevice: state.registeredDevice,
        claimedDeviceId: state.claimedDeviceId,
        pendingPairingToken: state.pendingPairingToken,
        pendingSerial: state.pendingSerial,
        pendingName: state.pendingName,
        wifiOnly: state.wifiOnly,
      );
    }
  }

  void clearError() {
    state = ProvisioningState(
      registeredDevice: state.registeredDevice,
      claimedDeviceId: state.claimedDeviceId,
      pendingPairingToken: state.pendingPairingToken,
      pendingSerial: state.pendingSerial,
      pendingName: state.pendingName,
      wifiOnly: state.wifiOnly,
    );
  }

  /// SoftAP left the phone offline — keep the pairing token for retry.
  void setNetworkError() {
    state = ProvisioningState(
      error: ProvisionErrorCode.network,
      registeredDevice: state.registeredDevice,
      claimedDeviceId: state.claimedDeviceId,
      pendingPairingToken: state.pendingPairingToken,
      pendingSerial: state.pendingSerial,
      pendingName: state.pendingName,
      wifiOnly: state.wifiOnly,
    );
  }

  void reset() {
    _pollTimer?.cancel();
    state = const ProvisioningState();
  }
}

final provisioningProvider =
    NotifierProvider<ProvisioningNotifier, ProvisioningState>(
  ProvisioningNotifier.new,
);
