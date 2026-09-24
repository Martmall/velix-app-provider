import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class PartnerTripUpdatesScreen extends ConsumerStatefulWidget {
  const PartnerTripUpdatesScreen({super.key});

  @override
  ConsumerState<PartnerTripUpdatesScreen> createState() => _PartnerTripUpdatesScreenState();
}

class _PartnerTripUpdatesScreenState extends ConsumerState<PartnerTripUpdatesScreen> {
  String _selectedFilter = 'All Trips';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);

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
          'Trip Updates & Alerts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.brightness_2_outlined, color: textColor),
            onPressed: () {
              ref.read(appThemeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFC84C00))),
          error: (_, __) => _buildTripUpdatesContent([], isDark, cardBg, textColor, subtextColor, borderColor),
          data: (bookings) => _buildTripUpdatesContent(bookings, isDark, cardBg, textColor, subtextColor, borderColor),
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

  Widget _buildTripUpdatesContent(List<BookingModel> bookings, bool isDark, Color cardBg, Color textColor, Color subtextColor, Color borderColor) {
    final activeTrips = bookings.where((b) => b.status == BookingStatus.active || b.status == BookingStatus.confirmed).toList();

    return Column(
      children: [
        // Filter Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              _buildFilterChip('All Updates', isDark, cardBg, textColor, borderColor),
              const SizedBox(width: 8),
              _buildFilterChip('Active Trips (${activeTrips.length})', isDark, cardBg, textColor, borderColor),
            ],
          ),
        ),
        Expanded(
          child: activeTrips.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_none, size: 36, color: subtextColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Trip Updates Yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Real-time alerts, telematics status, extension requests, and trip completion updates will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: activeTrips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final trip = activeTrips[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                trip.carName,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('ONGOING TRIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Renter: ${trip.userName} | Pickup: ${trip.pickupLocation}', style: TextStyle(fontSize: 12, color: subtextColor)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.go(AppRoutes.verifyReturn1),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC84C00),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Initiate Return Inspection', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isDark, Color cardBg, Color textColor, Color borderColor) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC84C00) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFC84C00) : borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF374151)),
          ),
        ),
      ),
    );
  }
}
