import 'package:go_router/go_router.dart';

import 'package:fuelkeeper/features/favorites/presentation/pages/favorites_page.dart';
import 'package:fuelkeeper/features/home/presentation/pages/home_page.dart';
import 'package:fuelkeeper/features/logs/presentation/pages/logs_page.dart';
import 'package:fuelkeeper/features/map/presentation/pages/map_page.dart';
import 'package:fuelkeeper/features/shell/presentation/main_shell.dart';
import 'package:fuelkeeper/features/stats/presentation/pages/stats_page.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/home';
  static const map = '/map';
  static const favorites = '/favorites';
  static const logs = '/logs';
  static const stats = '/stats';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomePage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.map,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: MapPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: FavoritesPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.logs,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: LogsPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.stats,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: StatsPage()),
            ),
          ],
        ),
      ],
    ),
  ],
);
