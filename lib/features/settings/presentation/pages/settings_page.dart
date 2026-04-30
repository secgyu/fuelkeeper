import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/data_clear_tiles.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/fuel_type_setting_tile.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/theme_mode_setting_tile.dart';
import 'package:go_router/go_router.dart';

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
            const ThemeModeSettingTile(),
            const SettingsDivider(),
            const LocationRefreshTile(),
            const SizedBox(height: AppSpacing.lg),
            const SettingsSectionHeader('데이터 관리'),
            const FavoritesClearTile(),
            const SettingsDivider(),
            const FuelLogsClearTile(),
            const SizedBox(height: AppSpacing.lg),
            const SettingsSectionHeader('법적 정보'),
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 처리방침',
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
            const SettingsDivider(),
            SettingsTile(
              icon: Icons.gavel_outlined,
              title: '이용약관',
              onTap: () => context.push(AppRoutes.termsOfService),
            ),
            const SettingsDivider(),
            SettingsTile(
              icon: Icons.cloud_outlined,
              title: '데이터 출처 및 저작권',
              subtitle: 'Opinet · NAVER Maps · Kakao Local',
              onTap: () => context.push(AppRoutes.dataSources),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SettingsSectionHeader('앱 정보'),
            const SettingsInfoTile(
              icon: Icons.info_outline_rounded,
              title: '버전',
              trailing: _appVersion,
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
