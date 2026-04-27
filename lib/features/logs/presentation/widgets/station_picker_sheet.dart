import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

class StationPickerSheet extends StatelessWidget {
  const StationPickerSheet({super.key, required this.stations});

  final List<Station> stations;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
              const SizedBox(height: AppSpacing.base),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('주유소 선택', style: AppTypography.h3),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.borderHair),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: stations.length,
                  itemBuilder: (context, i) {
                    final s = stations[i];
                    return ListTile(
                      onTap: () => Navigator.pop(context, s),
                      leading: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: s.brand.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${s.brand.label} · ${Formatters.km(s.distanceKm)}',
                        style: AppTypography.caption,
                      ),
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
