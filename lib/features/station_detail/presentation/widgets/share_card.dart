import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

/// 공유용 정사각형(또는 4:5) 카드. 화면에 직접 노출되지는 않고
/// `Screenshot` 컨트롤러로 이미지화되는 게 주 용도다.
class StationShareCard extends StatelessWidget {
  const StationShareCard({
    super.key,
    required this.station,
    required this.fuelType,
    required this.price,
    this.delta,
  });

  final Station station;
  final FuelType fuelType;
  final int price;
  final int? delta;

  @override
  Widget build(BuildContext context) {
    final isCheaper = (delta ?? 0) < 0;

    return Material(
      color: context.colors.bgPrimary,
      child: SizedBox(
        width: 360,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            border: Border.all(color: context.colors.borderHair),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: station.brand.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.local_gas_station_rounded,
                      color: station.brand.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    station.brand.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'FuelKeeper',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: context.colors.bgPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                station.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (station.address.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  station.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: context.colors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: context.colors.borderHair),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fuelType.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.thousands(price),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: context.colors.textPrimary,
                            letterSpacing: -1,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            ' 원/L',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (delta != null && delta != 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isCheaper
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: 14,
                            color: isCheaper
                                ? context.colors.accent
                                : context.colors.danger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '전국 평균보다 ${delta!.abs()}원 ${isCheaper ? '저렴' : '비쌈'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isCheaper
                                  ? context.colors.accent
                                  : context.colors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _todayLabel(),
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _todayLabel() {
    final n = DateTime.now();
    final mm = n.month.toString().padLeft(2, '0');
    final dd = n.day.toString().padLeft(2, '0');
    return '${n.year}.$mm.$dd 기준';
  }
}
