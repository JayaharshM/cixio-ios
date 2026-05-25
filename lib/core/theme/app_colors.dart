import 'package:flutter/material.dart';

/// Centralised, theme-aware colour palette for the entire app.
///
/// Usage:  `final c = AppColors.of(context);`
///
/// Every colour adapts automatically when the user toggles dark / light mode.
class AppColors {
  AppColors._(this._dark);

  factory AppColors.of(BuildContext context) {
    return AppColors._(Theme.of(context).brightness == Brightness.dark);
  }

  final bool _dark;

  // ── Backgrounds ──────────────────────────────────────────────────────────
  Color get scaffoldBg       => _dark ? const Color(0xFF101415) : const Color(0xFFF0F2F5);
  Color get cardBg           => _dark ? const Color(0xFF1E2024) : Colors.white;
  Color get elevatedCardBg   => _dark ? const Color(0xFF161A1D) : Colors.white;
  Color get inputBg          => _dark ? const Color(0xFF15181B) : const Color(0xFFF5F5FA);
  Color get headerBg         => _dark ? const Color(0xFF101415) : const Color(0xFFF0F2F5);

  // ── Surfaces & containers ────────────────────────────────────────────────
  Color get surfaceDim       => _dark ? const Color(0xFF2A2D32) : const Color(0xFFEEEFF3);
  Color get iconContainer    => _dark ? const Color(0xFF1E2327) : const Color(0xFFEEEFF3);
  Color get dialogBg         => _dark ? const Color(0xFF1A1F21) : Colors.white;

  // ── Text ─────────────────────────────────────────────────────────────────
  Color get textPrimary      => _dark ? const Color(0xFFE9E5F5) : const Color(0xFF1A1A2E);
  Color get textSecondary    => _dark ? const Color(0xFFA3A7AA) : const Color(0xFF6B6B80);
  Color get textMuted        => _dark ? const Color(0xFF6B7077) : const Color(0xFF9A9AAA);
  Color get textOnDark       => const Color(0xFFE9E5F5);

  // ── Borders & dividers ───────────────────────────────────────────────────
  Color get border           => _dark ? const Color(0xFF2A2F32) : const Color(0xFFDDDDE8);
  Color get divider          => _dark ? const Color(0xFF1E2327) : const Color(0xFFEEEEF5);

  // ── Accents ──────────────────────────────────────────────────────────────
  Color get accent           => Colors.indigoAccent.shade200;
  Color get accentMuted      => _dark ? const Color(0xFF342A66) : const Color(0xFFEAE8FF);

  // ── Icons ────────────────────────────────────────────────────────────────
  Color get icon             => _dark ? const Color(0xFFD3CEE2) : const Color(0xFF5B5B7A);
  Color get iconMuted        => _dark ? const Color(0xFF4A4F55) : const Color(0xFFBBBBC8);

  // ── Chat-specific ────────────────────────────────────────────────────────
  Color get userBubbleBg     => _dark ? const Color(0xFF323638) : const Color(0xFFE8E5FF);
  Color get assistantBubbleBg => _dark ? const Color(0xFF1E2024) : const Color(0xFFF5F5FA);
  Color get chatInputBorder  => _dark
      ? const Color(0xFF5B4DFF).withValues(alpha: 0.5)
      : const Color(0xFF5B4DFF).withValues(alpha: 0.3);
  Color get chatInputGlow    => _dark
      ? const Color(0xFF5B4DFF).withValues(alpha: 0.15)
      : const Color(0xFF5B4DFF).withValues(alpha: 0.08);

  // ── Nav bar ──────────────────────────────────────────────────────────────
  Color get navSelected      => _dark ? const Color(0xFFF1EEFF) : const Color(0xFF2D2B4E);
  Color get navUnselected    => _dark ? const Color(0xFFC0BDCB) : const Color(0xFF8A8AA0);
  Color get navActiveBg      => _dark ? const Color(0xFF342A66) : const Color(0xFFEAE8FF);

  // ── Todo-specific ────────────────────────────────────────────────────────
  Color get todoItemBg       => _dark ? const Color(0xFF1E2024) : Colors.white;
  Color get todoItemDoneBg   => _dark ? const Color(0xFF0F1213) : const Color(0xFFF0F0F5);
  Color get checkboxFill     => _dark ? const Color(0xFF2A2F32) : const Color(0xFFDDDDE8);
}
