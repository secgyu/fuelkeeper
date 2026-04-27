import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_text.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/section_block.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/tag_chip.dart';

class FuelPriceTable extends StatelessWidget {
  const FuelPriceTable({
    super.key,
    required this.station,
    required this.currentFuel,
  });

  final Station station;
  final FuelType currentFuel;

  @override
  Widget build(BuildContext context) {
    final entries = FuelType.values
        .where((t) => station.priceOf(t) != null)
        .toList();
    return SectionBlock(
      title: '연료별 가격',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderHair),
        ),
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              _FuelPriceRow(
                fuel: entries[i],
                price: station.priceOf(entries[i])!,
                isCurrent: entries[i] == currentFuel,
              ),
              if (i != entries.length - 1)
                const Divider(
                  height: 1,
                  color: AppColors.borderHair,
                  indent: AppSpacing.base,
                  endIndent: AppSpacing.base,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FuelPriceRow extends StatelessWidget {
  const _FuelPriceRow({
    required this.fuel,
    required this.price,
    required this.isCurrent,
  });

  final FuelType fuel;
  final int price;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            fuel.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            const TagChip(label: '선택', color: AppColors.primary),
          ],
          const Spacer(),
          PriceText(
            amount: price,
            size: 16,
            weight: FontWeight.w700,
            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
