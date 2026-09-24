import 'package:flutter/material.dart';

enum VelixToastType { success, error, info, warning }

class VelixToast {
  static void showSuccess(BuildContext context, String message, {String? title}) {
    show(
      context,
      message: message,
      title: title ?? 'Success',
      type: VelixToastType.success,
    );
  }

  static void showError(BuildContext context, String message, {String? title}) {
    show(
      context,
      message: message,
      title: title ?? 'Error',
      type: VelixToastType.error,
    );
  }

  static void showInfo(BuildContext context, String message, {String? title}) {
    show(
      context,
      message: message,
      title: title ?? 'Notice',
      type: VelixToastType.info,
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    required String title,
    VelixToastType type = VelixToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _VelixToastWidget(
        title: title,
        message: message,
        type: type,
        onDismissed: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _VelixToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final VelixToastType type;
  final VoidCallback onDismissed;

  const _VelixToastWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_VelixToastWidget> createState() => _VelixToastWidgetState();
}

class _VelixToastWidgetState extends State<_VelixToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getIconColor() {
    switch (widget.type) {
      case VelixToastType.success:
        return const Color(0xFF10B981); // Emerald
      case VelixToastType.error:
        return const Color(0xFFEF4444); // Crimson
      case VelixToastType.warning:
        return const Color(0xFFF59E0B); // Amber
      case VelixToastType.info:
        return const Color(0xFFC84C00); // Velix Orange
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case VelixToastType.success:
        return Icons.check_circle_rounded;
      case VelixToastType.error:
        return Icons.error_rounded;
      case VelixToastType.warning:
        return Icons.warning_rounded;
      case VelixToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161922) : const Color(0xFF0C1830);
    final iconColor = _getIconColor();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 14,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getIcon(),
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onDismissed,
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
