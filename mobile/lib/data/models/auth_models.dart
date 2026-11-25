class SendOtpRequest {
  final String phone;
  /// `bale` or `sms`
  final String channel;
  const SendOtpRequest({required this.phone, this.channel = 'sms'});
  Map<String, dynamic> toJson() => {'phone': phone, 'channel': channel};
}

class SendOtpResponse {
  final int expiresInSeconds;
  final int retryAfterSeconds;
  final String? channel;
  const SendOtpResponse({
    required this.expiresInSeconds,
    required this.retryAfterSeconds,
    this.channel,
  });
  factory SendOtpResponse.fromJson(Map<String, dynamic> json) =>
      SendOtpResponse(
        expiresInSeconds: json['expires_in_seconds'] as int,
        retryAfterSeconds: json['retry_after_seconds'] as int,
        channel: json['channel'] as String?,
      );
}

class VerifyOtpRequest {
  final String phone;
  final String code;
  const VerifyOtpRequest({required this.phone, required this.code});
  Map<String, dynamic> toJson() => {'phone': phone, 'code': code};
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: json['expires_in'] as int,
      );
}
