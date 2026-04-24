import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/home/data/mock_station_repository.dart';
import 'package:fuelkeeper/features/home/data/opinet_station_repository.dart';
import 'package:fuelkeeper/features/home/data/station_repository.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/sort_order.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

const bool _useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

final stationRepositoryProvider = Provider<StationRepository>((ref) {
  return _useMock ? MockStationRepository() : OpinetStationRepository();
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
  return repo.fetchNearby();
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

const Map<FuelType, int> _nationalAverageMock = {
  FuelType.gasoline: 1932,
  FuelType.premiumGasoline: 2235,
  FuelType.diesel: 1768,
  FuelType.lpg: 1105,
};

final nationalAverageProvider = Provider<int?>((ref) {
  final fuelType = ref.watch(selectedFuelTypeProvider);
  return _nationalAverageMock[fuelType];
});
