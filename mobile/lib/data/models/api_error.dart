class ApiError implements Exception {
  final int statusCode;
  final String detail;

  const ApiError(this.statusCode, this.detail);

  @override
  String toString() => detail;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isRateLimited => statusCode == 429;
  bool get isValidationError => statusCode == 422;

  bool get isAlreadyRegistered {
    if (!isConflict) return false;
    final d = detail.toLowerCase();
    return d.contains('already registered') || d.contains('already linked');
  }
}
