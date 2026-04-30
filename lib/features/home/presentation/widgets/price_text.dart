import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';

class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.amount,
    required this.size,
    required this.weight,
    this.letterSpacing,
    this.color,
    this.symbolColor,
  });

  final int amount;
  final double size;
  final FontWeight weight;
  final double? letterSpacing;
  final Color? color;
  final Color? symbolColor;

  @override
  Widget build(BuildContext context) {
    final formatted = Formatters.thousands(amount);
    return Semantics(
      label: '$formatted원',
      excludeSemantics: true,
      child: RichText(
        text: TextSpan(
        style: TextStyle(
          color: color ?? context.colors.textPrimary,
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
              color: symbolColor ?? context.colors.textSecondary,
              letterSpacing: 0,
            ),
          ),
          const WidgetSpan(child: SizedBox(width: 4)),
          TextSpan(
            text: formatted,
            style: TextStyle(fontSize: size),
          ),
        ],
        ),
      ),
    );
  }
}
