import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class VerifyPickup1Screen extends ConsumerWidget {
  const VerifyPickup1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final innerBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6);

    final bookingsAsync = ref.watch(partnerBookingsProvider);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 16),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.partnerBookings);
            }
          },
        ),
        title: Text(
          'Pickup Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.brightness_2_outlined, color: textColor),
            onPressed: () {
              ref.read(appThemeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: textColor),
                onPressed: () => context.go(AppRoutes.partnerTripUpdates),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFC84C00), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D1E16) : const Color(0xFFFDF0E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCD34D).withValues(alpha: isDark ? 0.3 : 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF422616) : const Color(0xFFFDE68A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time_filled, color: Color(0xFFC84C00), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Verification',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select a customer pickup below to verify with their 6-digit OTP code',
                          style: TextStyle(fontSize: 12, color: subtextColor, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            bookingsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFFC84C00)),
                ),
              ),
              error: (_, __) => _buildEmptyState(context, cardBg, borderColor, textColor, subtextColor, isDark),
              data: (bookings) {
                final pendingPickups = bookings
                    .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.pending)
                    .toList();

                if (pendingPickups.isEmpty) {
                  return _buildEmptyState(context, cardBg, borderColor, textColor, subtextColor, isDark);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pending Pickups',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D1E16) : const Color(0xFFFDF0E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCD34D).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '${pendingPickups.length} Pending',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...pendingPickups.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildPickupCard(
                            context: context,
                            booking: b,
                            cardBg: cardBg,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            borderColor: borderColor,
                            innerBg: innerBg,
                          ),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
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

  Widget _buildEmptyState(BuildContext context, Color cardBg, Color borderColor, Color textColor, Color subtextColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.car_rental_outlined, size: 40, color: Color(0xFFC84C00)),
          ),
          const SizedBox(height: 16),
          Text(
            'No Pending Pickups',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'When customers make new bookings and arrive for vehicle pickup, they will appear here with an OTP verification action.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: subtextColor, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.partnerBookings),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC84C00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'View All Bookings',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard({
    required BuildContext context,
    required BookingModel booking,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required Color innerBg,
  }) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.verifyPickup2, extra: booking),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    booking.carImage.isNotEmpty ? booking.carImage : CarImageCatalog.toyotaCamry,
                    width: 50,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 40,
                      color: innerBg,
                      child: const Icon(Icons.directions_car, color: Color(0xFFC84C00)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.userName.isNotEmpty ? booking.userName : 'Customer',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        booking.carName,
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: innerBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(
                        booking.id,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios, size: 10, color: subtextColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: subtextColor),
                const SizedBox(width: 4),
                Text(
                  '${booking.startDate.day}/${booking.startDate.month}/${booking.startDate.year}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 14, color: subtextColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.pickupLocation.isNotEmpty ? booking.pickupLocation : 'Lagos Hub',
                    style: TextStyle(fontSize: 12, color: subtextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
