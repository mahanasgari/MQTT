final _e164Pattern = RegExp(r'^\+[1-9]\d{6,14}$');

bool isValidE164(String phone) => _e164Pattern.hasMatch(phone);

String? formatPhoneError(String phone) {
  final trimmed = phone.trim();
  if (trimmed.isEmpty) return 'Enter your phone number';
  if (!isValidE164(trimmed)) {
    return 'Phone must start with + followed by country code (e.g. +8613800138000)';
  }
  return null;
}
