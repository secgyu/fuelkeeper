import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/stats/application/national_stats_providers.dart';
import 'package:fuelkeeper/features/stats/domain/national_price.dart';

class SidoAveragesCard extends ConsumerWidget {
  const SidoAveragesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final asyncAverages = ref.watch(sidoAveragesProvider(fuelType));
    final selected = ref.watch(effectiveSidoProvider);

    return asyncAverages.when(
      loading: () => const _Skeleton(),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        child: Text(
          '시·도별 평균을 불러오지 못했어요',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Text(
              '데이터가 없어요',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          );
        }
        final cheapest = list.first.price;
        final dearest = list.last.price;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in list)
              _Row(
                entry: entry,
                cheapest: cheapest,
                dearest: dearest,
                isSelected: entry.sido == selected,
              ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.cheapest,
    required this.dearest,
    required this.isSelected,
  });

  final SidoAverage entry;
  final int cheapest;
  final int dearest;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final span = (dearest - cheapest).clamp(1, 1 << 30);
    final ratio = (entry.price - cheapest) / span;
    final length = (1.0 - ratio * 0.8).clamp(0.2, 1.0);
    final barColor = isSelected
        ? tokens.primary
        : tokens.textTertiary.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              entry.sido.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? tokens.primary : tokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Stack(
                children: [
                  Container(height: 8, color: tokens.bgMuted),
                  FractionallySizedBox(
                    widthFactor: length,
                    child: Container(height: 8, color: barColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 64,
            child: Text(
              '${entry.price.toString()}원',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
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
        6,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.bgMuted,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        ),
      ),
    );
  }
}
