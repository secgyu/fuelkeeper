import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/domain/station_amenity.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/section_block.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key, required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    return SectionBlock(
      title: '주유소 정보',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderHair),
        ),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: '주소',
              value: station.address,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.call_outlined,
              label: '전화',
              value: station.phone.isEmpty ? '-' : station.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: '영업시간',
              value: station.operatingHours,
            ),
            const SizedBox(height: AppSpacing.base),
            const Divider(height: 1, color: AppColors.borderHair),
            const SizedBox(height: AppSpacing.base),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '편의시설',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (station.amenities.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('등록된 편의시설이 없어요', style: AppTypography.caption),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final amenity in station.amenities)
                    _AmenityChip(amenity: amenity),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.amenity});

  final StationAmenity amenity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(amenity.icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            amenity.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
