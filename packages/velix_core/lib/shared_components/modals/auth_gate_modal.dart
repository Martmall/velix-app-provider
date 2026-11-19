import 'package:flutter/material.dart';

import 'package:velix_core/theme/velix_palette.dart';
/// Modal triggered when an unauthenticated guest user taps a protected feature (e.g. Booking, Wallet, Saved, KYC).
class AuthGateModal {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onSignIn,
    required VoidCallback onRegister,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? VelixPalette.nightPaper : VelixPalette.paper;
    final textColor = isDark ? VelixPalette.paper : VelixPalette.ink;
    final subtextColor = isDark ? VelixPalette.nightMuted : VelixPalette.muted;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? VelixPalette.nightLineStrong : VelixPalette.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VelixPalette.copper.withValues(alpha: 0.12),
                  border: Border.all(color: VelixPalette.copper.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 32,
                  color: VelixPalette.copper,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: subtextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onSignIn();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelixPalette.copper,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign In to Your Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: VelixPalette.paper,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onRegister();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(
                    color: isDark ? VelixPalette.nightMuted : VelixPalette.lineStrong,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Create New Velix Account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Continue Browsing as Guest',
                  style: TextStyle(
                    fontSize: 13,
                    color: subtextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
