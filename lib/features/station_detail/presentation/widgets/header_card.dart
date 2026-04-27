import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_text.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/tag_chip.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({
    super.key,
    required this.station,
    required this.price,
    required this.delta,
    required this.fuelType,
  });

  final Station station;
  final int price;
  final int? delta;
  final FuelType fuelType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderHair),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandRow(station: station),
          const SizedBox(height: AppSpacing.sm),
          Text(station.name, style: AppTypography.h1),
          const SizedBox(height: 4),
          Text(
            station.address,
            style: AppTypography.body2.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PriceRow(price: price, fuelType: fuelType),
          if (delta != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DeltaRow(delta: delta!),
          ],
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.station});
  final Station station;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: station.brand.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(station.brand.label, style: AppTypography.caption),
        if (station.isSelfService) ...[
          const SizedBox(width: 8),
          const TagChip(label: '셀프', color: AppColors.primary),
        ],
        const Spacer(),
        Text(
          '${station.distanceKm.toStringAsFixed(1)}km',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price, required this.fuelType});

  final int price;
  final FuelType fuelType;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PriceText(
          amount: price,
          size: 44,
          weight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        const SizedBox(width: 6),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            '원/L',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.bgMuted,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            fuelType.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.delta});
  final int delta;

  @override
  Widget build(BuildContext context) {
    final isCheaper = delta < 0;
    final color = isCheaper ? AppColors.accent : AppColors.danger;
    return Row(
      children: [
        Icon(
          isCheaper
              ? Icons.trending_down_rounded
              : Icons.trending_up_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          '전국 평균 대비',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isCheaper ? '$delta원' : '+$delta원',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
