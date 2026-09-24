import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class PartnerHomeScreen extends ConsumerWidget {
  const PartnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);

    final authState = ref.watch(partnerAuthProvider);
    final fleetAsync = ref.watch(partnerFleetProvider);
    final bookingsAsync = ref.watch(partnerBookingsProvider);

    final vehicles = fleetAsync.when(
      data: (cars) => cars,
      loading: () => <CarModel>[],
      error: (_, __) => <CarModel>[],
    );

    final bookings = bookingsAsync.when(
      data: (b) => b,
      loading: () => <BookingModel>[],
      error: (_, __) => <BookingModel>[],
    );

    final completedBookings = bookings.where((b) => b.status == BookingStatus.completed).toList();
    final totalEarnings = completedBookings.fold<double>(0.0, (sum, item) => sum + (item.totalPrice * 0.85));
    final activeRentals = bookings.where((b) => b.status == BookingStatus.active).length;

    final partnerName = authState.user?.fullName.isNotEmpty == true ? authState.user!.fullName : 'Partner Host';

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: VelixAppHeader(
        title: 'Welcome, $partnerName',
        subtitle: 'Velix Host Portal',
        userName: partnerName,
        userEmail: authState.user?.email ?? 'partner@velix.com',
        avatarUrl: authState.user?.avatarUrl,
        isVerified: authState.user?.isVerified ?? true,
        hasUnreadNotifications: bookings.any((b) => b.status == BookingStatus.pending),
        onNotificationTap: () => context.go(AppRoutes.partnerTripUpdates),
        onProfileTap: () => context.go(AppRoutes.partnerProfile),
        onSupportTap: () => context.go(AppRoutes.supportDisputes),
        onLogout: () async {
          await ref.read(partnerAuthProvider.notifier).signOut();
          if (context.mounted) {
            VelixToast.showSuccess(
              context,
              'Logged out safely. See you soon!',
              title: 'Logged Out',
            );
            context.go(AppRoutes.partnerSignIn);
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Navy Total Earnings Card
            GestureDetector(
              onTap: () => context.go(AppRoutes.earnings),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1830),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0C1830).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Net Earnings', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.earnings),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC84C00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 0,
                          ),
                          child: const Text('Wallet', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₦${totalEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined, size: 12, color: Colors.lightGreenAccent),
                          const SizedBox(width: 4),
                          Text(
                            totalEarnings > 0 ? 'Verified Host Account' : 'New Host Account (₦0 balance)',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions Title
            Text('QUICK ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            // Quick Actions Buttons Row
            Row(
              children: [
                Expanded(child: _buildActionButton(context, Icons.add_circle_outline, 'Add Vehicle', AppRoutes.addVehicle, isDark, textColor)),
                const SizedBox(width: 8),
                Expanded(child: _buildActionButton(context, Icons.qr_code_scanner, 'Verify Pickup', AppRoutes.verifyPickup1, isDark, textColor)),
                const SizedBox(width: 8),
                Expanded(child: _buildActionButton(context, Icons.task_alt, 'Verify Return', AppRoutes.verifyReturn1, isDark, textColor)),
                const SizedBox(width: 8),
                Expanded(child: _buildActionButton(context, Icons.support_agent, 'Support', AppRoutes.supportDisputes, isDark, textColor)),
              ],
            ),
            const SizedBox(height: 24),
            // 2x2 Metrics Grid
            Text('FLEET PERFORMANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Total Revenue', '₦${totalEarnings.toStringAsFixed(0)}', totalEarnings > 0 ? 'Active' : 'No revenue yet', totalEarnings > 0, cardBg, textColor, subtextColor, borderColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Listed Fleet', '${vehicles.length} Vehicles', vehicles.isNotEmpty ? 'Live on catalog' : 'No cars added', vehicles.isNotEmpty, cardBg, textColor, subtextColor, borderColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Active Rentals', '$activeRentals', activeRentals > 0 ? 'On the road' : 'None active', activeRentals > 0, cardBg, textColor, subtextColor, borderColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Total Orders', '${bookings.length}', bookings.isNotEmpty ? 'Lifetime' : 'Zero orders', bookings.isNotEmpty, cardBg, textColor, subtextColor, borderColor)),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RECENT RENTALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.partnerBookings),
                  child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Icon(Icons.directions_car_outlined, size: 36, color: subtextColor),
                    const SizedBox(height: 8),
                    Text(
                      'No bookings received yet',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload your vehicle photos and details to start receiving customer rentals.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.addVehicle),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text('Add First Vehicle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC84C00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...bookings.take(5).map((booking) {
                final statusColor = booking.status == BookingStatus.active
                    ? const Color(0xFF10B981)
                    : (booking.status == BookingStatus.pending ? const Color(0xFFF59E0B) : const Color(0xFF6B7280));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _buildActivityItem(
                    context,
                    booking.customerName,
                    booking.carName,
                    '₦${booking.totalPrice.toStringAsFixed(0)}',
                    booking.status.name.toUpperCase(),
                    statusColor,
                    cardBg,
                    textColor,
                    subtextColor,
                    borderColor,
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        isPartner: true,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.partnerHome);
              break;
            case 1:
              context.go(AppRoutes.myVehicles);
              break;
            case 2:
              context.go(AppRoutes.partnerBookings);
              break;
            case 3:
              context.go(AppRoutes.earnings);
              break;
            case 4:
              context.go(AppRoutes.partnerProfile);
              break;
          }
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, String route, bool isDark, Color textColor) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC84C00).withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFC84C00), size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String sub, bool isPositive, Color cardBg, Color textColor, Color subtextColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: subtextColor)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPositive ? const Color(0xFF10B981) : subtextColor)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String name,
    String car,
    String price,
    String status,
    Color statusColor,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.partnerTripUpdates),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                Text(car, style: TextStyle(fontSize: 11, color: subtextColor)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
