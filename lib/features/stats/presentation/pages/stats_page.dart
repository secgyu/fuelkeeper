import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/widgets/error_view.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/stats/application/stats_providers.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/efficiency_trend_chart.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/frequent_station_tile.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/fuel_share_donut.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/low_top10_card.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/monthly_cost_chart.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/sido_averages_card.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/sido_selector.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/stats_overview_card.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/stats_section_card.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(fuelLogsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: context.colors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('통계', style: AppTypography.h2),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          // 1) 전국 가격 비교 — 로그 유무와 무관하게 항상 표시.
          StatsSectionCard(
            title: '시·도별 평균 가격',
            subtitle: _fuelLabel(fuelType),
            collapsible: true,
            sectionId: 'sido_averages',
            child: const SidoAveragesCard(),
          ),
          const SizedBox(height: AppSpacing.lg),
          StatsSectionCard(
            title: '저가 주유소 TOP 10',
            subtitle: '${_fuelLabel(fuelType)} · 시·도 변경 가능',
            trailing: const SidoSelector(),
            collapsible: true,
            sectionId: 'low_top10',
            child: const LowTop10Card(),
          ),

          // 2) 내 주유 통계 — 로그 있을 때만 노출.
          const SizedBox(height: AppSpacing.lg),
          logsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => ErrorView(
              title: '통계를 불러오지 못했어요',
              message: '잠시 후 다시 시도해주세요',
              onRetry: () => ref.invalidate(fuelLogsProvider),
            ),
            data: (logs) {
              if (logs.isEmpty) return const _LogsEmptyHint();
              return const _MyStatsBody();
            },
          ),
        ],
      ),
    );
  }

  String _fuelLabel(FuelType type) {
    switch (type) {
      case FuelType.gasoline:
        return '휘발유';
      case FuelType.premiumGasoline:
        return '고급휘발유';
      case FuelType.diesel:
        return '경유';
      case FuelType.lpg:
        return 'LPG';
    }
  }
}

class _MyStatsBody extends ConsumerWidget {
  const _MyStatsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(statsOverviewProvider);
    final buckets = ref.watch(monthlyBucketsProvider);
    final shares = ref.watch(fuelTypeShareProvider);
    final stations = ref.watch(frequentStationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsOverviewCard(overview: overview),
        const SizedBox(height: AppSpacing.lg),
        StatsSectionCard(
          title: '월별 주유 비용',
          subtitle: '최근 6개월',
          collapsible: true,
          sectionId: 'monthly_cost',
          child: MonthlyCostChart(buckets: buckets),
        ),
        const SizedBox(height: AppSpacing.lg),
        StatsSectionCard(
          title: '연비 추이',
          subtitle: '월 평균 km/L',
          collapsible: true,
          sectionId: 'efficiency_trend',
          child: EfficiencyTrendChart(buckets: buckets),
        ),
        if (shares.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StatsSectionCard(
            title: '연료별 비용 분포',
            collapsible: true,
            sectionId: 'fuel_share',
            child: FuelShareDonut(shares: shares),
          ),
        ],
        if (stations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StatsSectionCard(
            title: '자주 가는 주유소',
            subtitle: 'TOP ${stations.length}',
            collapsible: true,
            sectionId: 'frequent_stations',
            child: Column(
              children: [
                for (final s in stations) FrequentStationTile(station: s),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LogsEmptyHint extends StatelessWidget {
  const _LogsEmptyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderHair),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            size: 20,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '주유 로그를 남기면 월별 비용·연비 추이 등 내 통계가 자동으로 표시돼요.',
              style: TextStyle(
                fontSize: 12.5,
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
