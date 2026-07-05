class Household {
  final String id;
  final String name;
  final String timezone;
  final String role;
  final int deviceCount;
  final String createdAt;

  const Household({
    required this.id,
    required this.name,
    required this.timezone,
    required this.role,
    required this.deviceCount,
    required this.createdAt,
  });

  factory Household.fromJson(Map<String, dynamic> json) => Household(
        id: json['id'] as String,
        name: json['name'] as String,
        timezone: json['timezone'] as String? ?? 'UTC',
        role: json['role'] as String? ?? 'member',
        deviceCount: json['device_count'] as int? ?? 0,
        createdAt: json['created_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'timezone': timezone,
        'role': role,
        'device_count': deviceCount,
        'created_at': createdAt,
      };
}

class HouseholdCreateRequest {
  final String name;
  final String? timezone;
  const HouseholdCreateRequest({required this.name, this.timezone});
  Map<String, dynamic> toJson() => {
        'name': name,
        if (timezone != null) 'timezone': timezone,
      };
}
