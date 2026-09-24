import 'package:flutter/material.dart';

class OnboardingHero3Widget extends StatelessWidget {
  const OnboardingHero3Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft peach circle background
          Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              color: Color(0xFFFDF0E9),
              shape: BoxShape.circle,
            ),
          ),
          // Subtle inner ring
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFC84C00).withValues(alpha: 0.1),
                width: 2,
              ),
            ),
          ),
          // Clean Fast Payout Phone Mockup
          _buildFallbackHero(),
        ],
      ),
    );
  }

  Widget _buildFallbackHero() {
    return Transform.rotate(
      angle: 0.1,
      child: Container(
        width: 190,
        height: 250,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFC84C00),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC84C00).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            color: const Color(0xFFF8F9FA),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1830),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 10, color: Color(0xFF0C1830)),
                    SizedBox(width: 2),
                    Text(
                      'Vehicle Access',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C1830),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFDF0E9),
                  child: Icon(
                    Icons.key,
                    size: 20,
                    color: Color(0xFF0C1830),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter Pickup Code',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1830),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter the 6-digit code sent to you to confirm your identity and unlock your vehicle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 6,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => Container(
                      width: 18,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: index == 0 ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB),
                          width: index == 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          index == 0 ? '1' : '',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC84C00),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Resend Code 00:42',
                  style: TextStyle(fontSize: 7, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
