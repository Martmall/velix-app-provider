import 'package:flutter/material.dart';

/// Type roles from DESIGN.md. Hanken Grotesk for everything except things that are counted
/// (claim numbers, codes, times, distances, money), which use Red Hat Mono with tabular
/// figures. Flutter letterSpacing is absolute, so DESIGN.md's em values are × fontSize.
///
/// Neither face has a ₦ glyph; Android draws that one character in the system font.
abstract final class VelixTypography {
  static const String ui = 'packages/velix_core/HankenGrotesk';
  static const String data = 'packages/velix_core/RedHatMono';
  static const List<FontFeature> _tnum = [FontFeature.tabularFigures()];

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    TextStyle s(double size, FontWeight weight, double height, [double tracking = 0]) =>
        TextStyle(
          fontFamily: ui,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: tracking,
          color: onSurface,
        );

    return TextTheme(
      // DESIGN.md defines headlineMedium down to labelMedium. The roles above and below
      // follow the same face and steps so stray uses of them still look like Velix.
      displayLarge: s(44, FontWeight.w800, 1.1, -0.88),
      displayMedium: s(38, FontWeight.w800, 1.1, -0.76),
      displaySmall: s(32, FontWeight.w800, 1.12, -0.64),
      headlineLarge: s(30, FontWeight.w800, 1.15, -0.6),
      headlineMedium: s(28, FontWeight.w800, 1.15, -0.56),
      headlineSmall: s(23, FontWeight.w800, 1.15, -0.345),
      titleLarge: s(20, FontWeight.w700, 1.25, -0.2),
      titleMedium: s(16, FontWeight.w700, 1.3),
      titleSmall: s(14, FontWeight.w700, 1.3),
      bodyLarge: s(16, FontWeight.w400, 1.5),
      bodyMedium: s(14, FontWeight.w400, 1.45),
      bodySmall: s(13, FontWeight.w400, 1.4).copyWith(color: onSurfaceVariant),
      labelLarge: s(14, FontWeight.w700, 1.2),
      labelMedium: s(12, FontWeight.w600, 1.3).copyWith(color: onSurfaceVariant),
      labelSmall: s(11, FontWeight.w600, 1.3).copyWith(color: onSurfaceVariant),
    );
  }

  /// Pickup code: 40, tracking 0.18em, grouped in threes.
  static const TextStyle dataLarge = TextStyle(
    fontFamily: data,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 7.2,
    fontFeatures: _tnum,
  );

  static const TextStyle dataMedium = TextStyle(
    fontFamily: data,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFeatures: _tnum,
  );

  /// Claim-number tag.
  static const TextStyle dataSmall = TextStyle(
    fontFamily: data,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.66,
    fontFeatures: _tnum,
  );

  /// Inline numbers (`.num` on web): the mono face at the surrounding size.
  static TextStyle number(TextStyle base, {FontWeight weight = FontWeight.w600}) =>
      base.copyWith(fontFamily: data, fontWeight: weight, fontFeatures: _tnum);
}
