import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';

class AppLifecycleObserver extends ConsumerStatefulWidget {
  const AppLifecycleObserver({
    super.key,
    required this.child,
    this.staleAfter = const Duration(minutes: 5),
  });

  final Widget child;
  final Duration staleAfter;

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        _pausedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.detached:
        break;
    }
  }

  void _onResumed() {
    final pausedAt = _pausedAt;
    _pausedAt = null;

    final stale =
        pausedAt == null ||
        DateTime.now().difference(pausedAt) >= widget.staleAfter;

    ref.invalidate(currentLocationProvider);
    ref.invalidate(currentAddressProvider);

    if (stale) {
      ref.read(stationRepositoryProvider).clearCache();
      ref.invalidate(stationsProvider);
      ref.invalidate(nationalAveragesProvider);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
