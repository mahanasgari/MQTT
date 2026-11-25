import 'package:smartplug/l10n/app_localizations.dart';

final _e164Pattern = RegExp(r'^\+[1-9]\d{6,14}$');

bool isValidE164(String phone) => _e164Pattern.hasMatch(phone);

/// Normalize common Iran formats to E.164 (`+98912…`).
String normalizePhone(String phone) {
  var p = phone.trim().replaceAll(' ', '').replaceAll('-', '');
  if (p.startsWith('00')) p = '+${p.substring(2)}';
  if (p.startsWith('09') && p.length == 11) p = '+98${p.substring(1)}';
  if (p.startsWith('9') && p.length == 10) p = '+98$p';
  if (p.startsWith('98') && !p.startsWith('+') && p.length >= 12) {
    p = '+$p';
  }
  return p;
}

String? formatPhoneError(String phone, AppLocalizations l10n) {
  final trimmed = normalizePhone(phone);
  if (trimmed.isEmpty) return l10n.phoneRequired;
  if (!isValidE164(trimmed)) return l10n.phoneInvalidE164;
  return null;
}
