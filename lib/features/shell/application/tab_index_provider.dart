import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) {
    if (state != index) state = index;
  }
}

final selectedTabIndexProvider = NotifierProvider<TabIndexNotifier, int>(
  TabIndexNotifier.new,
);

class ShellTabs {
  static const int home = 0;
  static const int map = 1;
  static const int favorites = 2;
  static const int logs = 3;
  static const int stats = 4;
}
