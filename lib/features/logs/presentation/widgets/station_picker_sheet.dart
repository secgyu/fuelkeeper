import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

class StationPickerSheet extends StatelessWidget {
  const StationPickerSheet({
    super.key,
    required this.stations,
    this.recommendedId,
  });

  final List<Station> stations;

  /// 가장 가까운 주유소 등 사용자에게 강조해서 보여줄 항목의 id.
  final String? recommendedId;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.borderHair,
                  borderRadius: BorderRadius.circular(AppRadius.full),
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
              Divider(height: 1, color: context.colors.borderHair),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: stations.length,
                  itemBuilder: (context, i) {
                    final s = stations[i];
                    final isRecommended = s.id == recommendedId;
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
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                '추천',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: context.colors.bgPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
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
