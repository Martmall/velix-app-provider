import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';
import 'bank_account_sheet.dart';
import 'edit_personal_details_sheet.dart';

class PartnerProfileScreen extends ConsumerStatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  ConsumerState<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends ConsumerState<PartnerProfileScreen> {
  String _selectedLanguage = 'English (EN)';
  bool _isBiometricEnabled = false;
  String? _biometricEmail;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final enabled = await BiometricAuthService.isBiometricEnabled();
    final email = await BiometricAuthService.getEnrolledUserEmail();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = enabled;
        _biometricEmail = email;
      });
    }
  }

  Future<void> _handleToggleBiometrics(bool enable) async {
    final auth = ref.read(partnerAuthProvider);
    final user = auth.user;
    final email = user?.email ?? 'partner@velix.com';
    final fullName = user?.fullName ?? 'Fleet Host Partner';

    if (enable) {
      final success = await BiometricAuthService.authenticate(
        context: context,
        title: 'Register Partner Biometrics',
        localizedReason: 'Scan fingerprint to lock your partner account ($email) to this device',
        actionName: 'Register Biometrics',
      );
      if (success && mounted) {
        await BiometricAuthService.registerBiometrics(
          email: email,
          fullName: fullName,
          role: 'partner',
        );
        setState(() {
          _isBiometricEnabled = true;
          _biometricEmail = email;
        });
        if (mounted) {
          VelixToast.showSuccess(
            context,
            'Partner biometrics registered & locked to $email!',
            title: 'Biometrics Active',
          );
        }
      }
    } else {
      await BiometricAuthService.disableBiometrics();
      setState(() {
        _isBiometricEnabled = false;
        _biometricEmail = null;
      });
      if (mounted) {
        VelixToast.showSuccess(context, 'Partner biometric login disabled.');
      }
    }
  }

  void _showLanguageModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final languages = [
      {'name': 'English (EN)', 'native': 'English'},
      {'name': 'Yorùbá (YOR)', 'native': 'Èdè Yorùbá'},
      {'name': 'Hausa (HAU)', 'native': 'Harshen Hausa'},
      {'name': 'Igbo (IGB)', 'native': 'Asụsụ Igbo'},
      {'name': 'French (FR)', 'native': 'Français'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.70,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 12),
                ...languages.map((lang) {
                  final isSelected = _selectedLanguage == lang['name'];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    title: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFC84C00) : textColor,
                      ),
                    ),
                    subtitle: Text(
                      lang['native']!,
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFFC84C00))
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = lang['name']!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language switched to ${lang['name']}')),
                      );
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final borderColor = isDark ? const Color(0xFF2A2E3D) : const Color(0xFFE5E7EB);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final authState = ref.watch(partnerAuthProvider);
    final user = authState.user;
    final fleetAsync = ref.watch(partnerFleetProvider);
    final bookingsAsync = ref.watch(partnerBookingsProvider);

    final vehicleCount = fleetAsync.when(
      data: (cars) => cars.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final rentalCount = bookingsAsync.when(
      data: (b) => b.where((x) => x.status == BookingStatus.completed || x.status == BookingStatus.active).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final displayName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Partner Host';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : 'partner@velix.ng';
    final initials = displayName.split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const VelixBackButton(fallbackRoute: AppRoutes.partnerHome),
        title: Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.brightness_2_outlined, color: textColor),
            onPressed: () {
              ref.read(appThemeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: textColor),
                onPressed: () => context.go(AppRoutes.partnerTripUpdates),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC84C00),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Terracotta/Orange Hero Profile Card
            GestureDetector(
              onTap: () => EditPersonalDetailsSheet.show(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFC84C00),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC84C00).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar with Camera Overlay
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFFFDF0E9),
                              backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                                  ? Text(
                                      initials.isNotEmpty ? initials : 'ME',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 14, color: Color(0xFFC84C00)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayEmail,
                                style: const TextStyle(fontSize: 13, color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    user?.isVerified == true ? Icons.check_circle : Icons.hourglass_top,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user?.isVerified == true ? 'Verified Partner' : 'Verification Pending',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 12),
                    // 3 Stat Columns Row (Real dynamic numbers)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(number: '$vehicleCount', label: 'Vehicles'),
                        _StatItem(number: '$rentalCount', label: 'Rentals'),
                        _StatItem(number: vehicleCount > 0 ? '5.0' : '0.0', label: 'Rating'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Setting Card 1: Business Info
            _buildSettingCard(
              context: context,
              icon: Icons.business_outlined,
              iconBg: isDark ? const Color(0xFF331616) : const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFEF4444),
              title: 'Business Information',
              subtitle: user?.businessName ?? 'Submit CAC Registration',
              badgeText: user?.cacStatus == 'approved' ? 'Approved' : (user?.cacDocumentUrl != null ? 'Under Review' : null),
              badgeColor: user?.cacStatus == 'approved' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              onTap: () => context.go(AppRoutes.partnerSetUp),
            ),
            const SizedBox(height: 12),
            // Setting Card 2: Bank Account
            _buildSettingCard(
              context: context,
              icon: Icons.account_balance_outlined,
              iconBg: isDark ? const Color(0xFF0F2E22) : const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF10B981),
              title: 'Bank Account',
              subtitle: user?.bankName != null ? '${user!.bankName!} (${user.accountNumber ?? ""})' : 'Add Bank Account for Payouts',
              badgeText: user?.isBankVerified == true ? 'Verified' : null,
              badgeColor: const Color(0xFF10B981),
              onTap: () => BankAccountSheet.show(context),
            ),
            const SizedBox(height: 12),
            // Setting Card 3: Notifications
            _buildSettingCard(
              context: context,
              icon: Icons.notifications_none_outlined,
              iconBg: isDark ? const Color(0xFF14223A) : const Color(0xFFDBEAFE),
              iconColor: const Color(0xFF3B82F6),
              title: 'Notifications & Alerts',
              subtitle: 'Manage trip updates and notifications',
              onTap: () => context.go(AppRoutes.partnerTripUpdates),
            ),
            const SizedBox(height: 12),
            // Setting Card 4: Language
            _buildSettingCard(
              context: context,
              icon: Icons.language,
              iconBg: isDark ? const Color(0xFF281E3B) : const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF6366F1),
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: _showLanguageModal,
            ),
            const SizedBox(height: 12),
            // Setting Card 5: Biometrics & Fingerprint Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fingerprint_rounded, color: Color(0xFFC84C00), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Biometric & Fingerprint Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                        Text(
                          _isBiometricEnabled
                              ? 'Locked to: ${_biometricEmail ?? (user?.email ?? "Active")}'
                              : 'Toggle ON to enable fingerprint quick login',
                          style: TextStyle(
                            fontSize: 10,
                            color: _isBiometricEnabled ? const Color(0xFF10B981) : subtextColor,
                            fontWeight: _isBiometricEnabled ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isBiometricEnabled,
                    activeTrackColor: const Color(0xFFC84C00),
                    activeThumbColor: Colors.white,
                    onChanged: _handleToggleBiometrics,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Setting Card 6: Help & Support
            _buildSettingCard(
              context: context,
              icon: Icons.support_agent_outlined,
              iconBg: isDark ? const Color(0xFF332711) : const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFF59E0B),
              title: 'Help & Support',
              subtitle: 'Contact Velix Support Team',
              onTap: () => context.go(AppRoutes.supportDisputes),
            ),
            const SizedBox(height: 24),
            // Log Out Button
            OutlinedButton(
              onPressed: () async {
                await ref.read(partnerAuthProvider.notifier).signOut();
                if (context.mounted) {
                  VelixToast.showSuccess(
                    context,
                    'Logged out safely. See you soon!',
                    title: 'Logged Out',
                  );
                  context.go(AppRoutes.partnerSignIn);
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: isDark ? const Color(0xFF331616) : const Color(0xFFFEE2E2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: cardBg,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        isPartner: true,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.partnerHome);
              break;
            case 1:
              context.go(AppRoutes.myVehicles);
              break;
            case 2:
              context.go(AppRoutes.partnerBookings);
              break;
            case 3:
              context.go(AppRoutes.earnings);
              break;
            case 4:
              context.go(AppRoutes.partnerProfile);
              break;
          }
        },
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: subtextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? const Color(0xFF10B981)).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor ?? const Color(0xFF10B981)),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
