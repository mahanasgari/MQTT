import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/websocket_client.dart';
import '../../core/storage/secure_storage.dart';
import 'device_list_provider.dart';
import 'device_detail_provider.dart';

class WsConnectionState {
  final bool isConnected;
  final List<String> subscribedDeviceIds;

  const WsConnectionState({
    this.isConnected = false,
    this.subscribedDeviceIds = const [],
  });
}

class WsNotifier extends Notifier<WsConnectionState> {
  WebSocketClient? _client;
  StreamSubscription<WsMessage>? _subscription;

  @override
  WsConnectionState build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _client?.dispose();
    });
    return const WsConnectionState();
  }

  Future<void> connect() async {
    final token = await SecureStorage.accessToken;
    if (token == null) return;

    _client = WebSocketClient();
    await _client!.connect(token);

    _subscription = _client!.messages.listen(_handleMessage);

    state = WsConnectionState(isConnected: true);

    if (state.subscribedDeviceIds.isNotEmpty) {
      _client!.subscribe(state.subscribedDeviceIds);
    }
  }

  void subscribeToDevice(String deviceId) {
    final ids = [
      ...state.subscribedDeviceIds,
      if (!state.subscribedDeviceIds.contains(deviceId)) deviceId,
    ];
    state = WsConnectionState(
      isConnected: state.isConnected,
      subscribedDeviceIds: ids,
    );
    _client?.subscribe([deviceId]);
  }

  void unsubscribeFromDevice(String deviceId) {
    final ids =
        state.subscribedDeviceIds.where((id) => id != deviceId).toList();
    state = WsConnectionState(
      isConnected: state.isConnected,
      subscribedDeviceIds: ids,
    );
    _client?.unsubscribe([deviceId]);
  }

  void subscribeToDevices(List<String> deviceIds) {
    final newIds = deviceIds
        .where((id) => !state.subscribedDeviceIds.contains(id))
        .toList();
    if (newIds.isEmpty) return;
    state = WsConnectionState(
      isConnected: state.isConnected,
      subscribedDeviceIds: [...state.subscribedDeviceIds, ...newIds],
    );
    _client?.subscribe(newIds);
  }

  void _handleMessage(WsMessage msg) {
    if (msg.type == 'state_update' && msg.deviceId != null && msg.data != null) {
      ref.read(deviceListProvider.notifier).applyLiveUpdate(
            msg.deviceId!,
            msg.data!,
          );
      ref.read(deviceDetailProvider.notifier).applyLiveUpdate(msg.data!);
    }
  }

  Future<void> disconnect() async {
    await _client?.disconnect();
    _subscription?.cancel();
    _subscription = null;
    _client = null;
    state = const WsConnectionState();
  }

  Future<void> reconnectAfterLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }
}

final wsProvider = NotifierProvider<WsNotifier, WsConnectionState>(
  WsNotifier.new,
);
