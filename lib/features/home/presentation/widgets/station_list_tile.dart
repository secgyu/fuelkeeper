import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/utils/external_launcher.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/favorites/application/favorites_providers.dart';
import 'package:fuelkeeper/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_text.dart';

class StationListTile extends ConsumerWidget {
  const StationListTile({
    super.key,
    required this.rank,
    required this.station,
    required this.fuelType,
    required this.lowestPrice,
    this.onTap,
  });

  final int rank;
  final Station station;
  final FuelType fuelType;
  final int lowestPrice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = station.priceOf(fuelType)!;
    final diffFromLowest = price - lowestPrice;
    final priceLabel = '${fuelType.label} 가격 ${Formatters.thousands(price)}원';
    final diffLabel = diffFromLowest == 0
        ? ', 최저가'
        : ', 최저가보다 ${Formatters.thousands(diffFromLowest)}원 비쌈';
    final distanceLabel = ', 거리 ${Formatters.km(station.distanceKm)}';
    final selfLabel = station.isSelfService ? ', 셀프 주유' : '';
    final isFav = ref.watch(isFavoriteProvider(station.id));

    void toggleFavorite() {
      ref.read(favoriteIdsProvider.notifier).toggle(station.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isFav ? '즐겨찾기에서 제거했어요' : '즐겨찾기에 추가했어요',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    Future<void> openDirections() async {
      if (!station.hasCoordinates) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 정보가 없어요'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await ExternalLauncher.drivingDirections(
        context,
        latitude: station.latitude!,
        longitude: station.longitude!,
        name: station.name,
      );
    }

    return Semantics(
      button: true,
      label:
          '$rank위, ${station.name}, ${station.brand.label}, '
          '$priceLabel$diffLabel$distanceLabel$selfLabel',
      child: Slidable(
        key: ValueKey('station-${station.id}'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: station.hasCoordinates ? 0.5 : 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => toggleFavorite(),
              backgroundColor: isFav
                  ? context.colors.textTertiary
                  : context.colors.danger,
              foregroundColor: Colors.white,
              icon: isFav
                  ? Icons.heart_broken_rounded
                  : Icons.favorite_rounded,
              label: isFav ? '해제' : '즐겨찾기',
            ),
            if (station.hasCoordinates)
              SlidableAction(
                onPressed: (_) => openDirections(),
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                icon: Icons.directions_rounded,
                label: '길찾기',
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
              ),
          ],
        ),
        child: Material(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.base,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.colors.borderHair),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: station.brand.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(station.brand.label, style: AppTypography.caption),
                        const SizedBox(width: 8),
                        Container(
                          width: 2,
                          height: 2,
                          decoration: BoxDecoration(
                            color: context.colors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.km(station.distanceKm),
                          style: AppTypography.caption,
                        ),
                        if (station.isSelfService) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              color: context.colors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('셀프', style: AppTypography.caption),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceText(amount: price, size: 18, weight: FontWeight.w700),
                  const SizedBox(height: 4),
                  if (diffFromLowest == 0)
                    Text(
                      '최저',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.colors.accent,
                      ),
                    )
                  else
                    Text(
                      '+$diffFromLowest원',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textTertiary,
                      ),
                    ),
                ],
              ),
              FavoriteButton(stationId: station.id, size: 20),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}
