import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/favorites/application/favorites_providers.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/station_list_tile.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFavIds = ref.watch(favoriteIdsProvider);
    final asyncStations = ref.watch(stationsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: SafeArea(
        child: asyncStations.when(
          loading: () => const _Loading(),
          error: (e, _) => Center(child: Text('주유소 정보를 불러오지 못했어요\n$e')),
          data: (allStations) {
            return asyncFavIds.when(
              loading: () => const _Loading(),
              error: (e, _) => Center(child: Text('즐겨찾기를 불러오지 못했어요\n$e')),
              data: (favIds) {
                final favStations = allStations
                    .where((s) => favIds.contains(s.id))
                    .toList();

                if (favStations.isEmpty) return const _EmptyState();

                final lowest = favStations
                    .map((s) => s.priceOf(fuelType)!)
                    .reduce((a, b) => a < b ? a : b);

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.sm,
                    AppSpacing.base,
                    AppSpacing.xxl,
                  ),
                  itemCount: favStations.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => StationListTile(
                    rank: i + 1,
                    station: favStations[i],
                    fuelType: fuelType,
                    lowestPrice: lowest,
                    onTap: () {},
                  ),
                );
              },
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
