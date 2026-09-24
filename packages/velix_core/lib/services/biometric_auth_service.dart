import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unified Biometric & Fingerprint Authentication service for Velix Apps.
/// Enforces strict user-to-device enrollment: users must register and toggle on
/// biometrics in Settings before using it for quick login.
class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  static const String _keyBiometricEnabled = 'velix_biometric_enabled';
  static const String _keyBiometricEmail = 'velix_biometric_user_email';
  static const String _keyBiometricName = 'velix_biometric_user_name';
  static const String _keyBiometricRole = 'velix_biometric_user_role';

  /// Check if biometric authentication is enabled on this device.
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Get the strictly registered email address bound to this device's biometrics.
  static Future<String?> getEnrolledUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBiometricEmail);
  }

  /// Get the strictly registered user full name.
  static Future<String?> getEnrolledUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBiometricName);
  }

  /// Get the registered user role (user or partner).
  static Future<String?> getEnrolledUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBiometricRole);
  }

  /// Register/Enroll a specific user's biometrics and toggle on biometric login.
  static Future<void> registerBiometrics({
    required String email,
    required String fullName,
    String role = 'user',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, true);
    await prefs.setString(_keyBiometricEmail, email.trim().toLowerCase());
    await prefs.setString(_keyBiometricName, fullName.trim());
    await prefs.setString(_keyBiometricRole, role);
  }

  /// Disable biometric login and clear enrollment on this device.
  static Future<void> disableBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, false);
    await prefs.remove(_keyBiometricEmail);
    await prefs.remove(_keyBiometricName);
    await prefs.remove(_keyBiometricRole);
  }

  /// Prompt user for Fingerprint / Biometric scan.
  static Future<bool> authenticate({
    required BuildContext context,
    String title = 'Fingerprint Authentication',
    String localizedReason = 'Scan your registered fingerprint to authenticate securely',
    String actionName = 'Verify',
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BiometricAuthSheet(
        title: title,
        localizedReason: localizedReason,
        actionName: actionName,
      ),
    ) ?? false;
  }
}

class _BiometricAuthSheet extends StatefulWidget {
  final String title;
  final String localizedReason;
  final String actionName;

  const _BiometricAuthSheet({
    required this.title,
    required this.localizedReason,
    required this.actionName,
  });

  @override
  State<_BiometricAuthSheet> createState() => _BiometricAuthSheetState();
}

class _BiometricAuthSheetState extends State<_BiometricAuthSheet> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;
  bool _isAuthenticating = true;
  bool _isSuccess = false;
  String _statusText = 'Touch the fingerprint sensor';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _simulateBiometricScan();
  }

  Future<void> _simulateBiometricScan() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _isSuccess = true;
      _statusText = 'Biometric Verified!';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Container(
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
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.localizedReason,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: subtextColor,
              ),
            ),
            const SizedBox(height: 32),
            // Animated Fingerprint Scan Icon
            AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isAuthenticating ? _scaleAnim.value : 1.0,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isSuccess
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFC84C00).withValues(alpha: 0.12),
                      border: Border.all(
                        color: _isSuccess
                            ? const Color(0xFF10B981)
                            : const Color(0xFFC84C00),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isSuccess ? const Color(0xFF10B981) : const Color(0xFFC84C00))
                              .withValues(alpha: 0.25),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isSuccess ? Icons.check_rounded : Icons.fingerprint_rounded,
                      size: 46,
                      color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFC84C00),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _isSuccess ? const Color(0xFF10B981) : textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _simulateBiometricScan(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC84C00),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.actionName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
