import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/utils/share_image.dart';
import 'package:fuelkeeper/core/widgets/empty_view.dart';
import 'package:fuelkeeper/core/widgets/error_view.dart';
import 'package:fuelkeeper/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/action_row.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/detail_skeleton.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/fuel_price_table.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/header_card.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/info_section.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/price_history_chart.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/share_card.dart';

class StationDetailPage extends ConsumerWidget {
  const StationDetailPage({super.key, required this.stationId});

  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStation = ref.watch(stationByIdProvider(stationId));
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final national = ref.watch(nationalAverageProvider);

    final loadedStation = asyncStation.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );
    final canShare =
        loadedStation != null && loadedStation.priceOf(fuelType) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('주유소 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '카드 이미지 공유',
            onPressed: canShare
                ? () {
                    final price = loadedStation.priceOf(fuelType)!;
                    final delta = national != null ? price - national : null;
                    ShareImage.capture(
                      context,
                      widget: StationShareCard(
                        station: loadedStation,
                        fuelType: fuelType,
                        price: price,
                        delta: delta,
                      ),
                      fileNamePrefix: 'fuelkeeper_${loadedStation.id}',
                      subject: '${loadedStation.name} ${fuelType.label} 가격',
                      text: '${loadedStation.name} · ${fuelType.label} '
                          '$price원/L',
                    );
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FavoriteButton(stationId: stationId),
          ),
        ],
      ),
      body: SafeArea(
        child: asyncStation.when(
          loading: () => const DetailSkeleton(),
          error: (e, _) => ErrorView(
            title: '주유소 정보를 불러오지 못했어요',
            message: '네트워크 상태를 확인하고 다시 시도해주세요',
            onRetry: () => ref.invalidate(stationByIdProvider(stationId)),
          ),
          data: (station) {
            if (station == null) {
              return const EmptyView(
                icon: Icons.local_gas_station_outlined,
                title: '주유소를 찾을 수 없어요',
                message: '삭제되었거나 위치가 변경되었을 수 있어요',
              );
            }
            return _DetailBody(
              station: station,
              fuelType: fuelType,
              national: national,
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.station,
    required this.fuelType,
    required this.national,
  });

  final Station station;
  final FuelType fuelType;
  final int? national;

  @override
  Widget build(BuildContext context) {
    final price = station.priceOf(fuelType)!;
    final delta = national != null ? price - national! : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xxl,
      ),
      children: [
        HeaderCard(
          station: station,
          price: price,
          delta: delta,
          fuelType: fuelType,
        ),
        const SizedBox(height: AppSpacing.base),
        ActionRow(station: station),
        const SizedBox(height: AppSpacing.lg),
        FuelPriceTable(station: station, currentFuel: fuelType),
        const SizedBox(height: AppSpacing.lg),
        PriceHistoryChart(stationId: station.id, fuelType: fuelType),
        const SizedBox(height: AppSpacing.lg),
        InfoSection(station: station),
      ],
    );
  }
}
