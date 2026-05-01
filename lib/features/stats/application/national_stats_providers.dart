import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/stats/data/national_stats_repository.dart';
import 'package:fuelkeeper/features/stats/domain/national_price.dart';
import 'package:fuelkeeper/features/stats/domain/sido.dart';

final nationalStatsRepositoryProvider = Provider<NationalStatsRepository>((
  ref,
) {
  return NationalStatsRepository(api: ref.watch(opinetApiProvider));
});

final sidoAveragesProvider = FutureProvider.family<List<SidoAverage>, FuelType>(
  (ref, fuelType) async {
    final repo = ref.watch(nationalStatsRepositoryProvider);
    return repo.fetchSidoAverages(fuelType);
  },
);

final lowTop10Provider =
    FutureProvider.family<List<LowPriceStation>, (Sido, FuelType)>((
      ref,
      args,
    ) async {
      final (sido, fuelType) = args;
      final repo = ref.watch(nationalStatsRepositoryProvider);
      return repo.fetchLowTop10(sido, fuelType);
    });

class SelectedSidoNotifier extends Notifier<Sido?> {
  @override
  Sido? build() => null;

  void set(Sido sido) => state = sido;
}

final selectedSidoProvider = NotifierProvider<SelectedSidoNotifier, Sido?>(
  SelectedSidoNotifier.new,
);

final autoDetectedSidoProvider = FutureProvider<Sido?>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  final kakao = ref.watch(kakaoLocalRepositoryProvider);
  final regionName = await kakao.reverseRegionDepth1(location);
  return Sido.fromRegionName(regionName);
});

final effectiveSidoProvider = Provider<Sido>((ref) {
  final selected = ref.watch(selectedSidoProvider);
  if (selected != null) return selected;
  final auto = ref.watch(autoDetectedSidoProvider).value;
  return auto ?? Sido.seoul;
});
