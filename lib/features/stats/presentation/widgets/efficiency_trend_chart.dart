import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/features/stats/application/stats_providers.dart';

class EfficiencyTrendChart extends StatelessWidget {
  const EfficiencyTrendChart({super.key, required this.buckets});

  final List<MonthlyBucket> buckets;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        size: Size.infinite,
        painter: _EfficiencyPainter(
          buckets: buckets,
          tokens: context.colors,
        ),
      ),
    );
  }
}

class _EfficiencyPainter extends CustomPainter {
  _EfficiencyPainter({required this.buckets, required this.tokens});

  final List<MonthlyBucket> buckets;
  final AppColorTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty) return;

    const labelHeight = 22.0;
    const valueHeight = 18.0;
    const padX = 18.0;
    final chartHeight = size.height - labelHeight - valueHeight;
    const chartTop = valueHeight;

    final values = buckets.map((b) => b.efficiency).toList();
    final nums = values.whereType<double>().toList();
    if (nums.length < 2) {
      _drawEmpty(canvas, size);
      return;
    }

    final maxV = nums.reduce((a, b) => a > b ? a : b);
    final minV = nums.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 0.01 ? 1.0 : maxV - minV;

    final slotWidth = (size.width - padX * 2) / (buckets.length - 1).clamp(1, 99);

    final gridPaint = Paint()
      ..color = tokens.borderHair
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, chartTop + chartHeight),
      Offset(size.width, chartTop + chartHeight),
      gridPaint,
    );

    final points = <Offset?>[];
    for (var i = 0; i < buckets.length; i++) {
      final v = buckets[i].efficiency;
      if (v == null) {
        points.add(null);
        continue;
      }
      final x = padX + slotWidth * i;
      final y = chartTop + chartHeight - ((v - minV) / range) * chartHeight * 0.85 - 8;
      points.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = tokens.accent
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          tokens.accent.withValues(alpha: 0.22),
          tokens.accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, chartTop, size.width, chartHeight));

    final path = Path();
    final fillPath = Path();
    Offset? lastValid;
    bool started = false;
    for (final p in points) {
      if (p == null) continue;
      if (!started) {
        path.moveTo(p.dx, p.dy);
        fillPath.moveTo(p.dx, chartTop + chartHeight);
        fillPath.lineTo(p.dx, p.dy);
        started = true;
      } else {
        path.lineTo(p.dx, p.dy);
        fillPath.lineTo(p.dx, p.dy);
      }
      lastValid = p;
    }
    if (lastValid != null) {
      fillPath
        ..lineTo(lastValid.dx, chartTop + chartHeight)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);
    }

    final dotFill = Paint()..color = tokens.bgSurface;
    final dotStroke = Paint()
      ..color = tokens.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (var i = 0; i < buckets.length; i++) {
      final p = points[i];
      final v = buckets[i].efficiency;
      if (p == null || v == null) continue;
      canvas.drawCircle(p, 4.5, dotFill);
      canvas.drawCircle(p, 4.5, dotStroke);

      final isLatest = i == buckets.length - 1;
      final valueText = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isLatest ? tokens.textPrimary : tokens.textTertiary,
            letterSpacing: -0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valueText.paint(
        canvas,
        Offset(p.dx - valueText.width / 2, p.dy - valueText.height - 8),
      );
    }

    for (var i = 0; i < buckets.length; i++) {
      final isLatest = i == buckets.length - 1;
      final cx = padX + slotWidth * i;
      final labelText = TextPainter(
        text: TextSpan(
          text: buckets[i].label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isLatest ? tokens.textPrimary : tokens.textTertiary,
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

  void _drawEmpty(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: '추세를 그리려면 서로 다른 달에\n주유 기록이 2회 이상 필요해요',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tokens.textTertiary,
          height: 1.5,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _EfficiencyPainter old) =>
      old.buckets != buckets;
}
