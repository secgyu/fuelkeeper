import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/core/location/kakao_local_repository.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final searchResultsProvider = FutureProvider<List<KakaoPlace>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 2) return const [];

  final kakao = ref.read(kakaoLocalRepositoryProvider);
  final centerAsync = ref.watch(currentLocationProvider);
  final center = centerAsync.maybeWhen(data: (l) => l, orElse: () => null);

  return kakao.searchPlaces(query, center: center);
});
