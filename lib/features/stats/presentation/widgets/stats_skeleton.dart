import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/widgets/skeleton.dart';

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: const [
        _OverviewSkeleton(),
        SizedBox(height: AppSpacing.lg),
        _ChartCardSkeleton(chartHeight: 140),
        SizedBox(height: AppSpacing.lg),
        _ChartCardSkeleton(chartHeight: 140),
      ],
    );
  }
}

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _whiteBlock(width: 100, height: 12, alpha: 0.12),
          const SizedBox(height: AppSpacing.base),
          _whiteBlock(width: 180, height: 28, alpha: 0.16),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                  child: Column(
                    children: [
                      _whiteBlock(width: 40, height: 10, alpha: 0.12),
                      const SizedBox(height: 8),
                      _whiteBlock(width: 60, height: 14, alpha: 0.16),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _whiteBlock({
    required double width,
    required double height,
    required double alpha,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

class _ChartCardSkeleton extends StatelessWidget {
  const _ChartCardSkeleton({required this.chartHeight});

  final double chartHeight;

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
            children: const [
              Skeleton(width: 100, height: 14),
              Spacer(),
              Skeleton(width: 60, height: 10),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Skeleton(height: chartHeight, radius: 8),
        ],
      ),
    );
  }
}
