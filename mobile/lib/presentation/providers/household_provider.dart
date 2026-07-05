import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/household_models.dart';
import '../../data/repositories/household_repository.dart';

class HouseholdListNotifier extends AsyncNotifier<List<Household>> {
  late final HouseholdRepository _repo;

  @override
  Future<List<Household>> build() async {
    _repo = HouseholdRepository();
    return _fetch();
  }

  Future<List<Household>> _fetch() async {
    final list = await _repo.list();
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<bool> create(String name, {String? timezone}) async {
    try {
      await _repo.create(name, timezone: timezone);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final householdListProvider =
    AsyncNotifierProvider<HouseholdListNotifier, List<Household>>(
  HouseholdListNotifier.new,
);
