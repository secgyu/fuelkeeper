import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/core/network/opinet_api.dart';
import 'package:fuelkeeper/features/home/data/opinet_codes.dart';
import 'package:fuelkeeper/features/home/data/opinet_station_repository.dart';
import 'package:fuelkeeper/features/home/data/station_repository.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/sort_order.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

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
  final location = await ref.watch(currentLocationProvider.future);
  return repo.fetchNearby(
    fuelType: fuelType,
    latitude: location.latitude,
    longitude: location.longitude,
  );
});

final stationByIdProvider = FutureProvider.family<Station?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.fetchById(id);
});

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
