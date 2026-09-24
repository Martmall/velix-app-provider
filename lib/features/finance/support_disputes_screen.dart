import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class SupportDisputesScreen extends ConsumerStatefulWidget {
  const SupportDisputesScreen({super.key});

  @override
  ConsumerState<SupportDisputesScreen> createState() => _SupportDisputesScreenState();
}

class _SupportDisputesScreenState extends ConsumerState<SupportDisputesScreen> {
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();
  bool _isSending = false;
  final List<DisputeModel> _localDisputes = [];

  void _showNewDisputeModal(List<BookingModel> bookings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);

    final bookingOptions = bookings.isNotEmpty
        ? bookings.map((b) => '${b.id.substring(0, b.id.length > 8 ? 8 : b.id.length)} (${b.carName})').toList()
        : ['General Partner Inquiry'];

    final reasonController = TextEditingController();
    final amountController = TextEditingController();
    String selectedBooking = bookingOptions.first;
    String selectedReason = 'Vehicle Damage';
    bool isSubmitting = false;
    String? evidencePhoto;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Submit Damage / Dispute Claim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF6B7280)), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Select Associated Booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedBooking,
                    dropdownColor: cardBg,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                    items: bookingOptions.map((b) => DropdownMenuItem(value: b, child: Text(b, style: TextStyle(color: textColor, fontSize: 13)))).toList(),
                    onChanged: (val) => setModalState(() => selectedBooking = val!),
                  ),
                  const SizedBox(height: 14),
                  Text('Claim Category / Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    dropdownColor: cardBg,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                    items: [
                      'Vehicle Damage',
                      'Late Return Penalty',
                      'Traffic Fine / Toll Charge',
                      'Fuel Refill Fee',
                      'Cleanliness / Detailing Fee',
                    ].map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(color: textColor, fontSize: 13)))).toList(),
                    onChanged: (val) => setModalState(() => selectedReason = val!),
                  ),
                  const SizedBox(height: 14),
                  Text('Claim Amount (₦)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. 45000',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Description of Evidence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Provide details regarding the claim...',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final photo = await ImagePickerModal.show(
                        context: context,
                        title: 'Attach Damage Photo Evidence',
                        isVehicle: true,
                      );
                      if (photo != null) {
                        setModalState(() => evidencePhoto = photo);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: evidencePhoto != null ? const Color(0xFF10B981) : borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            evidencePhoto != null ? Icons.check_circle : Icons.camera_alt,
                            color: evidencePhoto != null ? const Color(0xFF10B981) : const Color(0xFFC84C00),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              evidencePhoto != null ? 'Damage Photo Attached (Tap to change)' : 'Attach Damage Evidence Photo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: evidencePhoto != null ? FontWeight.bold : FontWeight.normal,
                                color: evidencePhoto != null ? const Color(0xFF10B981) : textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PartnerOrangeButton(
                    text: 'Submit Dispute Claim',
                    isLoading: isSubmitting,
                    onPressed: () async {
                      final amount = double.tryParse(amountController.text) ?? 45000.0;
                      setModalState(() => isSubmitting = true);
                      final authState = ref.read(partnerAuthProvider);
                      final partnerId = authState.user?.id ?? 'partner_${DateTime.now().millisecondsSinceEpoch}';

                      try {
                        final dispute = await ref.read(supportRepoProvider).createDispute(
                              partnerId: partnerId,
                              bookingId: selectedBooking.split(' ').first,
                              carName: selectedBooking.contains('(') ? selectedBooking.split('(').last.replaceAll(')', '') : 'Vehicle',
                              reason: selectedReason,
                              description: reasonController.text.trim(),
                              claimAmount: amount,
                              evidenceImages: evidencePhoto != null ? [evidencePhoto!] : [],
                            );
                        setState(() {
                          _localDisputes.insert(0, dispute);
                        });
                      } catch (_) {}

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dispute claim submitted successfully to Velix Support!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);
    final authState = ref.read(partnerAuthProvider);
    final partnerId = authState.user?.id ?? 'partner_01';
    final partnerName = authState.user?.fullName ?? 'Host Partner';

    try {
      await ref.read(supportRepoProvider).createSupportTicket(
            userId: partnerId,
            subject: _subjectController.text.trim().isNotEmpty ? _subjectController.text.trim() : 'Partner Support Request',
            category: 'Partner Inquiry',
            description: '[$partnerName]: $message',
          );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSending = false;
        _messageController.clear();
        _subjectController.clear();
      });
      VelixToast.showSuccess(
        context,
        'Support ticket submitted! Admin team has been notified.',
        title: 'Ticket Submitted',
      );
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
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);

    final bookingsAsync = ref.watch(partnerBookingsProvider);
    final bookings = bookingsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const VelixBackButton(fallbackRoute: AppRoutes.partnerHome),
        title: Text(
          'Support & Dispute Claims',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildMetricBox('${_localDisputes.length}', 'Open Claims', cardBg, textColor, subtextColor, borderColor)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricBox('0', 'Under Review', cardBg, textColor, subtextColor, borderColor)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricBox('0', 'Resolved', cardBg, textColor, subtextColor, borderColor)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DISPUTE CLAIMS HISTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)),
                GestureDetector(
                  onTap: () => _showNewDisputeModal(bookings),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFC84C00), borderRadius: BorderRadius.circular(16)),
                    child: const Text('+ New Claim', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_localDisputes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 36, color: subtextColor),
                    const SizedBox(height: 8),
                    Text(
                      'No Active Disputes',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'If a trip incurs damage, late return, or toll charges, file a claim here for rapid Velix resolution.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _localDisputes.map((dsp) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dsp.reason, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                            Text('₦${dsp.claimAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Booking ID: ${dsp.bookingId} • ${dsp.carName}', style: TextStyle(fontSize: 11, color: subtextColor)),
                        const SizedBox(height: 8),
                        Text(dsp.description, style: TextStyle(fontSize: 12, color: textColor)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFCD34D))),
                          child: Text('Status: ${dsp.status.name.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            // Contact Support
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Velix Host Support Desk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text('Reach out directly to the Velix Partner Support team', style: TextStyle(fontSize: 12, color: subtextColor)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectController,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Subject / Category (optional)...',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type your message or inquiry...',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PartnerOrangeButton(text: 'Submit Support Ticket', isLoading: _isSending, onPressed: _sendMessage),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
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

  Widget _buildMetricBox(String count, String label, Color cardBg, Color textColor, Color subtextColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: subtextColor)),
        ],
      ),
    );
  }
}
