import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollapsedSectionsNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'stats_collapsed_sections_v1';
  static const defaultCollapsed = <String>{
    'low_top10',
    'monthly_cost',
    'efficiency_trend',
    'fuel_share',
    'frequent_stations',
  };

  @override
  Set<String> build() {
    Future.microtask(_load);
    return defaultCollapsed;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey);
    if (list == null) return;
    state = list.toSet();
  }

  Future<void> _persist(Set<String> next) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
  }

  bool isCollapsed(String id) => state.contains(id);

  void toggle(String id) {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    _persist(next);
  }
}

final collapsedSectionsProvider =
    NotifierProvider<CollapsedSectionsNotifier, Set<String>>(
      CollapsedSectionsNotifier.new,
    );
