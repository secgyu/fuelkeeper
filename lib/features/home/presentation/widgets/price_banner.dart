import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/delta_chip.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_text.dart';

class PriceBanner extends ConsumerWidget {
  const PriceBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final national = ref.watch(nationalAverageProvider);
    final neighborhoodAsync = ref.watch(neighborhoodAverageProvider);

    final neighborhood = neighborhoodAsync.value;
    final delta = (national != null && neighborhood != null)
        ? neighborhood - national
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderHair),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BannerCell(label: '우리동네 평균', value: neighborhood),
          ),
          Container(width: 1, height: 40, color: context.colors.borderHair),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.base),
              child: _BannerCell(label: '전국 평균', value: national, muted: true),
            ),
          ),
          if (delta != null) DeltaChip(value: delta),
        ],
      ),
    );
  }
}

class _BannerCell extends StatelessWidget {
  const _BannerCell({
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final int? value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        if (value == null)
          SizedBox(
            height: 22,
            width: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.bgMuted,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ),
          )
        else
          PriceText(
            amount: value!,
            size: 22,
            weight: FontWeight.w700,
            color: muted ? context.colors.textSecondary : context.colors.textPrimary,
          ),
      ],
    );
  }
}
