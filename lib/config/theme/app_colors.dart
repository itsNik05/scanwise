/// config/theme/app_colors.dart
/// Contains all color constants used throughout the app.

import 'package:flutter/material.dart';

class AppColors {
  // ── Base/Background ────────────────────────────────────
  static const Color bgBase = Color(0xFF0D0D0F);
  static const Color bgCard = Color(0xFF131316);
  static const Color bgCard2 = Color(0xFF1A1A1F);
  static const Color bgHover = Color(0xFF202027);

  // ── Borders ────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A35);

  // ── Accents ────────────────────────────────────────────
  static const Color accent = Color(0xFFFF6B2B); // Primary orange
  static const Color accent2 = Color(0xFFFFB347); // Light orange/amber
  static const Color accentSoft = Color(0x22FF6B2B); // Soft orange (with opacity)

  // ── Text ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0EEE8);
  static const Color textSecondary = Color(0xFF888899);
  static const Color textMuted = Color(0xFF444455);

  // ── Status Colors ──────────────────────────────────────
  static const Color success = Color(0xFF4ADE80);
  static const Color info = Color(0xFF60A5FA);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);

  // ── Tool Card Colors ───────────────────────────────────
  static const Color toolOrange = Color(0xFFFF6B2B);
  static const Color toolBlue = Color(0xFF60A5FA);
  static const Color toolGreen = Color(0xFF4ADE80);
  static const Color toolPurple = Color(0xFFA78BFA);
  static const Color toolPink = Color(0xFFF472B6);
  static const Color toolTeal = Color(0xFF2DD4BF);
  static const Color toolAmber = Color(0xFFFBBF24);
  static const Color toolRed = Color(0xFFF87171);

  // ── Helper Methods ─────────────────────────────────────
  static Color getToolColor(String colorKey) {
    switch (colorKey.toLowerCase()) {
      case 'orange':
        return toolOrange;
      case 'blue':
        return toolBlue;
      case 'green':
        return toolGreen;
      case 'purple':
        return toolPurple;
      case 'pink':
        return toolPink;
      case 'teal':
        return toolTeal;
      case 'amber':
        return toolAmber;
      case 'red':
        return toolRed;
      default:
        return accent;
    }
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}