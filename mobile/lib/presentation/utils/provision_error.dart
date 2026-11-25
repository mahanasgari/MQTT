import 'package:smartplug/l10n/app_localizations.dart';
import '../../data/models/api_error.dart';

/// Stable error tokens stored on [ProvisioningState.error] for l10n mapping.
abstract final class ProvisionErrorCode {
  static const alreadyRegistered = 'already_registered';
  static const alreadyLinked = 'already_linked';
  static const badToken = 'bad_token';
  static const unknownSerial = 'unknown_serial';
  static const network = 'network';
  static const timeout = 'timeout';
  static const missingToken = 'missing_token';
  static const missingSerial = 'missing_serial';
  static const pollTimeout = 'poll_timeout';
}

String mapProvisionException(Object e) {
  if (e is ApiError) {
    if (e.isAlreadyRegistered) {
      final d = e.detail.toLowerCase();
      if (d.contains('linked')) return ProvisionErrorCode.alreadyLinked;
      return ProvisionErrorCode.alreadyRegistered;
    }
    if (e.statusCode == 400) return ProvisionErrorCode.badToken;
    if (e.isNotFound) return ProvisionErrorCode.unknownSerial;
    if (e.statusCode == 0 || e.detail.toLowerCase().contains('network')) {
      return ProvisionErrorCode.network;
    }
    return e.detail;
  }
  final raw = e.toString().replaceFirst('Exception: ', '');
  if (raw.toLowerCase().contains('already registered') ||
      raw.toLowerCase().contains('already linked')) {
    return ProvisionErrorCode.alreadyRegistered;
  }
  return raw;
}

bool isFatalRegisterError(Object e) {
  if (e is ApiError) {
    return e.isAlreadyRegistered ||
        e.statusCode == 400 ||
        e.isNotFound ||
        e.isUnauthorized ||
        e.statusCode == 403;
  }
  return false;
}

String localizeProvisionError(String? error, AppLocalizations l10n) {
  if (error == null || error.isEmpty) return l10n.setupFailedDefault;
  switch (error) {
    case ProvisionErrorCode.alreadyRegistered:
      return l10n.deviceAlreadyRegistered;
    case ProvisionErrorCode.alreadyLinked:
      return l10n.deviceAlreadyLinked;
    case ProvisionErrorCode.badToken:
      return l10n.pairingTokenInvalid;
    case ProvisionErrorCode.unknownSerial:
      return l10n.unknownDeviceSerial;
    case ProvisionErrorCode.network:
      return l10n.provisionNetworkError;
    case ProvisionErrorCode.timeout:
      return l10n.provisionTimeout;
    case ProvisionErrorCode.missingToken:
      return l10n.provisionMissingToken;
    case ProvisionErrorCode.missingSerial:
      return l10n.provisionMissingSerial;
    case ProvisionErrorCode.pollTimeout:
      return l10n.provisionPollTimeout;
    default:
      if (error.startsWith('Exception:') ||
          error.contains('ApiError') ||
          error.contains('PlatformException')) {
        return l10n.setupFailedDefault;
      }
      return error;
  }
}
