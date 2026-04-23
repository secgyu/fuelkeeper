import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/domain/station_amenity.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_text.dart';
import 'package:fuelkeeper/features/station_detail/presentation/widgets/price_history_chart.dart';

class StationDetailPage extends ConsumerWidget {
  const StationDetailPage({super.key, required this.stationId});

  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStation = ref.watch(stationByIdProvider(stationId));
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final national = ref.watch(nationalAverageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주유소 정보'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FavoriteButton(stationId: stationId),
          ),
        ],
      ),
      body: SafeArea(
        child: asyncStation.when(
          loading: () => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
          error: (e, _) => Center(child: Text('주유소 정보를 불러오지 못했어요\n$e')),
          data: (station) {
            if (station == null) {
              return const Center(child: Text('주유소를 찾을 수 없어요'));
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
        _HeaderCard(
          station: station,
          price: price,
          delta: delta,
          fuelType: fuelType,
        ),
        const SizedBox(height: AppSpacing.base),
        const _ActionRow(),
        const SizedBox(height: AppSpacing.lg),
        _FuelPriceTable(station: station, currentFuel: fuelType),
        const SizedBox(height: AppSpacing.lg),
        _PriceHistorySection(station: station, fuelType: fuelType),
        const SizedBox(height: AppSpacing.lg),
        _InfoSection(station: station),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.station,
    required this.price,
    required this.delta,
    required this.fuelType,
  });

  final Station station;
  final int price;
  final int? delta;
  final FuelType fuelType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderHair),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: station.brand.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(station.brand.label, style: AppTypography.caption),
              if (station.isSelfService) ...[
                const SizedBox(width: 8),
                _Tag(label: '셀프', color: AppColors.primary),
              ],
              const Spacer(),
              Text(
                '${station.distanceKm.toStringAsFixed(1)}km',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(station.name, style: AppTypography.h1),
          const SizedBox(height: 4),
          Text(
            station.address,
            style: AppTypography.body2.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PriceText(
                amount: price,
                size: 44,
                weight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  '원/L',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgMuted,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  fuelType.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (delta != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  delta! < 0
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  size: 14,
                  color: delta! < 0 ? AppColors.accent : AppColors.danger,
                ),
                const SizedBox(width: 6),
                Text(
                  '전국 평균 대비',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  delta! < 0 ? '$delta원' : '+$delta원',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: delta! < 0 ? AppColors.accent : AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, size: 18),
            label: const Text('전화'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.directions_rounded, size: 20),
            label: const Text('길찾기'),
          ),
        ),
      ],
    );
  }
}

class _FuelPriceTable extends StatelessWidget {
  const _FuelPriceTable({required this.station, required this.currentFuel});

  final Station station;
  final FuelType currentFuel;

  @override
  Widget build(BuildContext context) {
    final entries = FuelType.values
        .where((t) => station.priceOf(t) != null)
        .toList();
    return _Section(
      title: '연료별 가격',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderHair),
        ),
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              _FuelPriceRow(
                fuel: entries[i],
                price: station.priceOf(entries[i])!,
                isCurrent: entries[i] == currentFuel,
              ),
              if (i != entries.length - 1)
                const Divider(
                  height: 1,
                  color: AppColors.borderHair,
                  indent: AppSpacing.base,
                  endIndent: AppSpacing.base,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FuelPriceRow extends StatelessWidget {
  const _FuelPriceRow({
    required this.fuel,
    required this.price,
    required this.isCurrent,
  });

  final FuelType fuel;
  final int price;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            fuel.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            _Tag(label: '선택', color: AppColors.primary),
          ],
          const Spacer(),
          PriceText(
            amount: price,
            size: 16,
            weight: FontWeight.w700,
            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _PriceHistorySection extends StatelessWidget {
  const _PriceHistorySection({required this.station, required this.fuelType});

  final Station station;
  final FuelType fuelType;

  @override
  Widget build(BuildContext context) {
    final history = station.historyOf(fuelType);
    final hasData = history.length >= 2;
    final minV = hasData ? history.reduce((a, b) => a < b ? a : b) : 0;
    final maxV = hasData ? history.reduce((a, b) => a > b ? a : b) : 0;
    final last = hasData ? history.last : 0;

    return _Section(
      title: '7일 가격 추이',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderHair),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PriceHistoryChart(values: history),
            if (hasData) ...[
              const SizedBox(height: AppSpacing.base),
              Row(
                children: [
                  _HistoryStat(
                    label: '최저',
                    value: minV,
                    color: AppColors.accent,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: AppColors.borderHair,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  _HistoryStat(
                    label: '현재',
                    value: last,
                    color: AppColors.textPrimary,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: AppColors.borderHair,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  _HistoryStat(
                    label: '최고',
                    value: maxV,
                    color: AppColors.danger,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          PriceText(
            amount: value,
            size: 14,
            weight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    return _Section(
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
