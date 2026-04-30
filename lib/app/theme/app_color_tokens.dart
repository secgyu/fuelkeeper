import 'package:flutter/material.dart';

@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.bgPrimary,
    required this.bgSurface,
    required this.bgMuted,
    required this.borderHair,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brandPrimary,
    required this.primary,
    required this.accent,
    required this.danger,
    required this.warning,
    required this.info,
  });

  final Color bgPrimary;
  final Color bgSurface;
  final Color bgMuted;

  final Color borderHair;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color brandPrimary;
  final Color primary;
  final Color accent;
  final Color danger;
  final Color warning;
  final Color info;

  static const AppColorTokens light = AppColorTokens(
    bgPrimary: Color(0xFFF7F7F5),
    bgSurface: Color(0xFFFFFFFF),
    bgMuted: Color(0xFFEFEEE9),
    borderHair: Color(0xFFE8E7E2),
    textPrimary: Color(0xFF0E0F12),
    textSecondary: Color(0xFF5C6068),
    textTertiary: Color(0xFF9AA0A6),
    brandPrimary: Color(0xFF1A3FAA),
    primary: Color(0xFF2962FF),
    accent: Color(0xFF00B383),
    danger: Color(0xFFFF4D4F),
    warning: Color(0xFFF5A524),
    info: Color(0xFF2962FF),
  );

  static const AppColorTokens dark = AppColorTokens(
    bgPrimary: Color(0xFF0F1014),
    bgSurface: Color(0xFF1A1C20),
    bgMuted: Color(0xFF24262C),
    borderHair: Color(0xFF2E3138),
    textPrimary: Color(0xFFF1F2F4),
    textSecondary: Color(0xFFB4B8C0),
    textTertiary: Color(0xFF7E848D),
    brandPrimary: Color(0xFF6F89F3),
    primary: Color(0xFF6F89F3),
    accent: Color(0xFF3DD9A4),
    danger: Color(0xFFFF7A7C),
    warning: Color(0xFFFFC062),
    info: Color(0xFF6F89F3),
  );

  @override
  AppColorTokens copyWith({
    Color? bgPrimary,
    Color? bgSurface,
    Color? bgMuted,
    Color? borderHair,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? brandPrimary,
    Color? primary,
    Color? accent,
    Color? danger,
    Color? warning,
    Color? info,
  }) {
    return AppColorTokens(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSurface: bgSurface ?? this.bgSurface,
      bgMuted: bgMuted ?? this.bgMuted,
      borderHair: borderHair ?? this.borderHair,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgMuted: Color.lerp(bgMuted, other.bgMuted, t)!,
      borderHair: Color.lerp(borderHair, other.borderHair, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppColorTokensX on BuildContext {
  AppColorTokens get colors =>
      Theme.of(this).extension<AppColorTokens>() ?? AppColorTokens.light;
}
