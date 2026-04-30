import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_repository.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:fuelkeeper/features/vehicles/application/vehicle_providers.dart';
import 'package:hive/hive.dart';

final fuelLogBoxProvider = FutureProvider<Box<FuelLog>>((ref) async {
  const name = HiveFuelLogRepository.boxName;
  if (Hive.isBoxOpen(name)) return Hive.box<FuelLog>(name);
  return Hive.openBox<FuelLog>(name);
});

final fuelLogRepositoryProvider = FutureProvider<FuelLogRepository>((
  ref,
) async {
  final box = await ref.watch(fuelLogBoxProvider.future);
  return HiveFuelLogRepository(box);
});

/// 모든 주유 로그(필터 없음). 차량 무관하게 전체 기록을 조회할 때 사용.
final allFuelLogsProvider = StreamProvider<List<FuelLog>>((ref) async* {
  final repo = await ref.watch(fuelLogRepositoryProvider.future);
  yield* repo.watch();
});

/// 활성 차량 기준으로 필터링된 주유 로그.
///
/// 활성 차량이 없거나 차량 도입 이전 로그(vehicleId == null)는
/// "모든 차량" 묶음으로 함께 보여 사용자 경험을 단순화한다.
final fuelLogsProvider = Provider<AsyncValue<List<FuelLog>>>((ref) {
  final asyncAll = ref.watch(allFuelLogsProvider);
  final activeId = ref.watch(activeVehicleIdProvider);

  return asyncAll.whenData((all) {
    if (activeId == null) return all;
    return all
        .where((l) => l.vehicleId == null || l.vehicleId == activeId)
        .toList(growable: false);
  });
});

class FuelLogActions {
  FuelLogActions(this._repo);
  final FuelLogRepository _repo;

  Future<void> save(FuelLog log) => _repo.save(log);
  Future<void> delete(String id) => _repo.delete(id);
}

final fuelLogActionsProvider = FutureProvider<FuelLogActions>((ref) async {
  final repo = await ref.watch(fuelLogRepositoryProvider.future);
  return FuelLogActions(repo);
});

class MonthlySummary {
  const MonthlySummary({
    required this.count,
    required this.totalCost,
    required this.totalLiters,
    required this.avgEfficiency,
  });

  final int count;
  final int totalCost;
  final double totalLiters;
  final double? avgEfficiency;
}

final currentMonthSummaryProvider = Provider<MonthlySummary>((ref) {
  final logs = ref.watch(fuelLogsProvider).value ?? const [];
  final now = DateTime.now();
  final thisMonth = logs
      .where((l) => l.date.year == now.year && l.date.month == now.month)
      .toList();

  if (thisMonth.isEmpty) {
    return const MonthlySummary(
      count: 0,
      totalCost: 0,
      totalLiters: 0,
      avgEfficiency: null,
    );
  }

  final totalCost = thisMonth.fold<int>(0, (sum, l) => sum + l.totalCost);
  final totalLiters = thisMonth.fold<double>(0, (sum, l) => sum + l.liters);

  final efficiency = _calcAverageEfficiency(logs);

  return MonthlySummary(
    count: thisMonth.length,
    totalCost: totalCost,
    totalLiters: totalLiters,
    avgEfficiency: efficiency,
  );
});

double? _calcAverageEfficiency(List<FuelLog> logs) {
  if (logs.length < 2) return null;
  final ascending = [...logs]..sort((a, b) => a.date.compareTo(b.date));
  final segments = <double>[];
  for (var i = 1; i < ascending.length; i++) {
    final prev = ascending[i - 1];
    final cur = ascending[i];
    final distance = cur.odometerKm - prev.odometerKm;
    if (distance > 0 && cur.liters > 0) {
      segments.add(distance / cur.liters);
    }
  }
  if (segments.isEmpty) return null;
  return segments.reduce((a, b) => a + b) / segments.length;
}
