class AppConstants {
  AppConstants._();

  static const int otpLength = 6;
  static const int otpExpireSeconds = 300;
  static const int otpRetryAfterSeconds = 60;
  static const int defaultPageSize = 50;
  static const Duration wsReconnectDelay = Duration(seconds: 3);
  static const Duration httpTimeout = Duration(seconds: 30);
}
