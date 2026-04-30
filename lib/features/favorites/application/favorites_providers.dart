import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/favorites/data/favorites_repository.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(),
);

class FavoriteIds extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final repo = ref.read(favoritesRepositoryProvider);
    return repo.load();
  }

  Future<void> toggle(String id) async {
    final current = state.value ?? const <String>{};
    final next = {...current};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = AsyncValue.data(next);
    await ref.read(favoritesRepositoryProvider).save(next);
  }
}

final favoriteIdsProvider = AsyncNotifierProvider<FavoriteIds, Set<String>>(
  FavoriteIds.new,
);

final isFavoriteProvider = Provider.family<bool, String>((ref, stationId) {
  final asyncIds = ref.watch(favoriteIdsProvider);
  return asyncIds.value?.contains(stationId) ?? false;
});

final favoriteStationsProvider = FutureProvider<List<Station>>((ref) async {
  final ids = await ref.watch(favoriteIdsProvider.future);
  if (ids.isEmpty) return const [];

  final repo = ref.watch(stationRepositoryProvider);
  final results = await Future.wait(
    ids.map((id) async {
      try {
        return await repo.fetchById(id);
      } catch (_) {
        return null;
      }
    }),
  );
  return results.whereType<Station>().toList();
});
