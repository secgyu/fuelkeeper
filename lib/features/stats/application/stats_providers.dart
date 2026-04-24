import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';

class MonthlyBucket {
  const MonthlyBucket({
    required this.year,
    required this.month,
    required this.totalCost,
    required this.totalLiters,
    required this.efficiency,
  });

  final int year;
  final int month;
  final int totalCost;
  final double totalLiters;
  final double? efficiency;

  String get label => '${month.toString().padLeft(2, '0')}월';
}

class StatsOverview {
  const StatsOverview({
    required this.totalCost,
    required this.totalLiters,
    required this.avgEfficiency,
    required this.logCount,
  });

  final int totalCost;
  final double totalLiters;
  final double? avgEfficiency;
  final int logCount;

  static const empty = StatsOverview(
    totalCost: 0,
    totalLiters: 0,
    avgEfficiency: null,
    logCount: 0,
  );
}

class FuelTypeShare {
  const FuelTypeShare({
    required this.type,
    required this.totalCost,
    required this.ratio,
  });

  final FuelType type;
  final int totalCost;
  final double ratio;
}

class FrequentStation {
  const FrequentStation({
    required this.stationId,
    required this.name,
    required this.brandIndex,
    required this.visits,
    required this.totalCost,
  });

  final String stationId;
  final String name;
  final int brandIndex;
  final int visits;
  final int totalCost;
}

final statsOverviewProvider = Provider<StatsOverview>((ref) {
  final logs = ref.watch(fuelLogsProvider).value ?? const [];
  if (logs.isEmpty) return StatsOverview.empty;

  final totalCost = logs.fold<int>(0, (sum, l) => sum + l.totalCost);
  final totalLiters = logs.fold<double>(0, (sum, l) => sum + l.liters);

  return StatsOverview(
    totalCost: totalCost,
    totalLiters: totalLiters,
    avgEfficiency: _averageEfficiency(logs),
    logCount: logs.length,
  );
});

final monthlyBucketsProvider = Provider<List<MonthlyBucket>>((ref) {
  final logs = ref.watch(fuelLogsProvider).value ?? const [];
  final now = DateTime.now();

  final buckets = <MonthlyBucket>[];
  for (var i = 5; i >= 0; i--) {
    final target = DateTime(now.year, now.month - i, 1);
    final inMonth = logs
        .where(
          (l) => l.date.year == target.year && l.date.month == target.month,
        )
        .toList();

    final cost = inMonth.fold<int>(0, (sum, l) => sum + l.totalCost);
    final liters = inMonth.fold<double>(0, (sum, l) => sum + l.liters);
    final eff = _averageEfficiency(inMonth);

    buckets.add(
      MonthlyBucket(
        year: target.year,
        month: target.month,
        totalCost: cost,
        totalLiters: liters,
        efficiency: eff,
      ),
    );
  }
  return buckets;
});

final fuelTypeShareProvider = Provider<List<FuelTypeShare>>((ref) {
  final logs = ref.watch(fuelLogsProvider).value ?? const [];
  if (logs.isEmpty) return const [];

  final totals = <FuelType, int>{};
  for (final l in logs) {
    totals[l.fuelType] = (totals[l.fuelType] ?? 0) + l.totalCost;
  }
  final grandTotal = totals.values.fold<int>(0, (a, b) => a + b);
  if (grandTotal == 0) return const [];

  final shares =
      totals.entries
          .map(
            (e) => FuelTypeShare(
              type: e.key,
              totalCost: e.value,
              ratio: e.value / grandTotal,
            ),
          )
          .toList()
        ..sort((a, b) => b.totalCost.compareTo(a.totalCost));
  return shares;
});

final frequentStationsProvider = Provider<List<FrequentStation>>((ref) {
  final logs = ref.watch(fuelLogsProvider).value ?? const [];
  if (logs.isEmpty) return const [];

  final groups = <String, List<FuelLog>>{};
  for (final l in logs) {
    groups.putIfAbsent(l.stationId, () => []).add(l);
  }

  final list = groups.entries.map((e) {
    final cost = e.value.fold<int>(0, (sum, l) => sum + l.totalCost);
    return FrequentStation(
      stationId: e.key,
      name: e.value.first.stationName,
      brandIndex: e.value.first.brand.index,
      visits: e.value.length,
      totalCost: cost,
    );
  }).toList()..sort((a, b) => b.visits.compareTo(a.visits));

  return list.take(3).toList();
});

double? _averageEfficiency(List<FuelLog> logs) {
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
