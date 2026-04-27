import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';

Future<FuelType?> showFuelPickerSheet(
  BuildContext context, {
  required FuelType current,
}) {
  return showModalBottomSheet<FuelType>(
    context: context,
    backgroundColor: AppColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) => _FuelPickerContent(current: current),
  );
}

class _FuelPickerContent extends StatelessWidget {
  const _FuelPickerContent({required this.current});

  final FuelType current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '연료 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            ...FuelType.values.map((fuel) {
              final isSelected = fuel == current;
              return ListTile(
                title: Text(
                  fuel.label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.textPrimary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(fuel),
              );
            }),
          ],
        ),
      ),
    );
  }
}
