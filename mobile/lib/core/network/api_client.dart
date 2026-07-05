import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/models/api_error.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _client = http.Client();

  Future<Map<String, String>> _headers({bool skipAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (!skipAuth) {
      final token = await SecureStorage.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool skipAuth = false,
  }) async {
    final url = Uri.parse('$apiBaseUrl$path');
    final headers = await _headers(skipAuth: skipAuth);

    http.Response res;
    try {
      final streamed = await _client
          .send(
            http.Request(method, url)
              ..headers.addAll(headers)
              ..body = body != null ? jsonEncode(body) : '',
          )
          .timeout(AppConstants.httpTimeout);
      res = await http.Response.fromStream(streamed);
    } catch (e) {
      throw ApiError(0, 'Network error: ${e.toString()}');
    }

    if (res.statusCode == 401 && !skipAuth) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final newHeaders = await _headers(skipAuth: false);
        final streamed = await _client.send(
          http.Request(method, url)
            ..headers.addAll(newHeaders)
            ..body = body != null ? jsonEncode(body) : '',
        );
        res = await http.Response.fromStream(streamed);
      } else {
        await SecureStorage.clear();
        throw ApiError(401, 'Session expired');
      }
    }

    if (res.statusCode >= 400) {
      String detail = 'HTTP ${res.statusCode}';
      try {
        final err = jsonDecode(res.body);
        detail = err['detail'] ?? err['message'] ?? detail;
      } catch (_) {}
      throw ApiError(res.statusCode, detail);
    }

    if (res.statusCode == 204) return null;
    return jsonDecode(res.body);
  }

  Future<bool> _tryRefresh() async {
    final token = await SecureStorage.refreshToken;
    if (token == null) return false;
    try {
      final data = await post<Map<String, dynamic>>(
        '/auth/refresh',
        body: {'refresh_token': token},
        skipAuth: true,
      );
      await SecureStorage.updateTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<T> get<T>(
    String path, {
    bool skipAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    final data = await _request('GET', path, skipAuth: skipAuth);
    if (fromJson != null && data != null) return fromJson(data);
    return data as T;
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    bool skipAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    final data = await _request('POST', path, body: body, skipAuth: skipAuth);
    if (fromJson != null && data != null) return fromJson(data);
    return data as T;
  }

  Future<T> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    final data = await _request('PATCH', path, body: body);
    if (fromJson != null && data != null) return fromJson(data);
    return data as T;
  }

  Future<T> delete<T>(String path, {T Function(dynamic)? fromJson}) async {
    final data = await _request('DELETE', path);
    if (fromJson != null && data != null) return fromJson(data);
    return data as T;
  }
}
