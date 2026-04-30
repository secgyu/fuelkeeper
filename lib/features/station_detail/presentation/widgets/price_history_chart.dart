import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/stats/application/price_snapshot_providers.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot.dart';

/// 주유소 상세에 표시되는 가격 시계열 차트.
///
/// 데이터 원천은 사용자가 앱을 사용할 때마다 누적되는 일별 스냅샷이다.
/// 데이터가 1개 이하이면 안내 문구만 노출한다.
class PriceHistoryChart extends ConsumerWidget {
  const PriceHistoryChart({
    super.key,
    required this.stationId,
    required this.fuelType,
  });

  final String stationId;
  final FuelType fuelType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(
      priceHistoryProvider((stationId: stationId, fuelType: fuelType)),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderHair),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 18,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${fuelType.label} 가격 추이',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          asyncHistory.when(
            loading: () => SizedBox(
              height: 120,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
            ),
            error: (_, _) => _NotEnoughData(
              message: '가격 추이를 불러오지 못했어요',
              colors: context.colors,
            ),
            data: (history) {
              if (history.length < 2) {
                return _NotEnoughData(
                  message: '아직 비교할 데이터가 충분하지 않아요\n앱을 자주 열수록 정확한 추이가 쌓여요',
                  colors: context.colors,
                );
              }
              return _ChartBody(history: history);
            },
          ),
        ],
      ),
    );
  }
}

class _NotEnoughData extends StatelessWidget {
  const _NotEnoughData({required this.message, required this.colors});
  final String message;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: colors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  const _ChartBody({required this.history});
  final List<PriceSnapshot> history;

  @override
  Widget build(BuildContext context) {
    final prices = history.map((s) => s.price).toList(growable: false);
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final last = history.last;
    final first = history.first;
    final diff = last.price - first.price;
    final diffPercent = first.price > 0
        ? (diff / first.price * 100).toStringAsFixed(1)
        : '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${last.price}원',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    diff >= 0
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: diff >= 0
                        ? context.colors.danger
                        : context.colors.accent,
                  ),
                  Text(
                    '${diff.abs()}원 ($diffPercent%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: diff >= 0
                          ? context.colors.danger
                          : context.colors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '최근 ${history.length}일 · 최저 $minP / 최고 $maxP원',
          style: TextStyle(
            fontSize: 11,
            color: context.colors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: const Size.fromHeight(120),
            painter: _LinePainter(
              history: history,
              minPrice: minP,
              maxPrice: maxP,
              lineColor: context.colors.primary,
              fillColor: context.colors.primary.withValues(alpha: 0.10),
              gridColor: context.colors.borderHair,
            ),
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.history,
    required this.minPrice,
    required this.maxPrice,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<PriceSnapshot> history;
  final int minPrice;
  final int maxPrice;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = h * i / 3;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    if (history.length < 2) return;

    final n = history.length;
    final range = (maxPrice - minPrice).clamp(1, 1 << 30);

    Offset pointAt(int i) {
      final x = w * i / (n - 1);
      final ratio = (history[i].price - minPrice) / range;
      final y = h - (h * 0.85) * ratio - h * 0.075;
      return Offset(x, y);
    }

    final path = Path()..moveTo(0, pointAt(0).dy);
    for (var i = 1; i < n; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round,
    );

    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(pointAt(n - 1), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.history != history ||
      old.lineColor != lineColor ||
      old.fillColor != fillColor;
}
