import 'package:flutter/material.dart';

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
          color: const Color(0xFF0C1830),
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
            color: const Color(0xFFF8F9FA),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
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
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C1830),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
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
                              Text('Micheal Benson', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                              Text('Toyota Camry 2022', style: TextStyle(fontSize: 7, color: Color(0xFF6B7280))),
                            ],
                          ),
                          Text('₦35,000', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('14 May - 17 May', style: TextStyle(fontSize: 7, color: Color(0xFF374151))),
                            Text('3 days', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
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
                                color: const Color(0xFFC84C00),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text('Approve', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text('Reject', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
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
        color: isSelected ? const Color(0xFFC84C00) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? const Color(0xFFC84C00) : const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
