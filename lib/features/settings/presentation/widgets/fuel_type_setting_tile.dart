import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';

class FuelTypeSettingTile extends ConsumerWidget {
  const FuelTypeSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFuelTypeProvider);

    return SettingsTile(
      icon: Icons.local_gas_station_rounded,
      title: '기본 연료 종류',
      trailing: Text(
        selected.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      onTap: () => _showPicker(context, ref, selected),
    );
  }

  Future<void> _showPicker(
    BuildContext context,
    WidgetRef ref,
    FuelType current,
  ) async {
    final picked = await showModalBottomSheet<FuelType>(
      context: context,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _FuelTypePickerSheet(current: current),
    );

    if (picked != null && picked != current) {
      ref.read(selectedFuelTypeProvider.notifier).set(picked);
    }
  }
}

class _FuelTypePickerSheet extends StatelessWidget {
  const _FuelTypePickerSheet({required this.current});

  final FuelType current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '기본 연료 종류',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          for (final t in FuelType.values)
            ListTile(
              title: Text(t.label),
              trailing: t == current
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(t),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
