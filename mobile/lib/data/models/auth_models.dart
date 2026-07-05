class SendOtpRequest {
  final String phone;
  const SendOtpRequest({required this.phone});
  Map<String, dynamic> toJson() => {'phone': phone};
}

class SendOtpResponse {
  final int expiresInSeconds;
  final int retryAfterSeconds;
  const SendOtpResponse({
    required this.expiresInSeconds,
    required this.retryAfterSeconds,
  });
  factory SendOtpResponse.fromJson(Map<String, dynamic> json) =>
      SendOtpResponse(
        expiresInSeconds: json['expires_in_seconds'] as int,
        retryAfterSeconds: json['retry_after_seconds'] as int,
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
