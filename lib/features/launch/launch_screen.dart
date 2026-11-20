import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

/// Launch screen: shows the logo while the saved session is restored, then opens the app
/// signed in (partner home) or goes to onboarding for a new or signed-out partner.
class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  Future<void> _continue() async {
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 600)),
      ref.read(partnerAuthProvider.notifier).ready,
    ]);
    if (!mounted) return;
    final signedIn = ref.read(partnerAuthProvider).isAuthenticated;
    context.go(signedIn ? AppRoutes.partnerHome : AppRoutes.vendorOnboarding1);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VelixPalette.paper,
      body: SafeArea(child: Center(child: VelixLogoHeader())),
    );
  }
}
