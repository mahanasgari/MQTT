class DeviceState {
  final String power;
  final String connectivity;
  final String lastChangedAt;
  final String lastSeenAt;

  const DeviceState({
    required this.power,
    required this.connectivity,
    required this.lastChangedAt,
    required this.lastSeenAt,
  });

  bool get isOn => power == 'on';
  bool get isOnline => connectivity == 'online';

  factory DeviceState.fromJson(Map<String, dynamic> json) => DeviceState(
        power: json['power'] as String? ?? 'off',
        connectivity: json['connectivity'] as String? ?? 'offline',
        lastChangedAt: json['last_changed_at'] as String? ?? '',
        lastSeenAt: json['last_seen_at'] as String? ?? '',
      );

  DeviceState copyWith({
    String? power,
    String? connectivity,
    String? lastChangedAt,
    String? lastSeenAt,
  }) =>
      DeviceState(
        power: power ?? this.power,
        connectivity: connectivity ?? this.connectivity,
        lastChangedAt: lastChangedAt ?? this.lastChangedAt,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      );
}

class Device {
  final String id;
  final String serial;
  final String? name;
  final String? householdId;
  final String? firmwareVersion;
  final DeviceState? state;
  final String createdAt;

  const Device({
    required this.id,
    required this.serial,
    this.name,
    this.householdId,
    this.firmwareVersion,
    this.state,
    required this.createdAt,
  });

  String get displayName => name ?? serial;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as String,
        serial: json['serial'] as String,
        name: json['name'] as String?,
        householdId: json['household_id'] as String?,
        firmwareVersion: json['firmware_version'] as String?,
        state: json['state'] != null
            ? DeviceState.fromJson(json['state'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] as String,
      );

  Device copyWith({DeviceState? state}) => Device(
        id: id,
        serial: serial,
        name: name,
        householdId: householdId,
        firmwareVersion: firmwareVersion,
        state: state ?? this.state,
        createdAt: createdAt,
      );
}

class DeviceControlRequest {
  final String command;
  final String value;
  const DeviceControlRequest({required this.command, required this.value});
  Map<String, dynamic> toJson() => {'command': command, 'value': value};
}
