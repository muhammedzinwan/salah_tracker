import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  // Modern Primary Colors - Gradient palette
  static const Color primaryStart = Color(0xFF667EEA);  // Soft purple-blue
  static const Color primaryEnd = Color(0xFF764BA2);    // Deep purple
  static const Color accentStart = Color(0xFF00B4DB);   // Bright cyan
  static const Color accentEnd = Color(0xFF0083B0);     // Ocean blue

  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF764BA2);

  // Background Colors
  static const Color background = Color(0xFFF8F9FF);
  static const Color secondaryBackground = Color(0xFFFFFFFF);
  static const Color tertiaryBackground = Color(0xFFF0F2F8);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Prayer Status Colors - Modern vibrant palette
  static const Color jamaah = Color(0xFF10B981);      // Emerald green
  static const Color adah = Color(0xFFF59E0B);        // Amber yellow
  static const Color qalah = Color(0xFFEF4444);       // Soft red
  static const Color missed = Color(0xFF6B7280);      // Gray

  // Text Colors - Better contrast
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF667EEA);

  // Calendar Colors
  static const Color calendarToday = Color(0xFF667EEA);
  static const Color calendarSelected = Color(0xFF10B981);
  static const Color calendarDisabled = Color(0xFFD1D5DB);

  // Chart Colors
  static const List<Color> chartColors = [
    jamaah,
    adah,
    qalah,
    missed,
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
