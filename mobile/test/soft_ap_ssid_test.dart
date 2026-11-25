import 'package:flutter_test/flutter_test.dart';
import 'package:smartplug/core/network/nearby_wifi.dart';
import 'package:smartplug/core/network/soft_ap_ssid.dart';

void main() {
  test('serial tail becomes SoftAP SSID', () {
    expect(softApSsidFromSerial('SP00F8587E'), 'SmartPlug-587E');
    expect(softApSsidFromSerial('sp0005c873'), 'SmartPlug-C873');
    expect(softApSsidFromSerial('SP00000000'), 'SmartPlug-0000');
  });

  test('SoftAP SSID yields chip-id tail', () {
    expect(softApTailFromSsid('SmartPlug-587E'), '587E');
    expect(softApTailFromSsid('SmartPlug-C873'), 'C873');
    expect(softApTailFromSsid('HomeWifi'), isNull);
    expect(softApTailFromSsid('SmartPlug-XYZ'), isNull);
  });

  test('serialMatchesSoftApTail', () {
    expect(serialMatchesSoftApTail('SP00F8587E', '587E'), isTrue);
    expect(serialMatchesSoftApTail('sp0005c873', 'C873'), isTrue);
    expect(serialMatchesSoftApTail('SP00F8587E', 'C873'), isFalse);
    expect(serialMatchesSoftApTail('', '587E'), isFalse);
  });

  test('wifi scan keeps strongest SSID and prefers 2.4 GHz', () {
    final merged = mergeWifiScans([
      const NearbyWifi(ssid: 'AALE.co', rssi: -70, frequency: 2437, secure: true),
      const NearbyWifi(ssid: 'AALE.co', rssi: -40, frequency: 5180, secure: true),
      const NearbyWifi(ssid: 'AALE.co', rssi: -50, frequency: 2437, secure: true),
      const NearbyWifi(ssid: '', rssi: -30, frequency: 2412, secure: false),
    ]);
    expect(merged.single.ssid, 'AALE.co');
    expect(merged.single.rssi, -50);
    expect(merged.single.is24g, isTrue);
  });
}
