import 'package:flutter/material.dart';

import 'velix_palette.dart';

/// The Velix roles Material 3's ColorScheme has no slot for (DESIGN.md "extension" rows).
///
/// Read with `VelixColors.of(context)`. `vault` stays a dark plate in both schemes (unlike
/// `ink`, which inverts at night), so the proof strip and the pickup stub use it.
@immutable
class VelixColors extends ThemeExtension<VelixColors> {
  const VelixColors({
    required this.vault,
    required this.onVault,
    required this.onVaultMuted,
    required this.tertiaryOnVault,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  final Color vault;
  final Color onVault;
  final Color onVaultMuted;
  final Color tertiaryOnVault;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warningContainer;
  final Color onWarningContainer;

  static const light = VelixColors(
    vault: VelixPalette.vault,
    onVault: VelixPalette.onVault,
    onVaultMuted: VelixPalette.onVaultMuted,
    tertiaryOnVault: VelixPalette.brassLight,
    success: VelixPalette.go,
    successContainer: VelixPalette.goSoft,
    onSuccessContainer: VelixPalette.onGoSoft,
    warningContainer: VelixPalette.amberSoft,
    onWarningContainer: VelixPalette.onAmberSoft,
  );

  static const night = VelixColors(
    vault: VelixPalette.nightVault,
    onVault: VelixPalette.nightOnVault,
    onVaultMuted: VelixPalette.onVaultMuted,
    tertiaryOnVault: VelixPalette.brassLight,
    success: VelixPalette.nightGo,
    successContainer: VelixPalette.nightGoSoft,
    onSuccessContainer: VelixPalette.nightOnGoSoft,
    warningContainer: VelixPalette.nightAmberSoft,
    onWarningContainer: VelixPalette.nightOnAmberSoft,
  );

  static VelixColors of(BuildContext context) =>
      Theme.of(context).extension<VelixColors>() ?? light;

  @override
  VelixColors copyWith({
    Color? vault,
    Color? onVault,
    Color? onVaultMuted,
    Color? tertiaryOnVault,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return VelixColors(
      vault: vault ?? this.vault,
      onVault: onVault ?? this.onVault,
      onVaultMuted: onVaultMuted ?? this.onVaultMuted,
      tertiaryOnVault: tertiaryOnVault ?? this.tertiaryOnVault,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  VelixColors lerp(VelixColors? other, double t) {
    if (other == null) return this;
    return VelixColors(
      vault: Color.lerp(vault, other.vault, t)!,
      onVault: Color.lerp(onVault, other.onVault, t)!,
      onVaultMuted: Color.lerp(onVaultMuted, other.onVaultMuted, t)!,
      tertiaryOnVault: Color.lerp(tertiaryOnVault, other.tertiaryOnVault, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
    );
  }
}
