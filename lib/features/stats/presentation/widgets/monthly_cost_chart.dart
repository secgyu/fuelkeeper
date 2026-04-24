import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/features/stats/application/stats_providers.dart';

class MonthlyCostChart extends StatelessWidget {
  const MonthlyCostChart({super.key, required this.buckets});

  final List<MonthlyBucket> buckets;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        size: Size.infinite,
        painter: _MonthlyCostPainter(buckets: buckets),
      ),
    );
  }
}

class _MonthlyCostPainter extends CustomPainter {
  _MonthlyCostPainter({required this.buckets});

  final List<MonthlyBucket> buckets;

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty) return;

    const labelHeight = 20.0;
    const valueHeight = 18.0;
    final chartHeight = size.height - labelHeight - valueHeight;
    final chartTop = valueHeight;

    final maxCost = buckets
        .map((b) => b.totalCost)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final safeMax = maxCost == 0 ? 1 : maxCost;

    final slot = size.width / buckets.length;
    final barWidth = (slot * 0.5).clamp(8.0, 36.0);

    final gridPaint = Paint()
      ..color = AppColors.borderHair
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, chartTop + chartHeight),
      Offset(size.width, chartTop + chartHeight),
      gridPaint,
    );

    for (var i = 0; i < buckets.length; i++) {
      final b = buckets[i];
      final cx = slot * i + slot / 2;
      final ratio = b.totalCost / safeMax;
      final barHeight = chartHeight * ratio;
      final isLatest = i == buckets.length - 1;

      final rect = Rect.fromLTWH(
        cx - barWidth / 2,
        chartTop + chartHeight - barHeight,
        barWidth,
        barHeight,
      );
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final barPaint = Paint()
        ..color = isLatest
            ? AppColors.textPrimary
            : AppColors.textPrimary.withValues(alpha: 0.18);
      canvas.drawRRect(rrect, barPaint);

      if (b.totalCost > 0) {
        final valueText = TextPainter(
          text: TextSpan(
            text: _formatCompact(b.totalCost),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isLatest ? AppColors.textPrimary : AppColors.textTertiary,
              letterSpacing: -0.2,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valueText.paint(
          canvas,
          Offset(
            cx - valueText.width / 2,
            chartTop + chartHeight - barHeight - valueText.height - 4,
          ),
        );
      }

      final labelText = TextPainter(
        text: TextSpan(
          text: b.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isLatest ? AppColors.textPrimary : AppColors.textTertiary,
            letterSpacing: -0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelText.paint(
        canvas,
        Offset(cx - labelText.width / 2, chartTop + chartHeight + 6),
      );
    }
  }

  String _formatCompact(int v) {
    if (v >= 10000) {
      final man = v / 10000;
      return '${man.toStringAsFixed(man >= 10 ? 0 : 1)}만';
    }
    return v.toString();
  }

  @override
  bool shouldRepaint(covariant _MonthlyCostPainter old) =>
      old.buckets != buckets;
}
