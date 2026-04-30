import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';

class FuelChipButton extends StatelessWidget {
  const FuelChipButton({
    super.key,
    required this.fuelType,
    required this.onTap,
  });

  final FuelType fuelType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Material(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_gas_station_rounded,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      fuelType.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
