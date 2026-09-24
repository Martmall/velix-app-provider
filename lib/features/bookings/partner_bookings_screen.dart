import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class PartnerBookingsScreen extends ConsumerStatefulWidget {
  const PartnerBookingsScreen({super.key});

  @override
  ConsumerState<PartnerBookingsScreen> createState() => _PartnerBookingsScreenState();
}

class _PartnerBookingsScreenState extends ConsumerState<PartnerBookingsScreen> {
  String _selectedTab = 'All';

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
        leading: const VelixBackButton(fallbackRoute: AppRoutes.partnerHome),
        title: Text(
          'Rental Requests & Bookings',
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
          error: (err, _) => _buildBookingsBody([], isDark, cardBg, textColor, subtextColor, borderColor),
          data: (allBookings) => _buildBookingsBody(allBookings, isDark, cardBg, textColor, subtextColor, borderColor),
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

  Widget _buildBookingsBody(List<BookingModel> allBookings, bool isDark, Color cardBg, Color textColor, Color subtextColor, Color borderColor) {
    var bookings = allBookings;
    if (_selectedTab == 'Pending') {
      bookings = bookings.where((b) => b.status == BookingStatus.pending).toList();
    } else if (_selectedTab == 'Active') {
      bookings = bookings.where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.active).toList();
    } else if (_selectedTab == 'Done') {
      bookings = bookings.where((b) => b.status == BookingStatus.completed).toList();
    } else if (_selectedTab == 'Cancelled') {
      bookings = bookings.where((b) => b.status == BookingStatus.cancelled).toList();
    }

    return Column(
      children: [
        // Status Tabs Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabChip('All (${allBookings.length})', 'All', isDark, cardBg, textColor, borderColor),
                const SizedBox(width: 8),
                _buildTabChip('Pending', 'Pending', isDark, cardBg, textColor, borderColor),
                const SizedBox(width: 8),
                _buildTabChip('Active', 'Active', isDark, cardBg, textColor, borderColor),
                const SizedBox(width: 8),
                _buildTabChip('Done', 'Done', isDark, cardBg, textColor, borderColor),
                const SizedBox(width: 8),
                _buildTabChip('Cancelled', 'Cancelled', isDark, cardBg, textColor, borderColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Bookings Request List
        Expanded(
          child: bookings.isEmpty
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
                          child: Icon(Icons.calendar_month_outlined, size: 36, color: subtextColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Bookings Yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When customers reserve your vehicles, rental requests and handover steps will appear here in real time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildBookingCard(bookings[index], isDark, cardBg, textColor, subtextColor, borderColor);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabChip(String label, String value, bool isDark, Color cardBg, Color textColor, Color borderColor) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC84C00) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFC84C00) : borderColor,
          ),
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

  Widget _buildBookingCard(BookingModel item, bool isDark, Color cardBg, Color textColor, Color subtextColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.carImage.isNotEmpty
                      ? item.carImage
                      : CarImageCatalog.getImageForCar(item.carName),
                  width: 64,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 48,
                    color: isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9),
                    child: Center(
                      child: Text(
                        item.userName.isNotEmpty ? item.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.carName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      'Renter: ${item.userName}',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        'Status: ${item.status.name.toUpperCase()}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${item.id}',
                    style: TextStyle(fontSize: 10, color: subtextColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pickup: ${item.pickupLocation}', style: TextStyle(fontSize: 11, color: subtextColor)),
                    Text('Return: ${item.dropoffLocation}', style: TextStyle(fontSize: 11, color: subtextColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Action Triggers Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.verifyPickup1),
                  icon: const Icon(Icons.qr_code_scanner, size: 16, color: Colors.white),
                  label: const Text('Verify Pickup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC84C00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.verifyReturn1),
                  icon: Icon(Icons.task_alt, size: 16, color: textColor),
                  label: Text('Verify Return', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => context.go(AppRoutes.partnerTripUpdates),
              icon: const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFFC84C00)),
              label: const Text('View Active Trip Updates', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
            ),
          ),
        ],
      ),
    );
  }
}
