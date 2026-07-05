import '../models/auth_models.dart';
import '../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  Future<SendOtpResponse> sendOtp(String phone) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/send-otp',
      body: SendOtpRequest(phone: phone).toJson(),
      skipAuth: true,
    );
    return SendOtpResponse.fromJson(data);
  }

  Future<TokenResponse> verifyOtp(String phone, String code) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      body: VerifyOtpRequest(phone: phone, code: code).toJson(),
      skipAuth: true,
    );
    return TokenResponse.fromJson(data);
  }

  Future<TokenResponse> refresh(String refreshToken) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/refresh',
      body: {'refresh_token': refreshToken},
      skipAuth: true,
    );
    return TokenResponse.fromJson(data);
  }
}
