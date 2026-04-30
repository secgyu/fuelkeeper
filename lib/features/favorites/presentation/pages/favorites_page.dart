import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/favorites/application/favorites_providers.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/station_list_tile.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFavStations = ref.watch(favoriteStationsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: SafeArea(
        child: asyncFavStations.when(
          loading: () => const _Loading(),
          error: (_, _) => const Center(child: Text('즐겨찾기를 불러오지 못했어요')),
          data: (favStations) {
            if (favStations.isEmpty) return const _EmptyState();

            final priced = favStations
                .where((s) => s.priceOf(fuelType) != null)
                .toList();

            if (priced.isEmpty) {
              return const _NoPriceForFuelState();
            }

            final lowest = priced
                .map((s) => s.priceOf(fuelType)!)
                .reduce((a, b) => a < b ? a : b);

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(favoriteStationsProvider),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.sm,
                  AppSpacing.base,
                  AppSpacing.xxl,
                ),
                itemCount: priced.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => StationListTile(
                  rank: i + 1,
                  station: priced[i],
                  fuelType: fuelType,
                  lowestPrice: lowest,
                  onTap: () =>
                      context.push(AppRoutes.stationDetail(priced[i].id)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _NoPriceForFuelState extends StatelessWidget {
  const _NoPriceForFuelState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_gas_station_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('해당 연료 가격 정보가 없어요', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '다른 연료 종류로 변경해보세요',
              style: AppTypography.body2.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                color: AppColors.danger,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('아직 즐겨찾기가 없어요', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '주유소 옆 하트 버튼으로\n자주 가는 곳을 저장해보세요.',
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
