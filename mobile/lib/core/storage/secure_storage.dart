import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  SecureStorage._();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _phoneKey = 'phone';
  static const _onboardingDoneKey = 'onboarding_done';

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
      // Keep onboarding_done so returning users skip the tour.
    ]);
  }

  static Future<bool> get onboardingDone async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingDoneKey) ?? false;
  }

  static Future<void> setOnboardingDone(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingDoneKey, value);
  }

  static String _lanIpKey(String serial) => 'lan_ip_$serial';
  static String _localTokenKey(String serial) => 'device_token_$serial';

  static Future<void> saveDeviceLanIp(String serial, String ip) async {
    final prefs = await _prefs;
    await prefs.setString(_lanIpKey(serial), ip);
  }

  static Future<String?> deviceLanIp(String serial) async {
    final prefs = await _prefs;
    return prefs.getString(_lanIpKey(serial));
  }

  static Future<void> clearDeviceLanIp(String serial) async {
    final prefs = await _prefs;
    await prefs.remove(_lanIpKey(serial));
  }

  static Future<void> saveDeviceLocalToken(String serial, String token) async {
    final prefs = await _prefs;
    await prefs.setString(_localTokenKey(serial), token);
  }

  static Future<String?> deviceLocalToken(String serial) async {
    final prefs = await _prefs;
    return prefs.getString(_localTokenKey(serial));
  }

  static String _lastPathKey(String serial) => 'last_path_$serial';
  static String _preferredPathKey(String serial) => 'preferred_path_$serial';

  /// Persist last successful control path: softAp | lan | cloud
  static Future<void> saveLastControlPath(String serial, String path) async {
    final prefs = await _prefs;
    await prefs.setString(_lastPathKey(serial), path);
  }

  static Future<String?> lastControlPath(String serial) async {
    final prefs = await _prefs;
    return prefs.getString(_lastPathKey(serial));
  }

  /// User preference: auto | softAp | lan | cloud
  static Future<void> savePreferredControlPath(
    String serial,
    String path,
  ) async {
    final prefs = await _prefs;
    if (path == 'auto') {
      await prefs.remove(_preferredPathKey(serial));
      return;
    }
    await prefs.setString(_preferredPathKey(serial), path);
  }

  static Future<String?> preferredControlPath(String serial) async {
    final prefs = await _prefs;
    return prefs.getString(_preferredPathKey(serial));
  }
}
