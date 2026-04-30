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
import 'package:fuelkeeper/core/lifecycle/app_lifecycle_observer.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_adapter.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_repository.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _assertSecretsConfigured();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FuelLogAdapter());
  }
  await _openFuelLogBox();

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

Future<void> _openFuelLogBox() async {
  const boxName = HiveFuelLogRepository.boxName;
  try {
    await Hive.openBox<FuelLog>(boxName);
    return;
  } catch (e, st) {
    debugPrint('[hive] open "$boxName" failed: $e\n$st');
  }

  await _quarantineHiveBox(boxName);
  await Hive.openBox<FuelLog>(boxName);
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

class FuelKeeperApp extends StatelessWidget {
  const FuelKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FuelKeeper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
