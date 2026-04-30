import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자가 선택한 주변 주유소 검색 반경(미터).
///
/// 1km / 3km / 5km / 10km 4단계 중 하나. SharedPreferences에 영속화한다.
class SearchRadiusNotifier extends Notifier<int> {
  static const _prefsKey = 'app.searchRadiusMeters';

  /// 사용자가 선택할 수 있는 반경 옵션(미터).
  static const options = <int>[1000, 3000, 5000, 10000];

  static const defaultRadius = 5000;

  @override
  int build() {
    _restore();
    return defaultRadius;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getInt(_prefsKey);
      if (raw != null && options.contains(raw)) {
        state = raw;
      }
    } catch (_) {
      // 저장소 오류 시 기본값 유지.
    }
  }

  Future<void> set(int meters) async {
    if (!options.contains(meters)) return;
    state = meters;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, meters);
    } catch (_) {
      // 저장 실패해도 메모리 상태는 유지.
    }
  }
}

final searchRadiusProvider = NotifierProvider<SearchRadiusNotifier, int>(
  SearchRadiusNotifier.new,
);

/// 미터를 사용자에게 보여줄 라벨로 변환한다. (1000 → "1km")
String radiusLabel(int meters) {
  if (meters % 1000 == 0) return '${meters ~/ 1000}km';
  return '${(meters / 1000).toStringAsFixed(1)}km';
}
