import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/core/location/presentation/location_status_banner.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/fuel_type_filter_row.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_banner.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/sort_filter_row.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/station_list_tile.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/top_station_card.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStations = ref.watch(filteredStationsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final national = ref.watch(nationalAverageProvider);
    final asyncAddress = ref.watch(currentAddressProvider);

    Future<void> refreshLocation() async {
      ref.read(stationRepositoryProvider).clearCache();
      ref.invalidate(currentLocationProvider);
      ref.invalidate(currentAddressProvider);
      ref.invalidate(stationsProvider);
      ref.invalidate(nationalAveragesProvider);
      await ref.read(stationsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.base,
        title: InkWell(
          onTap: refreshLocation,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  asyncAddress.maybeWhen(data: (a) => a, orElse: () => '내 위치'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshLocation,
          child: asyncStations.when(
            loading: () => const _LoadingState(),
            error: (e, st) {
              debugPrint('[home] stations load failed: $e\n$st');
              return _ErrorState(onRetry: refreshLocation);
            },
            data: (stations) {
              if (stations.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.sm,
                    AppSpacing.base,
                    AppSpacing.xxl,
                  ),
                  children: const [
                    LocationStatusBanner(),
                    PriceBanner(),
                    SizedBox(height: AppSpacing.base),
                    FuelTypeFilterRow(),
                    SizedBox(height: AppSpacing.xxl),
                    _EmptyState(),
                  ],
                );
              }
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
      itemCount: rest.length + 5,
      separatorBuilder: (context, i) {
        if (i == 0 || i == 1 || i == 2 || i == 3) {
          return const SizedBox(height: AppSpacing.base);
        }
        return const SizedBox(height: AppSpacing.sm);
      },
      itemBuilder: (context, i) {
        if (i == 0) return const LocationStatusBanner();
        if (i == 1) return const PriceBanner();
        if (i == 2) return const FuelTypeFilterRow();
        if (i == 3) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주변 ${stations.length}곳',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SortFilterRow(),
            ],
          );
        }
        if (i == 4) {
          return TopStationCard(
            station: top,
            fuelType: fuelType,
            referencePrice: referencePrice,
            onTap: () => context.push(AppRoutes.stationDetail(top.id)),
          );
        }
        final station = rest[i - 5];
        return StationListTile(
          rank: i - 3,
          station: station,
          fuelType: fuelType,
          lowestPrice: lowest,
          onTap: () => context.push(AppRoutes.stationDetail(station.id)),
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
            Icon(
              Icons.local_gas_station_outlined,
              size: 48,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('주변 주유소가 없어요', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '다른 연료 종류로 변경해보세요',
              style: AppTypography.body2.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('주유소 정보를 불러오지 못했어요', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '인터넷 연결을 확인하고\n잠시 후 다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
