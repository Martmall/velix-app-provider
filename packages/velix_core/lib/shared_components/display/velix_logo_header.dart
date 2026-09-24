import 'package:flutter/material.dart';

enum VelixLogoStyle {
  fullHorizontal,
  iconOnly,
  stackedWithTagline,
}

class VelixLogoHeader extends StatelessWidget {
  final double height;
  final VelixLogoStyle style;
  final bool showTagline;
  final Color? textColor;

  const VelixLogoHeader({
    super.key,
    this.height = 44,
    this.style = VelixLogoStyle.fullHorizontal,
    this.showTagline = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = textColor ?? (isDark ? Colors.white : const Color(0xFF0C1830));

    if (style == VelixLogoStyle.iconOnly) {
      return Container(
        width: height,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC84C00).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height * 0.22),
          child: Image.asset(
            'packages/velix_core/assets/logos/velix_icon.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/velix_icon.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackIcon(height),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC84C00).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height * 0.22),
                child: Image.asset(
                  'packages/velix_core/assets/logos/velix_icon.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/velix_icon.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackIcon(height),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Velix',
                  style: TextStyle(
                    fontSize: height * 0.65,
                    fontWeight: FontWeight.w900,
                    color: defaultTextColor,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                if (showTagline) ...[
                  const SizedBox(height: 2),
                  Text(
                    'AUTO RENTAL',
                    style: TextStyle(
                      fontSize: (height * 0.22).clamp(9.0, 13.0),
                      fontWeight: FontWeight.w800,
                      color: defaultTextColor.withValues(alpha: 0.85),
                      letterSpacing: 2.2,
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _fallbackIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC84C00), Color(0xFFE8590C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'V',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
