import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:hive/hive.dart';

abstract class FuelLogRepository {
  Future<List<FuelLog>> getAll();
  Future<void> save(FuelLog log);
  Future<void> delete(String id);
  Stream<List<FuelLog>> watch();
}

class HiveFuelLogRepository implements FuelLogRepository {
  HiveFuelLogRepository(this._box);

  static const boxName = 'fuel_logs';

  final Box<FuelLog> _box;

  @override
  Future<List<FuelLog>> getAll() async {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> save(FuelLog log) async {
    await _box.put(log.id, log);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Stream<List<FuelLog>> watch() async* {
    yield await getAll();
    yield* _box.watch().asyncMap((_) => getAll());
  }
}
