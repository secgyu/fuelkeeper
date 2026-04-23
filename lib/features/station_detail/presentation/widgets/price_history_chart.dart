import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';

class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({super.key, required this.values, this.height = 96});

  final List<int> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            '가격 추이 데이터가 부족해요',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(values: values),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values});

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).clamp(1, 1 << 30).toDouble();

    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0;
    final pad = 8.0;
    final chartHeight = size.height - pad * 2;

    Offset point(int i) {
      final v = values[i];
      final normalized = (v - minV) / range;
      final y = pad + chartHeight * (1 - normalized);
      return Offset(i * stepX.toDouble(), y);
    }

    final linePath = Path();
    final fillPath = Path();
    for (var i = 0; i < values.length; i++) {
      final p = point(i);
      if (i == 0) {
        linePath.moveTo(p.dx, p.dy);
        fillPath.moveTo(p.dx, size.height);
        fillPath.lineTo(p.dx, p.dy);
      } else {
        final prev = point(i - 1);
        final mid = Offset((prev.dx + p.dx) / 2, (prev.dy + p.dy) / 2);
        linePath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
        linePath.lineTo(p.dx, p.dy);
        fillPath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
        fillPath.lineTo(p.dx, p.dy);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final lastPoint = point(values.length - 1);
    final dotPaint = Paint()..color = AppColors.primary;
    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 8, ringPaint);
    canvas.drawCircle(lastPoint, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.values != values;
}
