import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/features/favorites/application/favorites_providers.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';

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
            const _SectionHeader('기본 설정'),
            _FuelTypeTile(),
            const _Divider(),
            _LocationRefreshTile(),

            const SizedBox(height: AppSpacing.lg),
            const _SectionHeader('데이터 관리'),
            _FavoritesTile(),
            const _Divider(),
            _LogsTile(),

            const SizedBox(height: AppSpacing.lg),
            const _SectionHeader('앱 정보'),
            const _InfoTile(
              icon: Icons.info_outline_rounded,
              title: '버전',
              trailing: _appVersion,
            ),
            const _Divider(),
            const _InfoTile(
              icon: Icons.cloud_outlined,
              title: '데이터 출처',
              trailing: 'Opinet · Naver Map',
            ),
            const _Divider(),
            _LicensesTile(),

            const SizedBox(height: AppSpacing.xl),
            const _Footer(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Divider(height: 1, thickness: 1, color: AppColors.borderHair),
    );
  }
}

class _FuelTypeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFuelTypeProvider);

    return _BaseTile(
      icon: Icons.local_gas_station_rounded,
      title: '기본 연료 종류',
      trailing: Text(
        selected.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      onTap: () => _showFuelTypePicker(context, ref, selected),
    );
  }

  Future<void> _showFuelTypePicker(
    BuildContext context,
    WidgetRef ref,
    FuelType current,
  ) async {
    final picked = await showModalBottomSheet<FuelType>(
      context: context,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '기본 연료 종류',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            for (final t in FuelType.values)
              ListTile(
                title: Text(t.label),
                trailing: t == current
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(t),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );

    if (picked != null && picked != current) {
      ref.read(selectedFuelTypeProvider.notifier).set(picked);
    }
  }
}

class _LocationRefreshTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BaseTile(
      icon: Icons.my_location_rounded,
      title: '위치 다시 가져오기',
      subtitle: '현재 GPS 좌표를 다시 조회합니다',
      onTap: () {
        ref.invalidate(currentLocationProvider);
        ref.invalidate(currentAddressProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치를 새로 가져오는 중이에요'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

class _FavoritesTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFavorites = ref.watch(favoriteIdsProvider);
    final count = asyncFavorites.value?.length ?? 0;

    return _BaseTile(
      icon: Icons.favorite_outline_rounded,
      title: '즐겨찾기',
      subtitle: '등록된 주유소 $count개',
      trailing: count == 0
          ? null
          : TextButton(
              onPressed: () => _confirmClear(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: const Text(
                '전체 삭제',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await _showConfirmDialog(
      context,
      title: '즐겨찾기 전체 삭제',
      message: '저장된 즐겨찾기를 모두 삭제할까요?\n이 작업은 되돌릴 수 없어요.',
    );
    if (ok != true) return;

    final repo = ref.read(favoritesRepositoryProvider);
    await repo.save(const <String>{});
    ref.invalidate(favoriteIdsProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('즐겨찾기가 모두 삭제되었어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LogsTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(fuelLogsProvider);
    final count = asyncLogs.value?.length ?? 0;

    return _BaseTile(
      icon: Icons.history_rounded,
      title: '주유 기록',
      subtitle: '저장된 기록 $count건',
      trailing: count == 0
          ? null
          : TextButton(
              onPressed: () => _confirmClear(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: const Text(
                '전체 삭제',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await _showConfirmDialog(
      context,
      title: '주유 기록 전체 삭제',
      message: '모든 주유 기록을 삭제할까요?\n이 작업은 되돌릴 수 없어요.',
    );
    if (ok != true) return;

    final box = await ref.read(fuelLogBoxProvider.future);
    await box.clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('주유 기록이 모두 삭제되었어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LicensesTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      icon: Icons.description_outlined,
      title: '오픈소스 라이선스',
      onTap: () => showLicensePage(
        context: context,
        applicationName: 'FuelKeeper',
        applicationVersion: SettingsPage._appVersion,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      icon: icon,
      title: title,
      trailing: Text(
        trailing,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _BaseTile extends StatelessWidget {
  const _BaseTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.borderHair),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (onTap != null && trailing == null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Column(
        children: [
          Text(
            'FuelKeeper',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textTertiary,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Made with Flutter',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('취소'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger.withValues(alpha: 0.1),
            foregroundColor: AppColors.danger,
          ),
          child: const Text('삭제'),
        ),
      ],
    ),
  );
}
