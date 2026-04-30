import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/core/network/opinet_api.dart';
import 'package:fuelkeeper/features/home/data/opinet_codes.dart';
import 'package:fuelkeeper/features/home/data/opinet_station_repository.dart';
import 'package:fuelkeeper/features/home/application/search_radius_provider.dart';
import 'package:fuelkeeper/features/home/data/station_repository.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/sort_order.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/stats/application/price_snapshot_providers.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot.dart';

final opinetApiProvider = Provider<OpinetApi>((ref) => OpinetApi());

final stationRepositoryProvider = Provider<StationRepository>((ref) {
  return OpinetStationRepository(api: ref.watch(opinetApiProvider));
});

class SelectedFuelType extends Notifier<FuelType> {
  @override
  FuelType build() => FuelType.gasoline;

  void set(FuelType type) => state = type;
}

final selectedFuelTypeProvider = NotifierProvider<SelectedFuelType, FuelType>(
  SelectedFuelType.new,
);

class SelectedSortOrder extends Notifier<SortOrder> {
  @override
  SortOrder build() => SortOrder.price;

  void set(SortOrder order) => state = order;
}

final selectedSortOrderProvider =
    NotifierProvider<SelectedSortOrder, SortOrder>(SelectedSortOrder.new);

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repo = ref.watch(stationRepositoryProvider);
  final fuelType = ref.watch(selectedFuelTypeProvider);
  // 반경이 바뀌면 stationsProvider가 재실행되도록 watch 한다.
  // 캐시 키에도 radius가 포함돼 있어 이전 반경 결과는 그대로 캐시 유지된다.
  final radius = ref.watch(searchRadiusProvider);
  final location = await ref.watch(currentLocationProvider.future);
  final stations = await repo.fetchNearby(
    fuelType: fuelType,
    latitude: location.latitude,
    longitude: location.longitude,
    radiusMeters: radius,
  );

  // 가격 시계열 그래프를 위해 오늘 자정 기준으로 일별 스냅샷을 누적한다.
  // 같은 날 여러 번 갱신돼도 같은 키로 덮어쓰여 1일 1건만 남는다.
  unawaited(_recordPriceSnapshots(ref, stations, fuelType));

  return stations;
});

Future<void> _recordPriceSnapshots(
  Ref ref,
  List<Station> stations,
  FuelType fuelType,
) async {
  try {
    final repo = await ref.read(priceSnapshotRepositoryProvider.future);
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    final snapshots = <PriceSnapshot>[];
    for (final s in stations) {
      final price = s.priceOf(fuelType);
      if (price == null) continue;
      snapshots.add(PriceSnapshot(
        stationId: s.id,
        fuelType: fuelType,
        date: normalized,
        price: price,
      ));
    }
    if (snapshots.isEmpty) return;
    await repo.upsertAll(snapshots);
  } catch (_) {
    // 스냅샷 저장 실패는 사용자 흐름을 막지 않는다.
  }
}

final stationByIdProvider = FutureProvider.family<Station?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(stationRepositoryProvider);
  final station = await repo.fetchById(id);
  if (station != null && station.prices.isNotEmpty) {
    // 상세 진입 시점에 주유소가 가진 모든 연료 가격을 스냅샷한다.
    unawaited(_recordDetailSnapshot(ref, station));
  }
  return station;
});

Future<void> _recordDetailSnapshot(Ref ref, Station station) async {
  try {
    final repo = await ref.read(priceSnapshotRepositoryProvider.future);
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    final snapshots = station.prices.entries.map((e) => PriceSnapshot(
          stationId: station.id,
          fuelType: e.key,
          date: normalized,
          price: e.value,
        ));
    await repo.upsertAll(snapshots);
  } catch (_) {}
}

final filteredStationsProvider = Provider<AsyncValue<List<Station>>>((ref) {
  final asyncStations = ref.watch(stationsProvider);
  final fuelType = ref.watch(selectedFuelTypeProvider);
  final sort = ref.watch(selectedSortOrderProvider);

  return asyncStations.whenData((stations) {
    final list = stations
        .where((s) => s.priceOf(fuelType) != null)
        .toList(growable: false);

    final sorted = [...list];
    switch (sort) {
      case SortOrder.price:
        sorted.sort(
          (a, b) => (a.priceOf(fuelType)!).compareTo(b.priceOf(fuelType)!),
        );
      case SortOrder.distance:
        sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case SortOrder.brand:
        sorted.sort((a, b) => a.brand.label.compareTo(b.brand.label));
    }
    return sorted;
  });
});

final neighborhoodAverageProvider = Provider<AsyncValue<int?>>((ref) {
  final asyncStations = ref.watch(stationsProvider);
  final fuelType = ref.watch(selectedFuelTypeProvider);
  return asyncStations.whenData((stations) {
    final prices = stations
        .map((s) => s.priceOf(fuelType))
        .whereType<int>()
        .toList();
    if (prices.isEmpty) return null;
    final sum = prices.reduce((a, b) => a + b);
    return (sum / prices.length).round();
  });
});

final nationalAveragesProvider = FutureProvider<Map<FuelType, int>>((ref) async {
  final api = ref.watch(opinetApiProvider);
  final list = await api.avgAllPrice();
  final result = <FuelType, int>{};
  for (final raw in list) {
    if (raw is! Map) continue;
    final code = raw['PRODCD'] as String?;
    final fuelType = OpinetCodes.fuelFromCode(code);
    final price = _parsePrice(raw['PRICE']);
    if (fuelType != null && price != null) {
      result[fuelType] = price;
    }
  }
  return result;
});

final nationalAverageProvider = Provider<int?>((ref) {
  final asyncMap = ref.watch(nationalAveragesProvider);
  final fuelType = ref.watch(selectedFuelTypeProvider);
  return asyncMap.maybeWhen(
    data: (map) => map[fuelType],
    orElse: () => null,
  );
});

int? _parsePrice(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.round();
  if (v is String) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed)?.round();
  }
  return null;
}
