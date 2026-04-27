import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/data_clear_tiles.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/fuel_type_setting_tile.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
          children: [
            const SettingsSectionHeader('기본 설정'),
            const FuelTypeSettingTile(),
            const SettingsDivider(),
            const LocationRefreshTile(),
            const SizedBox(height: AppSpacing.lg),
            const SettingsSectionHeader('데이터 관리'),
            const FavoritesClearTile(),
            const SettingsDivider(),
            const FuelLogsClearTile(),
            const SizedBox(height: AppSpacing.lg),
            const SettingsSectionHeader('앱 정보'),
            const SettingsInfoTile(
              icon: Icons.info_outline_rounded,
              title: '버전',
              trailing: _appVersion,
            ),
            const SettingsDivider(),
            const SettingsInfoTile(
              icon: Icons.cloud_outlined,
              title: '데이터 출처',
              trailing: 'Opinet · Naver Map',
            ),
            const SettingsDivider(),
            SettingsTile(
              icon: Icons.description_outlined,
              title: '오픈소스 라이선스',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'FuelKeeper',
                applicationVersion: _appVersion,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SettingsFooter(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
