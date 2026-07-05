import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_models.dart';
import '../../data/repositories/provisioning_repository.dart';
import 'device_list_provider.dart';

class ProvisioningState {
  final bool isClaiming;
  final bool isLinking;
  final bool isPolling;
  final bool isProvisioning;
  final Device? registeredDevice;
  final List<Device> unlinkedDevices;
  final String? error;
  final String? claimedDeviceId;

  const ProvisioningState({
    this.isClaiming = false,
    this.isLinking = false,
    this.isPolling = false,
    this.isProvisioning = false,
    this.registeredDevice,
    this.unlinkedDevices = const [],
    this.error,
    this.claimedDeviceId,
  });
}

class ProvisioningNotifier extends Notifier<ProvisioningState> {
  late final ProvisioningRepository _repo;
  Timer? _pollTimer;

  @override
  ProvisioningState build() {
    _repo = ProvisioningRepository();
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
      return true;
    } catch (e) {
      state = ProvisioningState(
        isClaiming: false,
        error: 'Failed to claim device: ${e.toString()}',
      );
      return false;
    }
  }

  Future<String?> fetchPairingToken(String serial) async {
    state = ProvisioningState(
      isClaiming: true,
      error: null,
      registeredDevice: state.registeredDevice,
      claimedDeviceId: state.claimedDeviceId,
    );
    try {
      final response = await _repo.createPairingToken(serial: serial);
      state = ProvisioningState(
        registeredDevice: state.registeredDevice,
        claimedDeviceId: state.claimedDeviceId,
      );
      return response.token;
    } catch (e) {
      state = ProvisioningState(
        error: 'Failed to get pairing token: ${e.toString()}',
        registeredDevice: state.registeredDevice,
        claimedDeviceId: state.claimedDeviceId,
      );
      return null;
    }
  }

  Future<Device?> startApProvisioning({
    required String ssid,
    required String password,
    required String serial,
    String? name,
  }) async {
    final normalizedSerial = serial.trim().toUpperCase();
    state = const ProvisioningState(isProvisioning: true);

    try {
      final tokenResponse =
          await _repo.createPairingToken(serial: normalizedSerial);

      await _repo.configureDeviceAp(
        ssid: ssid,
        password: password,
        serial: normalizedSerial,
        token: tokenResponse.token,
      );

      final device = await _repo.register(
        normalizedSerial,
        tokenResponse.token,
        name: name,
      );

      state = ProvisioningState(
        registeredDevice: device,
        claimedDeviceId: device.id,
      );
      return device;
    } catch (e) {
      state = ProvisioningState(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> linkDevice(String householdId, {String? name}) async {
    final deviceId = state.claimedDeviceId ?? state.registeredDevice?.id;
    if (deviceId == null) {
      state = ProvisioningState(
        error: 'No device to link',
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
        error: 'Failed to link device: ${e.toString()}',
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
        error: 'Timed out waiting for device to connect.',
      );
      return null;
    } catch (e) {
      state = ProvisioningState(
        isPolling: false,
        error: 'Polling error: ${e.toString()}',
      );
      return null;
    }
  }

  void clearError() {
    state = ProvisioningState(
      registeredDevice: state.registeredDevice,
      claimedDeviceId: state.claimedDeviceId,
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
