import 'package:flutter/material.dart';
import 'package:velix_core/velix_core.dart';

class OnboardingHero1Widget extends StatelessWidget {
  const OnboardingHero1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft peach circle background
          Container(
            width: 270,
            height: 270,
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
          // Clean Native Illustration Mockup
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vehicle Fleet Card
              Container(
                width: 175,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        CarImageCatalog.mercedesGle,
                        width: double.infinity,
                        height: 95,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 95,
                          color: const Color(0xFFF3F4F6),
                          child: const Center(child: Icon(Icons.directions_car, size: 48, color: Color(0xFF9CA3AF))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Mercedes-Benz',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C1830)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                            SizedBox(width: 2),
                            Text('4.9', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '₦85,000 / day',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Smartphone Host App Mockup
              Container(
                width: 78,
                height: 155,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1830), // Dark Navy Phone Body
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E293B), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0C1830).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Phone speaker bar
                    Container(
                      width: 24,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Host Profile Avatar
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFC84C00),
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Host Portal',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    // Live earnings pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '+₦120k',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                      ),
                    ),
                    const Spacer(),
                    // Car Key Icon
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF1E293B),
                      child: Icon(Icons.key, size: 12, color: Color(0xFFFDE68A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
