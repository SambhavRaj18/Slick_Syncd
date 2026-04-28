import 'package:flutter/material.dart';

/// Smart Home AI — Light Blue & White Color System
class AppColors {
  // ─── Core Brand ──────────────────────────────────────────────────────────────
  /// Sky blue — primary brand colour
  static const Color primary = Color(0xFF2196F3);        // Material Blue 500
  static const Color primaryDark = Color(0xFF1565C0);    // Blue 800
  static const Color primaryLight = Color(0xFF64B5F6);   // Blue 300
  static const Color primarySurface = Color(0xFFE3F2FD); // Blue 50

  /// Cyan accent for highlights
  static const Color accent = Color(0xFF00BCD4);         // Cyan 500
  static const Color accentLight = Color(0xFFB2EBF2);    // Cyan 100

  // ─── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F9FF);     // Very light blue-white
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFEBF4FF); // Slightly tinted card

  // ─── Cards & Borders ─────────────────────────────────────────────────────────
  static const Color cardBg = Colors.white;
  static const Color cardDark = Colors.white;            // Kept for backward compat
  static const Color border = Color(0xFFBBDEFB);         // Blue 100
  static const Color borderLight = Color(0xFFE3F2FD);    // Blue 50
  static const Color glassBorder = Color(0xFFBBDEFB);    // alias

  // ─── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0D1B2A);    // Near-black with blue tint
  static const Color textSecondary = Color(0xFF4A6076);  // Muted blue-grey
  static const Color textHint = Color(0xFF90A4AE);       // Blue Grey 300

  // ─── Status ──────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF26A69A);  // Teal 400
  static const Color warning = Color(0xFFFFA726);  // Orange 400
  static const Color error   = Color(0xFFEF5350);  // Red 400
  static const Color info    = Color(0xFF42A5F5);  // Blue 400

  // ─── Device State ────────────────────────────────────────────────────────────
  static const Color deviceOn  = Color(0xFF1E88E5);      // device active tint
  static const Color deviceOff = Color(0xFFB0BEC5);      // device inactive

  // ─── Surface variant (for input fills, chips, etc.) ──────────────────────────
  static const Color surfaceVariant = Color(0xFFE3F2FD); // Blue 50

  // ─── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF5F9FF), Color(0xFFEBF4FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFEBF4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // kept for backward-compat — same as primaryGradient
  static const LinearGradient mainGradient = primaryGradient;
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
