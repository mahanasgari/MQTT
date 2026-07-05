import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  SecureStorage._();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _phoneKey = 'phone';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String phone,
  }) async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
      prefs.setString(_phoneKey, phone),
    ]);
  }

  static Future<String?> get accessToken async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> get refreshToken async {
    final prefs = await _prefs;
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> get phone async {
    final prefs = await _prefs;
    return prefs.getString(_phoneKey);
  }

  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
    ]);
  }

  static Future<void> clear() async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_phoneKey),
    ]);
  }
}
