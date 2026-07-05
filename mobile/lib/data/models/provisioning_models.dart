class DeviceRegisterRequest {
  final String serial;
  final String token;
  final String? name;
  const DeviceRegisterRequest({
    required this.serial,
    required this.token,
    this.name,
  });
  Map<String, dynamic> toJson() => {
        'serial': serial,
        'token': token,
        if (name != null) 'name': name,
      };
}

class DeviceLinkRequest {
  final String householdId;
  final String? name;
  const DeviceLinkRequest({required this.householdId, this.name});
  Map<String, dynamic> toJson() => {
        'household_id': householdId,
        if (name != null) 'name': name,
      };
}

class ProvisionPairingTokenRequest {
  final String? householdId;
  final String? serial;
  const ProvisionPairingTokenRequest({this.householdId, this.serial});
  Map<String, dynamic> toJson() => {
        if (householdId != null) 'household_id': householdId,
        if (serial != null) 'serial': serial,
      };
}

class PairingTokenResponse {
  final String id;
  final String token;
  final String status;
  final String expiresAt;
  const PairingTokenResponse({
    required this.id,
    required this.token,
    required this.status,
    required this.expiresAt,
  });
  factory PairingTokenResponse.fromJson(Map<String, dynamic> json) =>
      PairingTokenResponse(
        id: json['id'] as String,
        token: json['token'] as String,
        status: json['status'] as String,
        expiresAt: json['expires_at'] as String,
      );
}

enum ApSetupStep {
  instructions,
  connectToAp,
  enterWifiCreds,
  sendingCreds,
  waitingForDevice,
  success,
  failed,
}
