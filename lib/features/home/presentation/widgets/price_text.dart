import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';

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
    final formatted = _format(amount);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
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
              color: symbolColor ?? AppColors.textSecondary,
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
    );
  }

  static String _format(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remain = s.length - i - 1;
      if (remain > 0 && remain % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }
}
