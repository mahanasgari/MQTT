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

  Map<String, dynamic> toJson() => {
        'power': power,
        'connectivity': connectivity,
        'last_changed_at': lastChangedAt,
        'last_seen_at': lastSeenAt,
      };
}

class Device {
  final String id;
  final String serial;
  final String? name;
  final String? householdId;
  final String? firmwareVersion;
  final String? lanIp;
  final String? wifiSsid;
  final DeviceState? state;
  final String createdAt;
  /// Ownership role returned by the API when the device comes from a share.
  /// `null` means the device is owned by the current user (no badge needed).
  /// Possible non-null values: `"control"`, `"view"`, `"admin"`.
  final String? role;

  const Device({
    required this.id,
    required this.serial,
    this.name,
    this.householdId,
    this.firmwareVersion,
    this.lanIp,
    this.wifiSsid,
    this.state,
    required this.createdAt,
    this.role,
  });

  String get displayName => name ?? serial;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as String,
        serial: json['serial'] as String,
        name: json['name'] as String?,
        householdId: json['household_id'] as String?,
        firmwareVersion: json['firmware_version'] as String?,
        lanIp: json['lan_ip'] as String?,
        wifiSsid: json['wifi_ssid'] as String?,
        state: json['state'] != null
            ? DeviceState.fromJson(json['state'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] as String,
        role: json['role'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serial': serial,
        if (name != null) 'name': name,
        if (householdId != null) 'household_id': householdId,
        if (firmwareVersion != null) 'firmware_version': firmwareVersion,
        if (lanIp != null) 'lan_ip': lanIp,
        if (wifiSsid != null) 'wifi_ssid': wifiSsid,
        if (state != null) 'state': state!.toJson(),
        'created_at': createdAt,
        if (role != null) 'role': role,
      };

  Device copyWith({
    DeviceState? state,
    String? lanIp,
    String? wifiSsid,
  }) =>
      Device(
        id: id,
        serial: serial,
        name: name,
        householdId: householdId,
        firmwareVersion: firmwareVersion,
        lanIp: lanIp ?? this.lanIp,
        wifiSsid: wifiSsid ?? this.wifiSsid,
        state: state ?? this.state,
        createdAt: createdAt,
        role: role,
      );
}

class DeviceControlRequest {
  final String command;
  final String value;
  const DeviceControlRequest({required this.command, required this.value});
  Map<String, dynamic> toJson() => {'command': command, 'value': value};
}
