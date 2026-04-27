import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/features/favorites/application/favorites_providers.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';

class LocationRefreshTile extends ConsumerWidget {
  const LocationRefreshTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsTile(
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

class FavoritesClearTile extends ConsumerWidget {
  const FavoritesClearTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFavorites = ref.watch(favoriteIdsProvider);
    final count = asyncFavorites.value?.length ?? 0;

    return SettingsTile(
      icon: Icons.favorite_outline_rounded,
      title: '즐겨찾기',
      subtitle: '등록된 주유소 $count개',
      trailing: count == 0 ? null : _ClearButton(onPressed: () => _confirm(context, ref)),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final ok = await showDangerConfirmDialog(
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

class FuelLogsClearTile extends ConsumerWidget {
  const FuelLogsClearTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(fuelLogsProvider);
    final count = asyncLogs.value?.length ?? 0;

    return SettingsTile(
      icon: Icons.history_rounded,
      title: '주유 기록',
      subtitle: '저장된 기록 $count건',
      trailing: count == 0 ? null : _ClearButton(onPressed: () => _confirm(context, ref)),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final ok = await showDangerConfirmDialog(
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

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.danger,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      child: const Text(
        '전체 삭제',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
