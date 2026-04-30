import 'package:go_router/go_router.dart';

import 'package:fuelkeeper/features/favorites/presentation/pages/favorites_page.dart';
import 'package:fuelkeeper/features/home/presentation/pages/home_page.dart';
import 'package:fuelkeeper/features/legal/presentation/pages/data_sources_page.dart';
import 'package:fuelkeeper/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:fuelkeeper/features/legal/presentation/pages/terms_of_service_page.dart';
import 'package:fuelkeeper/features/logs/presentation/pages/logs_page.dart';
import 'package:fuelkeeper/features/map/presentation/pages/map_page.dart';
import 'package:fuelkeeper/features/settings/presentation/pages/settings_page.dart';
import 'package:fuelkeeper/features/shell/presentation/main_shell.dart';
import 'package:fuelkeeper/features/splash/presentation/pages/splash_page.dart';
import 'package:fuelkeeper/features/station_detail/presentation/pages/station_detail_page.dart';
import 'package:fuelkeeper/features/stats/presentation/pages/stats_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';

  static const home = '/home';
  static const map = '/map';
  static const favorites = '/favorites';
  static const logs = '/logs';
  static const stats = '/stats';

  static const settings = '/settings';
  static const station = '/station';

  static const privacyPolicy = '/legal/privacy';
  static const termsOfService = '/legal/terms';
  static const dataSources = '/legal/data-sources';

  static String stationDetail(String id) => '$station/$id';
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
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: AppRoutes.termsOfService,
      builder: (context, state) => const TermsOfServicePage(),
    ),
    GoRoute(
      path: AppRoutes.dataSources,
      builder: (context, state) => const DataSourcesPage(),
    ),
    GoRoute(
      path: '${AppRoutes.station}/:id',
      builder: (context, state) =>
          StationDetailPage(stationId: state.pathParameters['id']!),
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
