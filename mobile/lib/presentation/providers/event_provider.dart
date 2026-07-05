import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';
import '../../core/constants/app_constants.dart';

class EventListState {
  final List<DeviceEvent> events;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? currentDeviceId;

  const EventListState({
    this.events = const [],
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentDeviceId,
  });

  bool get hasMore => events.length < total;

  EventListState copyWith({
    List<DeviceEvent>? events,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? currentDeviceId,
  }) =>
      EventListState(
        events: events ?? this.events,
        total: total ?? this.total,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error,
        currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      );
}

class EventListNotifier extends FamilyNotifier<EventListState, String> {
  late final EventRepository _repo;

  @override
  EventListState build(String arg) {
    _repo = EventRepository();
    return EventListState();
  }

  Future<void> loadFirstPage() async {
    final deviceId = arg;
    state = EventListState(isLoading: true, currentDeviceId: deviceId);
    try {
      final result = await _repo.getDeviceEvents(
        deviceId,
        limit: AppConstants.defaultPageSize,
        offset: 0,
      );
      state = EventListState(
        events: result.events,
        total: result.total,
        currentDeviceId: deviceId,
      );
    } catch (e) {
      state = const EventListState(
        isLoading: false,
        error: 'Failed to load events',
      );
    }
  }

  Future<void> loadMore() async {
    final deviceId = arg;
    if (state.isLoadingMore || !state.hasMore) return;
    if (state.currentDeviceId != deviceId) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _repo.getDeviceEvents(
        deviceId,
        limit: AppConstants.defaultPageSize,
        offset: state.events.length,
      );
      state = state.copyWith(
        events: [...state.events, ...result.events],
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final eventListProvider =
    NotifierProvider.family<EventListNotifier, EventListState, String>(
  EventListNotifier.new,
);
