import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/widgets/skeleton.dart';

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xxl,
      ),
      children: [
        _SkeletonCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Skeleton(width: 80, height: 12),
              SizedBox(height: AppSpacing.sm),
              Skeleton(width: 200, height: 22),
              SizedBox(height: 6),
              Skeleton(width: 240, height: 12),
              SizedBox(height: AppSpacing.lg),
              Skeleton(width: 160, height: 36),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Row(
          children: const [
            Expanded(child: Skeleton(height: 44, radius: 10)),
            SizedBox(width: AppSpacing.md),
            Expanded(flex: 2, child: Skeleton(height: 44, radius: 10)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SkeletonCard(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            children: List.generate(
              3,
              (i) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Skeleton(width: 60, height: 14),
                    Spacer(),
                    Skeleton(width: 80, height: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SkeletonCard(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Skeleton(width: 100, height: 12),
              SizedBox(height: AppSpacing.base),
              Skeleton(height: 80, radius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.padding, required this.child});

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderHair),
      ),
      child: child,
    );
  }
}
