/// config/theme/app_text_styles.dart
/// Centralized typography for consistent styling across the app.

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Headers & Titles ───────────────────────────────────
  static const TextStyle logoText = TextStyle(
    fontFamily: 'Syne',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Syne',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
    decoration: TextDecoration.none,
  );

  static const TextStyle toolName = TextStyle(
    fontFamily: 'Syne',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle toolNameWide = TextStyle(
    fontFamily: 'Syne',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle uploadTitle = TextStyle(
    fontFamily: 'Syne',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'Syne',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.bgBase,
  );

  // ── Body Text ──────────────────────────────────────────
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 12,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 11,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyTiny = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 10,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  static const TextStyle uploadSubtitle = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 11,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle toolDescription = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 10,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // ── Stats ──────────────────────────────────────────────
  static const TextStyle statValue = TextStyle(
    fontFamily: 'Syne',
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.accent,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  // ── File Item ──────────────────────────────────────────
  static const TextStyle fileName = TextStyle(
    fontFamily: 'Syne',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle fileMeta = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 10,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  // ── Navigation ─────────────────────────────────────────
  static const TextStyle navLabel = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle badgeLabel = TextStyle(
    fontFamily: 'DM Mono',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );
}