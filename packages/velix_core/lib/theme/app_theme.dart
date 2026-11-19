import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'velix_colors.dart';
import 'velix_palette.dart';
import 'velix_typography.dart';

export 'velix_colors.dart';
export 'velix_palette.dart';
export 'velix_typography.dart';

final appThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// The Velix light and night themes, built from DESIGN.md ("The Valet's Claim Ticket").
///
/// Light and night redefine the same roles; no component gets its own dark colours.
class AppTheme {
  static ThemeData get lightTheme => _build(_lightScheme, VelixColors.light);
  static ThemeData get darkTheme => _build(_nightScheme, VelixColors.night);

  // Roles DESIGN.md defines map 1:1. Roles it leaves undecided (onTertiary, onError,
  // onErrorContainer, the low/highest containers, inverse roles) take the nearest defined
  // token so they stay consistent across apps until the design decides them.
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: VelixPalette.ink,
    onPrimary: VelixPalette.onInk,
    primaryContainer: VelixPalette.stone2,
    onPrimaryContainer: VelixPalette.ink,
    secondary: VelixPalette.copper,
    onSecondary: VelixPalette.onCopper,
    secondaryContainer: VelixPalette.copperSoft,
    onSecondaryContainer: VelixPalette.onCopperSoft,
    tertiary: VelixPalette.brass,
    onTertiary: VelixPalette.paper,
    tertiaryContainer: VelixPalette.brassSoft,
    onTertiaryContainer: VelixPalette.brass,
    error: VelixPalette.claim,
    onError: VelixPalette.paper,
    errorContainer: VelixPalette.claimSoft,
    onErrorContainer: VelixPalette.claim,
    surface: VelixPalette.stone,
    onSurface: VelixPalette.ink,
    onSurfaceVariant: VelixPalette.muted,
    surfaceContainerLowest: VelixPalette.paper,
    surfaceContainerLow: VelixPalette.paper,
    surfaceContainer: VelixPalette.stone2,
    surfaceContainerHigh: VelixPalette.stone3,
    surfaceContainerHighest: VelixPalette.stone3,
    outline: VelixPalette.lineStrong,
    outlineVariant: VelixPalette.line,
    inverseSurface: VelixPalette.ink,
    onInverseSurface: VelixPalette.onInk,
    inversePrimary: VelixPalette.nightInk,
    shadow: VelixPalette.ink,
    scrim: Color(0x9E0A101E),
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _nightScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: VelixPalette.nightInk,
    onPrimary: VelixPalette.nightOnInk,
    primaryContainer: VelixPalette.nightStone3,
    onPrimaryContainer: VelixPalette.nightInk,
    secondary: VelixPalette.nightCopper,
    onSecondary: VelixPalette.nightOnCopper,
    secondaryContainer: VelixPalette.nightCopperSoft,
    onSecondaryContainer: VelixPalette.nightOnCopperSoft,
    tertiary: VelixPalette.nightBrass,
    onTertiary: VelixPalette.nightOnInk,
    tertiaryContainer: VelixPalette.nightBrassSoft,
    onTertiaryContainer: VelixPalette.nightBrass,
    error: VelixPalette.nightClaim,
    onError: VelixPalette.nightOnInk,
    errorContainer: VelixPalette.nightClaimSoft,
    onErrorContainer: VelixPalette.nightClaim,
    surface: VelixPalette.nightStone,
    onSurface: VelixPalette.nightInk,
    onSurfaceVariant: VelixPalette.nightMuted,
    surfaceContainerLowest: VelixPalette.nightPaper,
    surfaceContainerLow: VelixPalette.nightPaper,
    surfaceContainer: VelixPalette.nightStone2,
    surfaceContainerHigh: VelixPalette.nightStone3,
    surfaceContainerHighest: VelixPalette.nightStone3,
    outline: VelixPalette.nightLineStrong,
    outlineVariant: VelixPalette.nightLine,
    inverseSurface: VelixPalette.nightInk,
    onInverseSurface: VelixPalette.nightOnInk,
    inversePrimary: VelixPalette.ink,
    shadow: Colors.black,
    scrim: Color(0x9E000000),
    surfaceTint: Colors.transparent,
  );

  static ThemeData _build(ColorScheme c, VelixColors v) {
    final text = VelixTypography.textTheme(c.onSurface, c.onSurfaceVariant);
    final paper = c.surfaceContainerLowest;
    RoundedRectangleBorder rounded(double r, [BorderSide side = BorderSide.none]) =>
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(r), side: side);

    return ThemeData(
      useMaterial3: true,
      colorScheme: c,
      brightness: c.brightness,
      fontFamily: VelixTypography.ui,
      textTheme: text,
      primaryTextTheme: text,
      scaffoldBackgroundColor: c.surface,
      canvasColor: c.surface,
      primaryColor: c.primary,
      dividerColor: c.outlineVariant,
      focusColor: c.secondary.withValues(alpha: 0.24),
      extensions: [v],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.secondary,
        selectionColor: c.secondaryContainer,
        selectionHandleColor: c.secondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 64,
        iconTheme: IconThemeData(color: c.onSurface),
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded(VelixRadius.card, BorderSide(color: c.outlineVariant)),
      ),
      dividerTheme: DividerThemeData(color: c.outlineVariant, thickness: 1, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.surfaceContainerHigh,
          disabledForegroundColor: c.onSurfaceVariant,
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: text.titleMedium,
          shape: rounded(VelixRadius.control),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: text.titleMedium,
          shape: rounded(VelixRadius.control),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.onSurface,
          side: BorderSide(color: c.outline),
          minimumSize: const Size(64, 48),
          textStyle: text.titleMedium,
          shape: rounded(VelixRadius.control),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.secondary, textStyle: text.labelLarge),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 0,
        shape: rounded(VelixRadius.indicator),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        labelStyle: text.labelMedium,
        floatingLabelStyle: text.labelMedium?.copyWith(color: c.secondary),
        hintStyle: text.bodyMedium?.copyWith(color: c.onSurfaceVariant),
        prefixIconColor: c.onSurfaceVariant,
        suffixIconColor: c.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VelixRadius.control),
          borderSide: BorderSide(color: c.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VelixRadius.control),
          borderSide: BorderSide(color: c.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VelixRadius.control),
          borderSide: BorderSide(color: c.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VelixRadius.control),
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VelixRadius.control),
          borderSide: BorderSide(color: c.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: c.secondaryContainer,
        checkmarkColor: c.onSecondaryContainer,
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge?.copyWith(color: c.onSecondaryContainer),
        side: BorderSide(color: c.outline),
        shape: rounded(VelixRadius.chip),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.secondaryContainer,
        height: 80,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected) ? c.onSurface : c.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? c.onSecondaryContainer
                : c.onSurfaceVariant,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surfaceContainer,
        selectedItemColor: c.onSurface,
        unselectedItemColor: c.onSurfaceVariant,
        selectedLabelStyle: text.labelMedium,
        unselectedLabelStyle: text.labelMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.onSurface,
        unselectedLabelColor: c.onSurfaceVariant,
        indicatorColor: c.secondary,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
        dividerColor: c.outlineVariant,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        shape: rounded(VelixRadius.card),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: paper,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(VelixRadius.card)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: v.vault,
        contentTextStyle: text.bodyMedium?.copyWith(color: v.onVault),
        actionTextColor: v.tertiaryOnVault,
        behavior: SnackBarBehavior.floating,
        shape: rounded(VelixRadius.control),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.onSurfaceVariant,
        textColor: c.onSurface,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.secondary,
        linearTrackColor: c.outlineVariant,
        circularTrackColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceContainerHigh,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        side: BorderSide(color: c.outline, width: 1.5),
        shape: rounded(VelixRadius.tag / 2 + 1),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.outline,
        ),
      ),
    );
  }
}
