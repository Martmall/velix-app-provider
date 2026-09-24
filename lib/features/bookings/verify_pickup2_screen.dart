import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class VerifyPickup2Screen extends ConsumerStatefulWidget {
  final BookingModel? booking;

  const VerifyPickup2Screen({super.key, this.booking});

  @override
  ConsumerState<VerifyPickup2Screen> createState() => _VerifyPickup2ScreenState();
}

class _VerifyPickup2ScreenState extends ConsumerState<VerifyPickup2Screen> {
  final List<TextEditingController> _pinControllers = List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pinControllers[0].text = '1';
  }

  @override
  void dispose() {
    for (final c in _pinControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _verifyCode(BookingModel? currentBooking) async {
    setState(() => _isLoading = true);
    if (currentBooking != null) {
      await ref.read(bookingRepoProvider).updateBookingStatus(currentBooking.id, BookingStatus.active);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pickup verified successfully for ${currentBooking?.userName ?? "Customer"}! Rental is now active.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      context.go(AppRoutes.partnerTripUpdates);
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
    final booking = widget.booking ?? allBookings.where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.pending).firstOrNull;

    final customerName = booking?.userName.isNotEmpty == true ? booking!.userName : 'Customer';
    final vehicleName = booking?.carName.isNotEmpty == true ? booking!.carName : 'Selected Vehicle';
    final refCode = booking?.id ?? 'VR-LIVE-001';
    final location = booking?.pickupLocation.isNotEmpty == true ? booking!.pickupLocation : 'Victoria Island Hub, Lagos';
    final carImg = booking?.carImage.isNotEmpty == true ? booking!.carImage : CarImageCatalog.toyotaCamry;

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
              context.go(AppRoutes.verifyPickup1);
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
          children: [
            // Selected Customer Summary Card
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
                            backgroundColor: const Color(0xFFFCE7F3),
                            child: Text(
                              customerName.isNotEmpty ? customerName[0] : 'C',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDB2777)),
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
                      Expanded(child: _buildDetailTile('Location', location, innerBg, textColor, subtextColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // OTP Input Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC84C00).withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pin_outlined, color: Color(0xFFC84C00), size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter Customer OTP',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask $customerName for the 6-digit pickup verification code displayed in their Velix app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: subtextColor, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // 6 Digit PIN Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 44,
                        height: 52,
                        child: TextFormField(
                          controller: _pinControllers[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: innerBg,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 2)),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              FocusScope.of(context).nextFocus();
                            } else if (val.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  PartnerOrangeButton(
                    text: 'Confirm & Hand Over Vehicle',
                    isLoading: _isLoading,
                    onPressed: () => _verifyCode(booking),
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
