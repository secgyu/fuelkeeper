import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_text.dart';

class TopStationCard extends StatelessWidget {
  const TopStationCard({
    super.key,
    required this.station,
    required this.fuelType,
    required this.referencePrice,
    this.onTap,
  });

  final Station station;
  final FuelType fuelType;
  final int? referencePrice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = station.priceOf(fuelType)!;
    final delta = referencePrice != null ? price - referencePrice! : null;

    return Material(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderHair),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: AppColors.accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Badge(label: '최저가', color: AppColors.accent),
                              const SizedBox(width: AppSpacing.sm),
                              if (station.isSelfService)
                                const _Badge(
                                  label: '셀프',
                                  color: AppColors.primary,
                                  filled: false,
                                ),
                              const Spacer(),
                              Text(
                                Formatters.km(station.distanceKm),
                                style: AppTypography.caption,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              FavoriteButton(stationId: station.id),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: station.brand.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                station.brand.label,
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(station.name, style: AppTypography.h2),
                          const SizedBox(height: AppSpacing.base),
                          Row(
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
                            ],
                          ),
                          if (delta != null && delta < 0) ...[
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                const Icon(
                                  Icons.trending_down_rounded,
                                  color: AppColors.accent,
                                  size: 14,
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
                                  '$delta원',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.filled = true});

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
