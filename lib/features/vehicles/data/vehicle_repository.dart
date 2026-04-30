import 'package:fuelkeeper/features/vehicles/domain/vehicle.dart';
import 'package:hive/hive.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAll();
  Future<void> save(Vehicle vehicle);
  Future<void> delete(String id);
  Stream<List<Vehicle>> watch();
}

class HiveVehicleRepository implements VehicleRepository {
  HiveVehicleRepository(this._box);

  static const boxName = 'vehicles';

  final Box<Vehicle> _box;

  @override
  Future<List<Vehicle>> getAll() async {
    final list = _box.values.toList();
    list.sort((a, b) {
      final aTs =
          a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTs = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return aTs.compareTo(bTs);
    });
    return list;
  }

  @override
  Future<void> save(Vehicle vehicle) => _box.put(vehicle.id, vehicle);

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Stream<List<Vehicle>> watch() async* {
    yield await getAll();
    yield* _box.watch().asyncMap((_) => getAll());
  }
}
