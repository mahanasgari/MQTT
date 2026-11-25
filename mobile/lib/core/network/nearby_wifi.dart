class NearbyWifi {
  final String ssid;
  final int rssi;
  final int frequency;
  final bool secure;

  const NearbyWifi({
    required this.ssid,
    required this.rssi,
    required this.frequency,
    required this.secure,
  });

  bool get is5g => frequency >= 4900;
  bool get is24g => frequency > 0 && frequency < 4900;

  factory NearbyWifi.fromMap(Map<dynamic, dynamic> map) => NearbyWifi(
        ssid: (map['ssid'] as String? ?? '').trim(),
        rssi: (map['rssi'] as num?)?.toInt() ?? -100,
        frequency: (map['frequency'] as num?)?.toInt() ?? 0,
        secure: map['secure'] == true,
      );
}

/// Strongest result per SSID; drop blanks.
List<NearbyWifi> mergeWifiScans(Iterable<NearbyWifi> raw) {
  final bySsid = <String, NearbyWifi>{};
  for (final n in raw) {
    if (n.ssid.isEmpty) continue;
    final prev = bySsid[n.ssid];
    if (prev == null) {
      bySsid[n.ssid] = n;
      continue;
    }
    if (n.is24g && !prev.is24g) {
      bySsid[n.ssid] = n;
      continue;
    }
    if (n.is24g == prev.is24g && n.rssi > prev.rssi) {
      bySsid[n.ssid] = n;
    }
  }
  final list = bySsid.values.toList()
    ..sort((a, b) {
      if (a.is24g != b.is24g) return a.is24g ? -1 : 1;
      return b.rssi.compareTo(a.rssi);
    });
  return list;
}
