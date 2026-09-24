import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class VerifyReturn1Screen extends ConsumerWidget {
  const VerifyReturn1Screen({super.key});

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
          'Return Verification',
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
            // Soft Light Blue Notice Card Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time_filled, color: Color(0xFF2563EB), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Return Verification',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select an active vehicle rental to verify odometer, inspection & complete return',
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
                final activeRentals = bookings
                    .where((b) => b.status == BookingStatus.active || b.status == BookingStatus.confirmed)
                    .toList();

                if (activeRentals.isEmpty) {
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
                          'Active Rentals',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            '${activeRentals.length} Active',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...activeRentals.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildActiveRentalCard(
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
            child: const Icon(Icons.assignment_turned_in_outlined, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Rentals to Return',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Active vehicle rentals that are out with customers will appear here when ready for drop-off and return verification.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: subtextColor, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.partnerBookings),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
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

  Widget _buildActiveRentalCard({
    required BuildContext context,
    required BookingModel booking,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required Color innerBg,
  }) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.verifyReturn2, extra: booking),
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
                      child: const Icon(Icons.directions_car, color: Color(0xFF2563EB)),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event, size: 14, color: subtextColor),
                    const SizedBox(width: 4),
                    Text(
                      'Return: ${booking.endDate.day}/${booking.endDate.month}/${booking.endDate.year}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'Verify Return',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF2563EB)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
