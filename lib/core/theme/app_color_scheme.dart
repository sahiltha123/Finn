import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppColorScheme {
  const AppColorScheme._();

  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.finnBlue,
    onPrimary: Colors.white,
    secondary: AppColors.finnGreen,
    onSecondary: Colors.white,
    error: AppColors.finnRed,
    onError: Colors.white,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.inkLight,
    tertiary: AppColors.finnAmber,
    onTertiary: AppColors.inkLight,
    outline: AppColors.dividerLight,
    shadow: Color(0x1A101828),
    inverseSurface: AppColors.inkLight,
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFF86B8FF),
    surfaceTint: AppColors.finnBlue,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF86B8FF),
    onPrimary: Color(0xFF0B2545),
    secondary: Color(0xFF6FE3A0),
    onSecondary: Color(0xFF0F3320),
    error: Color(0xFFFF9B90),
    onError: Color(0xFF3C0902),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.inkDark,
    tertiary: Color(0xFFFFD86B),
    onTertiary: Color(0xFF473000),
    outline: AppColors.dividerDark,
    shadow: Color(0x33000000),
    inverseSurface: AppColors.inkDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary: AppColors.finnBlue,
    surfaceTint: Color(0xFF86B8FF),
  );
}
