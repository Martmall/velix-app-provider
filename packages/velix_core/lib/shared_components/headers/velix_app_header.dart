import 'package:flutter/material.dart';

class VelixAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String? userName;
  final String? userEmail;
  final String? avatarUrl;
  final bool isVerified;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onLogout;
  final Widget? leading;

  const VelixAppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.userName,
    this.userEmail,
    this.avatarUrl,
    this.isVerified = true,
    this.hasUnreadNotifications = false,
    this.onNotificationTap,
    this.onProfileTap,
    this.onSupportTap,
    this.onThemeToggle,
    this.onLogoutTap,
    this.onLogout,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF11141D) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF262C38) : const Color(0xFFE2E8F0);
    const accentOrange = Color(0xFFC84C00);

    final displayName = (userName != null && userName!.isNotEmpty) ? userName! : 'Velix Member';
    final initials = displayName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ] else ...[
            // Velix Brand Logo Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: accentOrange.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'packages/velix_core/assets/logos/velix_icon.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/velix_icon.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
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
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textColor,
                size: 20,
              ),
              tooltip: 'Toggle Theme',
              onPressed: onThemeToggle,
            ),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: textColor,
                  size: 22,
                ),
                onPressed: onNotificationTap,
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: accentOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
          // Profile Avatar with Dropdown Popup Menu
          PopupMenuButton<String>(
            tooltip: 'Account Menu',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 1.2),
            ),
            color: headerBg,
            elevation: 8,
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  onProfileTap?.call();
                  break;
                case 'support':
                  onSupportTap?.call();
                  break;
                case 'theme':
                  onThemeToggle?.call();
                  break;
                case 'logout':
                  (onLogoutTap ?? onLogout)?.call();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              // User Details Card in Dropdown
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: accentOrange,
                          backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                              ? NetworkImage(avatarUrl!)
                              : null,
                          child: (avatarUrl == null || avatarUrl!.isEmpty)
                              ? Text(
                                  initials.isNotEmpty ? initials : 'U',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                userEmail ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 10, color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                        if (isVerified)
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: borderColor, height: 1),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 18, color: textColor),
                    const SizedBox(width: 12),
                    Text('My Profile', style: TextStyle(fontSize: 13, color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'support',
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded, size: 18, color: textColor),
                    const SizedBox(width: 12),
                    Text('Help & Support', style: TextStyle(fontSize: 13, color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      size: 18,
                      color: textColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                enabled: false,
                height: 8,
                child: Divider(color: borderColor, height: 1),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 12),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentOrange.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: accentOrange,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Text(
                        initials.isNotEmpty ? initials : 'U',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
