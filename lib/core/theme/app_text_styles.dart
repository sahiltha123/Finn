import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextTheme textTheme(ColorScheme colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.onSurface.withValues(alpha: 0.82),
      ),
      bodySmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.onSurface.withValues(alpha: 0.7),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  static TextStyle amountStyle(TextStyle base) {
    return base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  }
}
