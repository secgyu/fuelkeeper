import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/stats/application/stats_providers.dart';

const Map<FuelType, Color> _fuelColors = {
  FuelType.gasoline: Color(0xFF2962FF),
  FuelType.premiumGasoline: Color(0xFF7C3AED),
  FuelType.diesel: Color(0xFF00B383),
  FuelType.lpg: Color(0xFFF5A524),
};

class FuelShareDonut extends StatelessWidget {
  const FuelShareDonut({super.key, required this.shares});

  final List<FuelTypeShare> shares;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _DonutPainter(shares: shares),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: _Legend(shares: shares)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.shares});
  final List<FuelTypeShare> shares;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    const stroke = 14.0;

    final bgPaint = Paint()
      ..color = AppColors.bgMuted
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - stroke / 2, bgPaint);

    if (shares.isEmpty) return;

    var start = -math.pi / 2;
    const gap = 0.04;
    for (final s in shares) {
      final sweep = s.ratio * 2 * math.pi - gap;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = _fuelColors[s.type] ?? AppColors.textPrimary
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep + gap;
    }

    final topShare = shares.first;
    final percent = (topShare.ratio * 100).round();
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$percent',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const TextSpan(
            text: '%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.shares != shares;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.shares});
  final List<FuelTypeShare> shares;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in shares)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _fuelColors[s.type] ?? AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.type.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${(s.ratio * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₩${Formatters.thousands(s.totalCost)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
