import 'package:flutter/material.dart';

import 'app_color_tokens.dart';
import 'app_radius.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppColorTokens.light, Brightness.light);
  static ThemeData dark() => _build(AppColorTokens.dark, Brightness.dark);

  static ThemeData _build(AppColorTokens tokens, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.primary,
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: isDark ? const Color(0xFF0E0F12) : Colors.white,
      secondary: tokens.accent,
      onSecondary: isDark ? const Color(0xFF0E0F12) : Colors.white,
      error: tokens.danger,
      onError: isDark ? const Color(0xFF0E0F12) : Colors.white,
      surface: tokens.bgSurface,
      onSurface: tokens.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.bgPrimary,
      fontFamily: 'Pretendard',
      extensions: [tokens],
      textTheme: TextTheme(
        displayLarge: AppTypography.priceHero.copyWith(color: tokens.textPrimary),
        displayMedium:
            AppTypography.priceLarge.copyWith(color: tokens.textPrimary),
        displaySmall:
            AppTypography.priceMedium.copyWith(color: tokens.textPrimary),
        headlineLarge: AppTypography.h1.copyWith(color: tokens.textPrimary),
        headlineMedium: AppTypography.h2.copyWith(color: tokens.textPrimary),
        titleLarge: AppTypography.h3.copyWith(color: tokens.textPrimary),
        bodyLarge: AppTypography.body1.copyWith(color: tokens.textPrimary),
        bodyMedium: AppTypography.body2.copyWith(color: tokens.textSecondary),
        labelSmall: AppTypography.caption.copyWith(color: tokens.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bgPrimary,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h3.copyWith(color: tokens.textPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: isDark ? const Color(0xFF0E0F12) : Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.textPrimary,
          backgroundColor: tokens.bgSurface,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: tokens.borderHair),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: tokens.borderHair),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderHair,
        thickness: 1,
        space: 0,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
