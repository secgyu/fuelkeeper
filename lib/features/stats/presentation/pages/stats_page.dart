import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/stats/application/stats_providers.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/efficiency_trend_chart.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/fuel_share_donut.dart';
import 'package:fuelkeeper/features/stats/presentation/widgets/monthly_cost_chart.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(fuelLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('통계', style: AppTypography.h2),
        centerTitle: false,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
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
        _OverviewCard(overview: overview),
        const SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: '월별 주유 비용',
          subtitle: '최근 6개월',
          child: MonthlyCostChart(buckets: buckets),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: '연비 추이',
          subtitle: '월 평균 km/L',
          child: EfficiencyTrendChart(buckets: buckets),
        ),
        if (shares.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: '연료별 비용 분포',
            child: FuelShareDonut(shares: shares),
          ),
        ],
        if (stations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: '자주 가는 주유소',
            subtitle: 'TOP ${stations.length}',
            child: Column(
              children: [
                for (final s in stations) _FrequentStationTile(station: s),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.overview});
  final StatsOverview overview;

  String _fmt(num v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remain = s.length - i - 1;
      if (remain > 0 && remain % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '누적 주유 통계',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9CA3AF),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            '₩ ${_fmt(overview.totalCost)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '기록 수',
                  value: '${overview.logCount}회',
                ),
              ),
              _divider(),
              Expanded(
                child: _Metric(
                  label: '총 주유량',
                  value: '${overview.totalLiters.toStringAsFixed(1)}L',
                ),
              ),
              _divider(),
              Expanded(
                child: _Metric(
                  label: '평균 연비',
                  value: overview.avgEfficiency == null
                      ? '—'
                      : '${overview.avgEfficiency!.toStringAsFixed(1)}km/L',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.12),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          child,
        ],
      ),
    );
  }
}

class _FrequentStationTile extends StatelessWidget {
  const _FrequentStationTile({required this.station});
  final FrequentStation station;

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remain = s.length - i - 1;
      if (remain > 0 && remain % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final brand = StationBrand.values[station.brandIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: brand.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${station.visits}회 · ₩${_fmt(station.totalCost)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderHair),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.textTertiary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              '아직 통계 데이터가 없어요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '주유 로그 탭에서 기록을 남기면\n자동으로 통계가 표시됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
