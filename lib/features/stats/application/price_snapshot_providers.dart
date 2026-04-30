import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot_repository.dart';
import 'package:hive/hive.dart';

final priceSnapshotBoxProvider =
    FutureProvider<Box<PriceSnapshot>>((ref) async {
  const name = HivePriceSnapshotRepository.boxName;
  if (Hive.isBoxOpen(name)) return Hive.box<PriceSnapshot>(name);
  return Hive.openBox<PriceSnapshot>(name);
});

final priceSnapshotRepositoryProvider =
    FutureProvider<PriceSnapshotRepository>((ref) async {
  final box = await ref.watch(priceSnapshotBoxProvider.future);
  return HivePriceSnapshotRepository(box);
});

/// 특정 주유소·연료의 가격 시계열. Dart 3 record 인자 사용.
final priceHistoryProvider = FutureProvider.family<List<PriceSnapshot>,
    ({String stationId, FuelType fuelType})>((ref, args) async {
  final repo = await ref.watch(priceSnapshotRepositoryProvider.future);
  return repo.historyOf(args.stationId, args.fuelType);
});
