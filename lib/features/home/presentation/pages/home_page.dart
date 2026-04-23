import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/fuel_type_filter_row.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_banner.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/sort_filter_row.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/station_list_tile.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/top_station_card.dart';
import 'package:fuelkeeper/features/location/application/location_providers.dart';
import 'package:fuelkeeper/features/location/presentation/widgets/region_picker_sheet.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStations = ref.watch(filteredStationsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final national = ref.watch(nationalAverageProvider);
    final region = ref.watch(selectedRegionProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.base,
        title: InkWell(
          onTap: () => showRegionPickerSheet(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  region.short,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(stationsProvider.future),
          child: asyncStations.when(
            loading: () => const _LoadingState(),
            error: (e, _) => _ErrorState(message: e.toString()),
            data: (stations) {
              if (stations.isEmpty) return const _EmptyState();
              return _StationListView(
                stations: stations,
                fuelType: fuelType,
                referencePrice: national,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StationListView extends StatelessWidget {
  const _StationListView({
    required this.stations,
    required this.fuelType,
    required this.referencePrice,
  });

  final List<Station> stations;
  final dynamic fuelType;
  final int? referencePrice;

  @override
  Widget build(BuildContext context) {
    final lowest = stations
        .map((s) => s.priceOf(fuelType)!)
        .reduce((a, b) => a < b ? a : b);
    final top = stations.first;
    final rest = stations.skip(1).toList();

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xxl,
      ),
      itemCount: rest.length + 4,
      separatorBuilder: (context, i) {
        if (i == 0 || i == 1 || i == 2) {
          return const SizedBox(height: AppSpacing.base);
        }
        return const SizedBox(height: AppSpacing.sm);
      },
      itemBuilder: (context, i) {
        if (i == 0) return const PriceBanner();
        if (i == 1) return const FuelTypeFilterRow();
        if (i == 2) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주변 ${stations.length}곳',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SortFilterRow(),
            ],
          );
        }
        if (i == 3) {
          return TopStationCard(
            station: top,
            fuelType: fuelType,
            referencePrice: referencePrice,
          );
        }
        final station = rest[i - 4];
        return StationListTile(
          rank: i - 2,
          station: station,
          fuelType: fuelType,
          lowestPrice: lowest,
          onTap: () {},
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_gas_station_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('주변 주유소가 없어요', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '다른 연료 종류로 변경해보세요',
              style: AppTypography.body2.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          '데이터를 불러오지 못했어요\n$message',
          textAlign: TextAlign.center,
          style: AppTypography.body2,
        ),
      ),
    );
  }
}
