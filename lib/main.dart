import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/config/kakao_config.dart';
import 'package:fuelkeeper/app/config/naver_map_config.dart';
import 'package:fuelkeeper/app/config/opinet_config.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_theme.dart';
import 'package:fuelkeeper/app/theme/theme_mode_provider.dart';
import 'package:fuelkeeper/core/lifecycle/app_lifecycle_observer.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_adapter.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_repository.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:fuelkeeper/features/notifications/local_notifications.dart';
import 'package:fuelkeeper/features/notifications/notification_providers.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot_adapter.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot_repository.dart';
import 'package:fuelkeeper/features/vehicles/data/vehicle_adapter.dart';
import 'package:fuelkeeper/features/vehicles/data/vehicle_repository.dart';
import 'package:fuelkeeper/features/vehicles/domain/vehicle.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _assertSecretsConfigured();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FuelLogAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(VehicleAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(PriceSnapshotAdapter());
  }
  await _openHiveBox<FuelLog>(HiveFuelLogRepository.boxName);
  await _openHiveBox<Vehicle>(HiveVehicleRepository.boxName);
  await _openHiveBox<PriceSnapshot>(HivePriceSnapshotRepository.boxName);

  await LocalNotifications.instance.init();

  await FlutterNaverMap().init(
    clientId: NaverMapConfig.clientId,
    onAuthFailed: (e) {
      debugPrint('NaverMap auth failed: $e');
    },
  );

  runApp(
    const ProviderScope(
      child: AppLifecycleObserver(child: FuelKeeperApp()),
    ),
  );
}

void _assertSecretsConfigured() {
  final missing = <String>[
    if (!OpinetConfig.isConfigured) 'OPINET_API_KEY',
    if (!NaverMapConfig.isConfigured) 'NAVER_MAP_CLIENT_ID',
    if (!KakaoConfig.isConfigured) 'KAKAO_REST_API_KEY',
  ];
  if (missing.isEmpty) return;

  final message =
      'API 키가 주입되지 않았습니다: ${missing.join(', ')}\n'
      '실행 시 `--dart-define-from-file=dart_defines.json`을 추가하거나 '
      '.vscode/launch.json 구성을 사용하세요.';

  if (kDebugMode) {
    debugPrint('\n=== [FuelKeeper] CONFIG WARNING ===\n$message\n');
  } else {
    debugPrint('[FuelKeeper] $message');
  }
}

Future<void> _openHiveBox<T>(String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
    return;
  } catch (e, st) {
    debugPrint('[hive] open "$boxName" failed: $e\n$st');
  }

  await _quarantineHiveBox(boxName);
  await Hive.openBox<T>(boxName);
}

Future<void> _quarantineHiveBox(String name) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    final hiveFile = File('${dir.path}/$name.hive');
    if (await hiveFile.exists()) {
      await hiveFile.rename('${dir.path}/$name.corrupted.$ts.hive');
    }

    final lockFile = File('${dir.path}/$name.lock');
    if (await lockFile.exists()) {
      await lockFile.delete();
    }
  } catch (e, st) {
    debugPrint('[hive] quarantine "$name" failed: $e\n$st');
  }
}

class FuelKeeperApp extends ConsumerWidget {
  const FuelKeeperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // 알림 ON/OFF·주기·로그 변화에 맞춰 OS 스케줄을 자동 재예약한다.
    ref.watch(fuelReminderSchedulerProvider);
    return MaterialApp.router(
      title: 'FuelKeeper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        // 시스템 텍스트 스케일이 너무 작거나 크면 레이아웃이 깨지는 화면이 있다.
        // 0.9 ~ 1.3 구간으로 클램프해 가독성을 유지하면서도 사용자 설정을 일부 존중한다.
        // 이 값은 향후 접근성 개선 시 1.5까지 상향을 검토할 수 있다.
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
