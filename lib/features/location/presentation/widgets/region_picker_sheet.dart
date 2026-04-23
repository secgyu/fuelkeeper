import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/location/application/location_providers.dart';
import 'package:fuelkeeper/features/location/domain/region.dart';

Future<void> showRegionPickerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RegionPickerSheet(),
  );
}

class _RegionPickerSheet extends ConsumerWidget {
  const _RegionPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedRegionProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderHair,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.base,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Text('지역 선택', style: AppTypography.h3),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderHair),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: kMockRegions.length,
                  itemBuilder: (context, i) {
                    final region = kMockRegions[i];
                    final isSelected = region.id == selected.id;
                    return _RegionTile(
                      region: region,
                      selected: isSelected,
                      onTap: () {
                        ref.read(selectedRegionProvider.notifier).set(region);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final Region region;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : AppColors.bgMuted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region.short,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(region.sido, style: AppTypography.caption),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
