import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class VerifyReturn2Screen extends ConsumerStatefulWidget {
  final BookingModel? booking;

  const VerifyReturn2Screen({super.key, this.booking});

  @override
  ConsumerState<VerifyReturn2Screen> createState() => _VerifyReturn2ScreenState();
}

class _VerifyReturn2ScreenState extends ConsumerState<VerifyReturn2Screen> {
  bool _isLoading = false;
  bool _noDamage = true;
  bool _fuelOk = true;

  void _confirmReturn(BookingModel? currentBooking) async {
    setState(() => _isLoading = true);
    if (currentBooking != null) {
      await ref.read(bookingRepoProvider).updateBookingStatus(currentBooking.id, BookingStatus.completed);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Return completed for ${currentBooking?.userName ?? "Customer"}! Payment released to your earnings.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      context.go(AppRoutes.earnings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final innerBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6);

    final allBookings = ref.watch(partnerBookingsProvider).value ?? [];
    final booking = widget.booking ?? allBookings.where((b) => b.status == BookingStatus.active || b.status == BookingStatus.confirmed).firstOrNull;

    final customerName = booking?.userName.isNotEmpty == true ? booking!.userName : 'Customer';
    final vehicleName = booking?.carName.isNotEmpty == true ? booking!.carName : 'Selected Vehicle';
    final refCode = booking?.id ?? 'VR-LIVE-002';
    final carImg = booking?.carImage.isNotEmpty == true ? booking!.carImage : CarImageCatalog.mercedesGLE;
    final returnDate = booking != null ? '${booking.endDate.day}/${booking.endDate.month}/${booking.endDate.year}' : 'Today';

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
              context.go(AppRoutes.verifyReturn1);
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
          children: [
            // Selected Rental Card Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          carImg,
                          width: 55,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFDBEAFE),
                            child: Text(
                              customerName.isNotEmpty ? customerName[0] : 'C',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
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
                              customerName,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Text(
                              vehicleName,
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
                        child: Text(
                          refCode,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildDetailTile('Return Scheduled', returnDate, innerBg, textColor, subtextColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle Inspection Checklist Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fact_check_outlined, color: Color(0xFF2563EB), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Return Inspection',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('No New Physical Damage', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    subtitle: Text('Exterior and interior are in good condition', style: TextStyle(fontSize: 11, color: subtextColor)),
                    value: _noDamage,
                    activeThumbColor: const Color(0xFF10B981),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _noDamage = v),
                  ),
                  const Divider(height: 16),
                  SwitchListTile(
                    title: Text('Fuel Level Checked & OK', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    subtitle: Text('Fuel gauge matches dispatch level', style: TextStyle(fontSize: 11, color: subtextColor)),
                    value: _fuelOk,
                    activeThumbColor: const Color(0xFF10B981),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _fuelOk = v),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _confirmReturn(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Complete Return & Close Rental',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildDetailTile(String label, String value, Color innerBg, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: innerBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: subtextColor)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
