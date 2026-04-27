import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/stats/application/stats_providers.dart';

class StatsOverviewCard extends StatelessWidget {
  const StatsOverviewCard({super.key, required this.overview});

  final StatsOverview overview;

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
            Formatters.currency(overview.totalCost),
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
              const _MetricDivider(),
              Expanded(
                child: _Metric(
                  label: '총 주유량',
                  value: Formatters.liters(overview.totalLiters),
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _Metric(
                  label: '평균 연비',
                  value: Formatters.efficiency(overview.avgEfficiency),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}
