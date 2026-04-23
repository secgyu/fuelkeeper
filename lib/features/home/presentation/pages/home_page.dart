import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
        ),
        title: const Text('FuelKeeper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.sm,
            AppSpacing.base,
            AppSpacing.xxl,
          ),
          children: const [
            _PriceBanner(),
            SizedBox(height: AppSpacing.base),
            _StationPreviewCard(),
            SizedBox(height: AppSpacing.lg),
            _CtaRow(),
          ],
        ),
      ),
    );
  }
}

class _PriceBanner extends StatelessWidget {
  const _PriceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderHair),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('우리동네 평균', style: AppTypography.caption),
                SizedBox(height: 2),
                _PriceText('1,987', size: 22, weight: FontWeight.w700),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.borderHair),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('정부 최고가', style: AppTypography.caption),
                  SizedBox(height: 2),
                  _PriceText('1,934', size: 22, weight: FontWeight.w700),
                ],
              ),
            ),
          ),
          const _DeltaChip(value: -53),
        ],
      ),
    );
  }
}

class _StationPreviewCard extends StatelessWidget {
  const _StationPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderHair),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AppColors.accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: const Text(
                              '최저가',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.brandSk,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('SK엔크린', style: AppTypography.caption),
                          const Spacer(),
                          const Text('0.4km', style: AppTypography.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text('강남대로주유소', style: AppTypography.h2),
                      const SizedBox(height: AppSpacing.base),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          _PriceText(
                            '1,894',
                            size: 48,
                            weight: FontWeight.w800,
                            letterSpacing: -1.2,
                          ),
                          SizedBox(width: 6),
                          Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              '원/L',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.accent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '정부 최고가 대비',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '-89원',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  const _PriceText(
    this.amount, {
    required this.size,
    required this.weight,
    this.letterSpacing,
  });

  final String amount;
  final double size;
  final FontWeight weight;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Pretendard',
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: 1.0,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        children: [
          TextSpan(
            text: '₩',
            style: TextStyle(
              fontSize: size * 0.62,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
          const WidgetSpan(child: SizedBox(width: 4)),
          TextSpan(
            text: amount,
            style: TextStyle(fontSize: size),
          ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final isCheap = value <= 0;
    final color = isCheap ? AppColors.accent : AppColors.danger;
    final sign = isCheap ? '' : '+';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$sign$value',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow();

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
