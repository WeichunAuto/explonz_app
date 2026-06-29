import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onColour,
          primaryContainer: AppColors.highlight,
          onPrimaryContainer: AppColors.darkSurf,
          secondary: AppColors.depth,
          onSecondary: AppColors.onColour,
          secondaryContainer: AppColors.markLight,
          onSecondaryContainer: AppColors.onColour,
          tertiary: AppColors.accent,
          onTertiary: AppColors.darkSurf,
          tertiaryContainer: AppColors.packLight,
          onTertiaryContainer: AppColors.onColour,
          error: AppColors.error,
          onError: AppColors.onColour,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.darkSurf,
          surfaceContainerHighest: Color(0xFFF0ECE8),
          onSurfaceVariant: AppColors.markLight,
          outline: AppColors.packLight,
          outlineVariant: Color(0xFFD6C8C0),
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: AppColors.darkSurf,
          onInverseSurface: AppColors.onColour,
          inversePrimary: AppColors.highlight,
        ),
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.darkSurf,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: AppRadius.smAll),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.highlight,
          onPrimary: AppColors.darkSurf,
          primaryContainer: AppColors.primary,
          onPrimaryContainer: AppColors.onColour,
          secondary: AppColors.accent,
          onSecondary: AppColors.darkSurf,
          secondaryContainer: AppColors.depth,
          onSecondaryContainer: AppColors.onColour,
          tertiary: AppColors.packLight,
          onTertiary: AppColors.darkSurf,
          tertiaryContainer: AppColors.markLight,
          onTertiaryContainer: AppColors.onColour,
          error: AppColors.error,
          onError: AppColors.onColour,
          surface: AppColors.darkSurf,
          onSurface: AppColors.onColour,
          surfaceContainerHighest: AppColors.surfaceDark,
          onSurfaceVariant: Color(0xFFCFC4BE),
          outline: AppColors.packLight,
          outlineVariant: AppColors.markLight,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: AppColors.surfaceLight,
          onInverseSurface: AppColors.darkSurf,
          inversePrimary: AppColors.primary,
        ),
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.darkSurf,
          foregroundColor: AppColors.onColour,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: AppRadius.smAll),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );
}
