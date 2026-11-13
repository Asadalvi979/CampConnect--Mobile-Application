import 'package:flutter/material.dart';

/// Semantic color tokens for CampConnect.
///
/// Layer 1 (primitive) and layer 2 (semantic) of the three-layer token
/// system. Components must use these tokens, never raw hex literals.
/// Existing names are kept so the ~45 screens not yet rebuilt keep working;
/// new semantic aliases (textPrimary, surface, …) are the preferred names.
abstract final class AppColors {
  // Brand.
  static const primary = Color(0xFF2563EB);
  static const deepPrimary = Color(0xFF004AC6);
  static const primaryDark = Color(0xFF004AC6);
  static const secondary = Color(0xFF3B82F6);
  // Retired from the rebuilt screens: the clean-current direction uses
  // blue #2563EB as the only accent. Kept for compatibility.
  static const accent = Color(0xFFEA580C);

  // Surfaces.
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const white = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFE9EFF8);
  static const paleBlue = Color(0xFFEEF4FF);
  static const lightBlue = Color(0xFFDBEAFE);
  // Form-field fill: light gray, no visible border.
  static const inputFill = Color(0xFFF1F5F9);

  // Text.
  static const primaryText = Color(0xFF1E293B);
  static const textPrimary = Color(0xFF1E293B);
  static const secondaryText = Color(0xFF475569);
  static const textSecondary = Color(0xFF475569);
  static const mutedText = Color(0xFF64748B);
  static const textMuted = Color(0xFF64748B);
  static const onPrimary = Color(0xFFFFFFFF);

  // Borders and states.
  static const border = Color(0xFFE2E8F0);
  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF007D55);
  static const warning = Color(0xFFD97706);

  // Supporting hues (metric cards, tile icons).
  static const violet = Color(0xFF7C3AED);
  static const teal = Color(0xFF0891B2);
  static const green = Color(0xFF059669);
  static const amber = Color(0xFFF59E0B);
  static const pink = Color(0xFFDB2777);

  // Campus-service tile accents: pastel ground paired with a matching
  // icon color. The rebuilt screens use only the blue pair; the rest are
  // kept for compatibility.
  static const tileBlue = Color(0xFFE7EEFF);
  static const tileBlueIcon = Color(0xFF2563EB);
  static const tileViolet = Color(0xFFE9E6FF);
  static const tileVioletIcon = Color(0xFF7C3AED);
  static const tileTeal = Color(0xFFE1F4F4);
  static const tileTealIcon = Color(0xFF0891B2);
  static const tileGreen = Color(0xFFE5F5EA);
  static const tileGreenIcon = Color(0xFF059669);
  static const tileAmber = Color(0xFFFFF0DF);
  static const tileAmberIcon = Color(0xFFD97706);
  static const tilePink = Color(0xFFFFE9ED);
  static const tilePinkIcon = Color(0xFFDB2777);
}
