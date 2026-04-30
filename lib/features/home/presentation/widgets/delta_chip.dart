import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';

class DeltaChip extends StatelessWidget {
  const DeltaChip({super.key, required this.value, this.compact = false});

  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isCheap = value <= 0;
    final color = isCheap ? context.colors.accent : context.colors.danger;
    final sign = isCheap ? '' : '+';
    // 색맹 사용자도 우열을 인지할 수 있도록 색 외에 화살표 아이콘을 함께 표시한다.
    final icon = isCheap
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final iconSize = (compact ? 11 : 13).toDouble();
    final semanticLabel = isCheap
        ? (value == 0 ? '평균가와 동일' : '평균보다 ${-value}원 저렴')
        : '평균보다 $value원 비쌈';

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: color),
            const SizedBox(width: 2),
            Text(
              '$sign$value',
              style: TextStyle(
                color: color,
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
