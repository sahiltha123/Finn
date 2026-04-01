import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_color_scheme.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _buildTheme(AppColorScheme.light);

  static ThemeData dark() => _buildTheme(AppColorScheme.dark);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final textTheme = AppTextStyles.textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary.withValues(alpha: 0.12),
        labelStyle: textTheme.bodyMedium!,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.brightness == Brightness.light
            ? AppColors.cardLight
            : AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.brightness == Brightness.light
            ? Colors.white
            : AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.brightness == Brightness.light
            ? AppColors.cardLight
            : AppColors.cardDark,
        modalBackgroundColor: scheme.brightness == Brightness.light
            ? AppColors.cardLight
            : AppColors.cardDark,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: scheme.surface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.brightness == Brightness.light
            ? Colors.white
            : AppColors.cardDark,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
