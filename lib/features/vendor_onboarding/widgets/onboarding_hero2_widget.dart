import 'package:flutter/material.dart';

import 'package:velix_core/theme/velix_palette.dart';
class OnboardingHero2Widget extends StatelessWidget {
  const OnboardingHero2Widget({super.key});

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
              color: VelixPalette.copperSoft,
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
                color: VelixPalette.copper.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
          ),
          // Clean GPS Tracking Phone Mockup
          _buildFallbackHero(),
        ],
      ),
    );
  }

  Widget _buildFallbackHero() {
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        width: 190,
        height: 250,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: VelixPalette.ink,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            color: VelixPalette.stone,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VelixPalette.ink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 10, color: VelixPalette.ink),
                    SizedBox(width: 2),
                    Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: VelixPalette.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Pending 2', true),
                      const SizedBox(width: 4),
                      _buildChip('Active 3', false),
                      const SizedBox(width: 4),
                      _buildChip('Done 3', false),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: VelixPalette.paper,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: VelixPalette.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Micheal Benson', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                              Text('Toyota Camry 2022', style: TextStyle(fontSize: 7, color: VelixPalette.muted)),
                            ],
                          ),
                          Text('₦35,000', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelixPalette.copper)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: VelixPalette.stone,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('14 May - 17 May', style: TextStyle(fontSize: 7, color: VelixPalette.muted)),
                            Text('3 days', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: VelixPalette.ink)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: VelixPalette.copper,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text('Approve', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: VelixPalette.paper)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: VelixPalette.line,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text('Reject', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: VelixPalette.muted)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? VelixPalette.copper : VelixPalette.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? VelixPalette.copper : VelixPalette.line),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? VelixPalette.paper : VelixPalette.muted,
        ),
      ),
    );
  }
}
