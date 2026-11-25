/// SoftAP SSID is `SmartPlug-` plus the last 4 hex digits of the chip id,
/// which is also the tail of serial `SP########`.
String softApSsidFromSerial(String serial, {String prefix = 'SmartPlug-'}) {
  final s = serial.trim().toUpperCase();
  final hex = s.startsWith('SP') ? s.substring(2) : s;
  final tail = hex.length >= 4
      ? hex.substring(hex.length - 4)
      : hex.padLeft(4, '0');
  return '$prefix$tail';
}

/// Last 4 hex chars from SoftAP SSID `SmartPlug-587E`, or null if not a plug AP.
String? softApTailFromSsid(String ssid, {String prefix = 'SmartPlug-'}) {
  final s = ssid.trim();
  if (!s.toUpperCase().startsWith(prefix.toUpperCase())) return null;
  final tail = s.substring(prefix.length).trim().toUpperCase();
  if (tail.length != 4) return null;
  if (!RegExp(r'^[0-9A-F]{4}$').hasMatch(tail)) return null;
  return tail;
}

/// True when [serial] ends with the SoftAP chip-id tail (last 4 hex).
bool serialMatchesSoftApTail(String serial, String tail) {
  final s = serial.trim().toUpperCase();
  final t = tail.trim().toUpperCase();
  if (t.length != 4) return false;
  final hex = s.startsWith('SP') ? s.substring(2) : s;
  return hex.endsWith(t);
}
