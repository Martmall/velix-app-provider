import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2F6FED);
  static const Color primaryDark = Color(0xFF1E52C1);
  static const Color primaryLight = Color(0xFF6395FF);

  static const Color backgroundDark = Color(0xFF0D0F17);
  static const Color cardDark = Color(0xFF161922);
  static const Color cardDarkElevated = Color(0xFF1E222D);
  static const Color inputBackground = Color(0xFF1C202C);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color border = Color(0xFF262B38);
  static const Color divider = Color(0xFF1F2430);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2F6FED), Color(0xFF1E52C1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C202C), Color(0xFF141722)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
