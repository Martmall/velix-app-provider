import 'package:flutter/material.dart';

class OnboardingHero4Widget extends StatelessWidget {
  const OnboardingHero4Widget({super.key});

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
          // Clean 24/7 Concierge Phone Mockup
          _buildFallbackHero(),
        ],
      ),
    );
  }

  Widget _buildFallbackHero() {
    return Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_back_ios, size: 10, color: Color(0xFF0C1830)),
                      SizedBox(width: 2),
                      Text(
                        'My Earnings',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C1830),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: Color(0xFFC84C00),
                    child: Text('JD', style: TextStyle(fontSize: 6, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Thursday, 16 May', style: TextStyle(fontSize: 6, color: Color(0xFF6B7280))),
              const Text('Welcome back, John', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1830),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Earnings', style: TextStyle(fontSize: 7, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text('₦2,450,000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('↗ +12.5% vs last month', style: TextStyle(fontSize: 6, color: Colors.lightGreenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Revenue Trend', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF0C1830))),
              const SizedBox(height: 4),
              SizedBox(
                height: 35,
                width: double.infinity,
                child: CustomPaint(
                  painter: _TrendChartPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC84C00)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.3, size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = const Color(0xFFC84C00)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
