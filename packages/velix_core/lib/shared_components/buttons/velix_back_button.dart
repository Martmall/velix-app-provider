import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:velix_core/theme/velix_palette.dart';
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
    final buttonBg = isDark ? VelixPalette.nightPaper : VelixPalette.paper;
    final borderColor = isDark ? VelixPalette.nightLine : VelixPalette.line;
    final iconColor = color ?? (isDark ? VelixPalette.paper : VelixPalette.ink);

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
