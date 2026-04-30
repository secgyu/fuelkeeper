import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/config/naver_map_config.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_theme.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_adapter.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_repository.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const ProviderScope(child: FuelKeeperApp()));
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
