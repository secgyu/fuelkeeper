import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/widgets/empty_view.dart';
import 'package:fuelkeeper/core/widgets/error_view.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/stats/application/stats_providers.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/efficiency_trend_chart.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/frequent_station_tile.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/fuel_share_donut.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/monthly_cost_chart.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/stats_overview_card.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/stats_section_card.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/stats_skeleton.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(fuelLogsProvider);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: context.colors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('통계', style: AppTypography.h2),
        centerTitle: false,
      ),
      body: logsAsync.when(
        loading: () => const StatsSkeleton(),
        error: (e, _) => ErrorView(
          title: '통계를 불러오지 못했어요',
          message: '잠시 후 다시 시도해주세요',
          onRetry: () => ref.invalidate(fuelLogsProvider),
        ),
        data: (logs) {
          if (logs.isEmpty) return const _EmptyState();
          return const _StatsBody();
        },
      ),
    );
  }
}

class _StatsBody extends ConsumerWidget {
  const _StatsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(statsOverviewProvider);
    final buckets = ref.watch(monthlyBucketsProvider);
    final shares = ref.watch(fuelTypeShareProvider);
    final stations = ref.watch(frequentStationsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        StatsOverviewCard(overview: overview),
        const SizedBox(height: AppSpacing.lg),
        StatsSectionCard(
          title: '월별 주유 비용',
          subtitle: '최근 6개월',
          child: MonthlyCostChart(buckets: buckets),
        ),
        const SizedBox(height: AppSpacing.lg),
        StatsSectionCard(
          title: '연비 추이',
          subtitle: '월 평균 km/L',
          child: EfficiencyTrendChart(buckets: buckets),
        ),
        if (shares.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StatsSectionCard(
            title: '연료별 비용 분포',
            child: FuelShareDonut(shares: shares),
          ),
        ],
        if (stations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StatsSectionCard(
            title: '자주 가는 주유소',
            subtitle: 'TOP ${stations.length}',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      icon: Icons.bar_chart_rounded,
      title: '아직 통계 데이터가 없어요',
      message: '주유 로그 탭에서 기록을 남기면\n자동으로 통계가 표시됩니다',
    );
  }
}
