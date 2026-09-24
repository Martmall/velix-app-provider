import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import 'widgets/onboarding_hero2_widget.dart';

class VendorOnboarding2Screen extends StatelessWidget {
  const VendorOnboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const VelixLogoHeader(),
              const SizedBox(height: 16),
              // Hero section with slanted My Bookings phone mockup
              const Expanded(
                child: Center(
                  child: OnboardingHero2Widget(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Manage Rentals\nFrom Your Phone',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC84C00),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Track bookings, approve requests,\nmonitor trips, and manage returns easily.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC84C00),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PartnerOrangeButton(
                text: 'Next',
                onPressed: () => context.go(AppRoutes.vendorOnboarding3),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
