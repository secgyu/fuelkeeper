import 'package:go_router/go_router.dart';

import 'package:fuelkeeper/features/favorites/presentation/pages/favorites_page.dart';
import 'package:fuelkeeper/features/home/presentation/pages/home_page.dart';
import 'package:fuelkeeper/features/logs/presentation/pages/logs_page.dart';
import 'package:fuelkeeper/features/map/presentation/pages/map_page.dart';
import 'package:fuelkeeper/features/notifications/presentation/pages/notifications_page.dart';
import 'package:fuelkeeper/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fuelkeeper/features/onboarding/presentation/pages/permission_page.dart';
import 'package:fuelkeeper/features/shell/presentation/main_shell.dart';
import 'package:fuelkeeper/features/splash/presentation/pages/splash_page.dart';
import 'package:fuelkeeper/features/stats/presentation/pages/stats_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const permission = '/permission';

  static const home = '/home';
  static const map = '/map';
  static const favorites = '/favorites';
  static const logs = '/logs';
  static const stats = '/stats';

  static const notifications = '/notifications';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SplashPage()),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OnboardingPage()),
    ),
    GoRoute(
      path: AppRoutes.permission,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PermissionPage()),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),
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
