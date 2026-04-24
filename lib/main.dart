import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_theme.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_adapter.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_repository.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FuelLogAdapter());
  }
  try {
    await Hive.openBox<FuelLog>(HiveFuelLogRepository.boxName);
  } catch (_) {
    await Hive.deleteBoxFromDisk(HiveFuelLogRepository.boxName);
    await Hive.openBox<FuelLog>(HiveFuelLogRepository.boxName);
  }

  runApp(const ProviderScope(child: FuelKeeperApp()));
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
