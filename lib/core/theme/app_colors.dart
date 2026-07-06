import 'package:flutter/material.dart';

abstract class AppColors {
  // Core Palette
  /// Sunset Coral — Primary brand colour
  static const primary = Color(0xFFF2683C);

  /// Sunset Amber — Highlight / gradient start
  static const highlight = Color(0xFFFFB347);

  /// Dusk Plum — Depth / gradient end
  static const depth = Color(0xFFB23A55);

  /// Trail Gold — Accent
  static const accent = Color(0xFFFFD15E);

  // Ink & Surfaces
  /// Snow — text / icons on coloured backgrounds
  static const onColour = Color(0xFFFFFFFF);

  /// Plum Ink — mark-light surface
  static const markLight = Color(0xFF5A3A5E);

  /// Coral Ink — pack-light surface
  static const packLight = Color(0xFFE8743A);

  /// Forest Night — dark surface background
  static const darkSurf = Color(0xFF10201D);

  // Gradient stops (0% → 48% → 100%)
  static const gradientStart = highlight; // #FFB347
  static const gradientMid = primary; // #F2683C
  static const gradientEnd = depth; // #B23A55

  static const brandGradient = LinearGradient(
    colors: [gradientStart, gradientMid, gradientEnd],
    stops: [0.0, 0.48, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Semantic
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF4CAF50);
  static const warning = accent;

  // Surfaces
  static const backgroundLight = onColour;
  static const backgroundDark = darkSurf;
  static const surfaceLight = Color(0xFFFAF8F6);
  static const surfaceDark = Color(0xFF1A2E2A);
}
