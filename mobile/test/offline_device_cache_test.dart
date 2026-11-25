import 'package:flutter_test/flutter_test.dart';
import 'package:smartplug/core/storage/offline_device_cache.dart';
import 'package:smartplug/data/models/device_models.dart';

Device _dev({
  required String id,
  required String serial,
  String? householdId,
}) {
  return Device(
    id: id,
    serial: serial,
    name: serial,
    householdId: householdId,
    createdAt: '2026-01-01T00:00:00Z',
    role: 'owner',
  );
}

void main() {
  test('mergeHouseholdCache replaces one household and keeps others', () {
    final cached = [
      _dev(id: 'a', serial: 'SP1', householdId: 'h1'),
      _dev(id: 'b', serial: 'SP2', householdId: 'h2'),
      _dev(id: 'c', serial: 'SP3', householdId: 'h1'),
    ];
    final fetched = [
      _dev(id: 'a', serial: 'SP1', householdId: 'h1'),
    ];
    final merged = mergeHouseholdCache(
      cached: cached,
      fetched: fetched,
      householdId: 'h1',
    );
    expect(merged.map((d) => d.id), ['b', 'a']);
  });

  test('mergeHouseholdCache never resurrects excluded ids', () {
    final cached = [
      _dev(id: 'gone', serial: 'SPX', householdId: 'h2'),
      _dev(id: 'keep', serial: 'SPY', householdId: 'h2'),
    ];
    final fetched = [
      _dev(id: 'new', serial: 'SPZ', householdId: 'h1'),
      _dev(id: 'gone', serial: 'SPX', householdId: 'h1'),
    ];
    final merged = mergeHouseholdCache(
      cached: cached,
      fetched: fetched,
      householdId: 'h1',
      excludeIds: {'gone'},
    );
    expect(merged.map((d) => d.id).toList(), ['keep', 'new']);
  });

  test('excludeDeviceIds filters tombstones', () {
    final list = [
      _dev(id: '1', serial: 'A'),
      _dev(id: '2', serial: 'B'),
    ];
    expect(excludeDeviceIds(list, {'1'}).map((d) => d.id), ['2']);
  });
}
