import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

class StationPreviewCard extends StatelessWidget {
  const StationPreviewCard({
    super.key,
    required this.station,
    required this.fuelType,
    required this.onClose,
    required this.onTap,
  });

  final Station station;
  final FuelType fuelType;
  final VoidCallback onClose;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = station.priceOf(fuelType);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Material(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: station.brand.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${station.brand.label} · ${Formatters.km(station.distanceKm)}',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  if (price != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.won(price),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          fuelType.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: onClose,
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
