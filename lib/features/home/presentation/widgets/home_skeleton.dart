import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/widgets/skeleton.dart';

/// 홈 화면 로딩 시 표시되는 일관된 스켈레톤.
///
/// PriceBanner / FuelTypeFilterRow / TopStationCard / StationListTile 모양을
/// 흐리게 모사해 실제 컨텐츠가 들어왔을 때 레이아웃 점프가 없게 한다.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xxl,
      ),
      children: const [
        _PriceBannerSkeleton(),
        SizedBox(height: AppSpacing.base),
        _FuelChipsSkeleton(),
        SizedBox(height: AppSpacing.base),
        _ListHeaderSkeleton(),
        SizedBox(height: AppSpacing.base),
        _TopStationCardSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _StationTileSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _StationTileSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _StationTileSkeleton(),
      ],
    );
  }
}

class _PriceBannerSkeleton extends StatelessWidget {
  const _PriceBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderHair),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 70, height: 12),
                SizedBox(height: 8),
                Skeleton(width: 110, height: 22),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 60, height: 12),
                SizedBox(height: 8),
                Skeleton(width: 110, height: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelChipsSkeleton extends StatelessWidget {
  const _FuelChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            const Skeleton(width: 64, height: 36, radius: 999),
            if (i < 3) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ListHeaderSkeleton extends StatelessWidget {
  const _ListHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Skeleton(width: 80, height: 14),
        Skeleton(width: 140, height: 14),
      ],
    );
  }
}

class _TopStationCardSkeleton extends StatelessWidget {
  const _TopStationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderHair),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 50, height: 18, radius: 999),
              Skeleton(width: 50, height: 14),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Skeleton(width: 100, height: 14),
          SizedBox(height: 8),
          Skeleton(width: 180, height: 22),
          SizedBox(height: AppSpacing.md),
          Skeleton(width: 200, height: 38),
          SizedBox(height: AppSpacing.sm),
          Skeleton(width: 140, height: 14),
        ],
      ),
    );
  }
}

class _StationTileSkeleton extends StatelessWidget {
  const _StationTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderHair),
      ),
      child: const Row(
        children: [
          Skeleton(width: 24, height: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 140, height: 14),
                SizedBox(height: 6),
                Skeleton(width: 100, height: 12),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Skeleton(width: 80, height: 18),
              SizedBox(height: 6),
              Skeleton(width: 50, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
