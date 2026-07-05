import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, loading, authenticated }

class AuthState {
  final AuthStatus status;
  final String? phone;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.phone,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, String? phone, String? error}) =>
      AuthState(
        status: status ?? this.status,
        phone: phone ?? this.phone,
        error: error,
      );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = AuthRepository();
    _checkAuth();
    return const AuthState();
  }

  Future<void> _checkAuth() async {
    final token = await SecureStorage.accessToken;
    final phone = await SecureStorage.phone;
    if (token != null && phone != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        phone: phone,
      );
    }
  }

  Future<void> checkAuth() => _checkAuth();

  Future<SendOtpResult> sendOtp(String phone) async {
    state = state.copyWith(error: null);
    try {
      final res = await _repo.sendOtp(phone);
      return SendOtpResult(
        expiresInSeconds: res.expiresInSeconds,
        retryAfterSeconds: res.retryAfterSeconds,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return SendOtpResult(error: e.toString());
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final tokens = await _repo.verifyOtp(phone, code);
      await SecureStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        phone: phone,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        phone: phone,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.clear();
    state = const AuthState();
  }
}

class SendOtpResult {
  final int? expiresInSeconds;
  final int? retryAfterSeconds;
  final String? error;
  const SendOtpResult({
    this.expiresInSeconds,
    this.retryAfterSeconds,
    this.error,
  });
  bool get isSuccess => error == null;
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
