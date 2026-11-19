import 'package:flutter/material.dart';

import '../theme/velix_palette.dart';

/// Legacy colour names, kept so existing screens compile. Each now points at a Velix token
/// (DESIGN.md). The "dark" names were the old dark-scheme surfaces and map to night tokens.
/// New code should use `Theme.of(context).colorScheme`, `VelixColors.of(context)` or
/// [VelixPalette] directly.
class AppColors {
  static const Color primary = VelixPalette.copper;
  static const Color primaryDark = VelixPalette.onCopperSoft;
  static const Color primaryLight = VelixPalette.nightCopper;

  static const Color backgroundDark = VelixPalette.nightStone;
  static const Color cardDark = VelixPalette.nightPaper;
  static const Color cardDarkElevated = VelixPalette.nightStone3;
  static const Color inputBackground = VelixPalette.nightStone2;

  static const Color success = VelixPalette.go;
  static const Color warning = VelixPalette.brass;
  static const Color error = VelixPalette.claim;
  static const Color info = VelixPalette.ink;

  static const Color textPrimary = VelixPalette.nightInk;
  static const Color textSecondary = VelixPalette.nightMuted;
  static const Color textMuted = VelixPalette.nightLineStrong;

  static const Color border = VelixPalette.nightLine;
  static const Color divider = VelixPalette.nightLine;

  // Velix has no gradients; these stay as flat copper / night surfaces for old callers.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [VelixPalette.copper, VelixPalette.copper],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [VelixPalette.nightPaper, VelixPalette.nightPaper],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
