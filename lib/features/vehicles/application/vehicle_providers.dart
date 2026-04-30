import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/vehicles/data/vehicle_repository.dart';
import 'package:fuelkeeper/features/vehicles/domain/vehicle.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

final vehicleBoxProvider = FutureProvider<Box<Vehicle>>((ref) async {
  const name = HiveVehicleRepository.boxName;
  if (Hive.isBoxOpen(name)) return Hive.box<Vehicle>(name);
  return Hive.openBox<Vehicle>(name);
});

final vehicleRepositoryProvider =
    FutureProvider<VehicleRepository>((ref) async {
  final box = await ref.watch(vehicleBoxProvider.future);
  return HiveVehicleRepository(box);
});

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) async* {
  final repo = await ref.watch(vehicleRepositoryProvider.future);
  yield* repo.watch();
});

class VehicleActions {
  VehicleActions(this._repo);
  final VehicleRepository _repo;

  Future<void> save(Vehicle vehicle) => _repo.save(vehicle);
  Future<void> delete(String id) => _repo.delete(id);
}

final vehicleActionsProvider = FutureProvider<VehicleActions>((ref) async {
  final repo = await ref.watch(vehicleRepositoryProvider.future);
  return VehicleActions(repo);
});

/// 현재 활성(선택된) 차량의 ID. SharedPreferences에 영속화한다.
///
/// null이면 "차량 미설정" 상태이며, 통계·알림 등은 모든 로그를 대상으로 한다.
class ActiveVehicleNotifier extends Notifier<String?> {
  static const _prefsKey = 'app.activeVehicleId';

  @override
  String? build() {
    _restore();
    return null;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getString(_prefsKey);
    } catch (_) {
      // 저장소 오류 시 null 유지.
    }
  }

  Future<void> set(String? id) async {
    state = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, id);
      }
    } catch (_) {
      // 저장 실패해도 메모리 상태는 유지.
    }
  }
}

final activeVehicleIdProvider =
    NotifierProvider<ActiveVehicleNotifier, String?>(
  ActiveVehicleNotifier.new,
);

/// 활성 차량 객체. 활성 ID가 null이거나 매칭되지 않으면 null.
final activeVehicleProvider = Provider<Vehicle?>((ref) {
  final id = ref.watch(activeVehicleIdProvider);
  final asyncList = ref.watch(vehiclesProvider);
  if (id == null) return null;
  return asyncList.maybeWhen(
    data: (list) {
      for (final v in list) {
        if (v.id == id) return v;
      }
      return null;
    },
    orElse: () => null,
  );
});
