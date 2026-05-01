import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/data/opinet_codes.dart';
import 'package:fuelkeeper/features/stats/application/national_stats_providers.dart';
import 'package:fuelkeeper/features/stats/domain/national_price.dart';
import 'package:go_router/go_router.dart';

class LowTop10Card extends ConsumerWidget {
  const LowTop10Card({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final sido = ref.watch(effectiveSidoProvider);
    final asyncList = ref.watch(lowTop10Provider((sido, fuelType)));

    return asyncList.when(
      loading: () => const _Skeleton(),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        child: Text(
          '저가 TOP10을 불러오지 못했어요',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Text(
              '${sido.label} 데이터가 없어요',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final entry in list.asMap().entries)
              _StationRow(rank: entry.key + 1, station: entry.value),
          ],
        );
      },
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({required this.rank, required this.station});

  final int rank;
  final LowPriceStation station;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final brand = OpinetCodes.brandFromCode(station.brandCode);
    final isTop3 = rank <= 3;

    return InkWell(
      onTap: () => context.push(AppRoutes.stationDetail(station.id)),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTop3
                    ? tokens.primary.withValues(alpha: 0.10)
                    : tokens.bgMuted,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isTop3 ? tokens.primary : tokens.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 6,
              height: 28,
              decoration: BoxDecoration(
                color: brand.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  if (station.address.isNotEmpty)
                    Text(
                      station.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: tokens.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${station.price}원',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: tokens.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              color: context.colors.bgMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
      ),
    );
  }
}
