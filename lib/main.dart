import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_theme.dart';
import 'package:fuelkeeper/features/home/presentation/pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: FuelKeeperApp()));
}

class FuelKeeperApp extends StatelessWidget {
  const FuelKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuelKeeper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
