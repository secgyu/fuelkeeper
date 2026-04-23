import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';

class DeltaChip extends StatelessWidget {
  const DeltaChip({super.key, required this.value, this.compact = false});

  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isCheap = value <= 0;
    final color = isCheap ? AppColors.accent : AppColors.danger;
    final sign = isCheap ? '' : '+';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$sign$value',
        style: TextStyle(
          color: color,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
