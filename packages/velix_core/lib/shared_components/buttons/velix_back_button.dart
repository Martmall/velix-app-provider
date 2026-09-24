import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VelixBackButton extends StatelessWidget {
  final String? fallbackRoute;
  final VoidCallback? onPressed;
  final Color? color;

  const VelixBackButton({
    super.key,
    this.fallbackRoute,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg = isDark ? const Color(0xFF161922) : Colors.white;
    final borderColor = isDark ? const Color(0xFF262C38) : const Color(0xFFE2E8F0);
    final iconColor = color ?? (isDark ? Colors.white : const Color(0xFF0C1830));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ??
              () {
                if (context.canPop()) {
                  context.pop();
                } else if (fallbackRoute != null && fallbackRoute!.isNotEmpty) {
                  context.go(fallbackRoute!);
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: buttonBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
