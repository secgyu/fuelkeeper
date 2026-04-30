import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot.dart';
import 'package:hive/hive.dart';

abstract class PriceSnapshotRepository {
  /// 같은 (주유소, 연료, 날짜) 키가 이미 있으면 가격을 갱신, 없으면 추가.
  Future<void> upsert(PriceSnapshot snapshot);

  /// 여러 건을 한 번에 저장.
  Future<void> upsertAll(Iterable<PriceSnapshot> snapshots);

  /// 특정 주유소·연료의 모든 스냅샷을 날짜 오름차순으로 반환.
  Future<List<PriceSnapshot>> historyOf(
    String stationId,
    FuelType fuelType,
  );

  /// [maxAge]보다 오래된 스냅샷을 일괄 삭제. 기본 90일.
  Future<int> pruneOlderThan(Duration maxAge);
}

class HivePriceSnapshotRepository implements PriceSnapshotRepository {
  HivePriceSnapshotRepository(this._box);

  static const boxName = 'price_snapshots';

  final Box<PriceSnapshot> _box;

  @override
  Future<void> upsert(PriceSnapshot snapshot) async {
    final key = PriceSnapshot.keyOf(
      snapshot.stationId,
      snapshot.fuelType,
      snapshot.date,
    );
    await _box.put(key, snapshot);
  }

  @override
  Future<void> upsertAll(Iterable<PriceSnapshot> snapshots) async {
    final entries = <String, PriceSnapshot>{};
    for (final s in snapshots) {
      entries[PriceSnapshot.keyOf(s.stationId, s.fuelType, s.date)] = s;
    }
    await _box.putAll(entries);
  }

  @override
  Future<List<PriceSnapshot>> historyOf(
    String stationId,
    FuelType fuelType,
  ) async {
    final list = _box.values
        .where((s) => s.stationId == stationId && s.fuelType == fuelType)
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<int> pruneOlderThan(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    final keysToDelete = <dynamic>[];
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value.date.isBefore(cutoff)) {
        keysToDelete.add(key);
      }
    }
    if (keysToDelete.isNotEmpty) {
      await _box.deleteAll(keysToDelete);
    }
    return keysToDelete.length;
  }
}
