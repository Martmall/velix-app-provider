import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../data_sources/remote/auth_remote_data_source.dart';

class SocialAuthModal {
  static Future<UserModel?> show({
    required BuildContext context,
    required String provider, // 'Google' or 'Apple'
    required bool isPartner,
  }) async {
    final isGoogle = provider.toLowerCase() == 'google';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    // Show clean authenticating dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isGoogle
                      ? const Color(0xFF4285F4).withValues(alpha: 0.12)
                      : (isDark ? const Color(0xFF262B38) : const Color(0xFFF3F4F6)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isGoogle
                      ? const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4285F4),
                          ),
                        )
                      : Icon(
                          Icons.apple,
                          size: 30,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Connecting to $provider',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Secure one-tap authorization with Velix Services',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                color: Color(0xFFC84C00),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final authSource = AuthRemoteDataSource();
      final role = isPartner ? UserRole.partner : UserRole.user;

      UserModel? user;
      if (isGoogle) {
        user = await authSource.signInWithGoogle(role: role);
      } else {
        user = await authSource.oauthLogin(
          provider: 'apple',
          name: 'Apple User',
          email: 'apple.user@velix.ng',
          role: role,
        );
      }

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      }
      return user;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      }
      rethrow;
    }
  }
}
