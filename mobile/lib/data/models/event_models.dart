class DeviceEvent {
  final String id;
  final String deviceId;
  final String type;
  final String initiator;
  final String? initiatorId;
  final Map<String, dynamic>? metadata;
  final String occurredAt;

  const DeviceEvent({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.initiator,
    this.initiatorId,
    this.metadata,
    required this.occurredAt,
  });

  factory DeviceEvent.fromJson(Map<String, dynamic> json) => DeviceEvent(
        id: json['id'] as String,
        deviceId: json['device_id'] as String,
        type: json['type'] as String,
        initiator: json['initiator'] as String? ?? 'device',
        initiatorId: json['initiator_id'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        occurredAt: json['occurred_at'] as String? ?? '',
      );

  String get displayType {
    switch (type) {
      case 'power_on':
        return 'Powered On';
      case 'power_off':
        return 'Powered Off';
      case 'device_online':
        return 'Device Online';
      case 'device_offline':
        return 'Device Offline';
      case 'provisioned':
        return 'Provisioned';
      case 'linked':
        return 'Linked to Household';
      default:
        return type.replaceAll('_', ' ').split(' ').map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
  }
}

class PaginatedEvents {
  final List<DeviceEvent> events;
  final int total;

  const PaginatedEvents({required this.events, required this.total});

  factory PaginatedEvents.fromJson(Map<String, dynamic> json) => PaginatedEvents(
        events: (json['events'] as List<dynamic>? ?? [])
            .map((e) => DeviceEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int? ?? 0,
      );
}
