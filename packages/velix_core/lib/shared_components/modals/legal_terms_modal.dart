import 'package:flutter/material.dart';

class LegalTermsModal extends StatelessWidget {
  final String title;
  final String content;

  const LegalTermsModal({
    super.key,
    required this.title,
    required this.content,
  });

  static Future<void> showTermsOfService(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LegalTermsModal(
        title: 'Velix Terms of Service',
        content: '''
Welcome to Velix Car Rental & Fleet Mobility Platform ("Velix"). By registering an account, making a vehicle reservation, or listing a vehicle as a partner host, you agree to comply with and be bound by the following Terms of Service.

1. ACCEPTANCE OF TERMS
By accessing or using the Velix application, backend services, or website, you confirm that you are at least 21 years of age, hold a valid driver's license, and agree to these terms in full.

2. VEHICLE RESERVATIONS & PAYMENTS
- Rental fees are calculated based on daily rates, optional add-ons (chauffeur, child seat), and applicable security deposits.
- Payment must be completed via Velix Digital Wallet, debit/credit card, or verified bank transfer prior to vehicle handover.
- Cancellation requests made more than 24 hours prior to pickup are eligible for a full refund to your Velix Digital Wallet.

3. USER RESPONSIBILITIES & VEHICLE USE
- Renters must inspect the vehicle at pickup and report existing damages during handover verification.
- Vehicles must be operated in accordance with Nigerian traffic laws. Driving under the influence of alcohol or drugs is strictly prohibited.
- Sub-leasing or unauthorized driver handovers are forbidden.

4. PARTNER HOST OBLIGATIONS
- Partner hosts warrant that listed vehicles are mechanically sound, insured, and possess valid roadworthiness documentation.
- Velix reserves the right to review, approve, or deactivate vehicle listings based on compliance and user feedback.

5. DISPUTES & LIABILITY
- Velix acts as a venue connecting renters and partner hosts. In case of vehicle damage, claims must be logged through the Support & Disputes portal with photo evidence within 24 hours of return.

6. GOVERNING LAW
These Terms shall be governed by and construed under the laws of the Federal Republic of Nigeria.
''',
      ),
    );
  }

  static Future<void> showPrivacyPolicy(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LegalTermsModal(
        title: 'Velix Privacy Policy',
        content: '''
Your privacy is important to Velix. This Privacy Policy describes how we collect, use, store, and protect your personal data when you use the Velix Mobile Applications and Services.

1. INFORMATION WE COLLECT
- Personal Identification: Full name, email address, phone number, government ID/driver's license details.
- Vehicle & Host Data: Vehicle documentation, registration numbers, payout bank details.
- Location & Device Data: GPS data for vehicle pickup/dropoff validation and keyless remote access functionality.

2. HOW WE USE YOUR DATA
- To process vehicle bookings, payments, and host earnings payouts.
- To verify identity, perform driver license validation, and prevent fraudulent activity.
- To provide keyless vehicle access and real-time trip status tracking.
- To communicate critical booking updates and customer support responses.

3. DATA PROTECTION & SECURITY
- All sensitive authentication data and tokens are stored securely using hardware-backed storage (`FlutterSecureStorage`).
- API communications are encrypted using 256-bit SSL/TLS protocol.
- Database access is protected with strict Row Level Security (RLS) policies.

4. DATA SHARING
- We do not sell your personal information. Relevant rental details are shared only between the booking customer and the vehicle partner host to facilitate pickup and return inspections.

5. YOUR RIGHTS
You have the right to request access to your stored personal data, request corrections, or request account erasure by contacting privacy@velix.ng or logging a ticket in Help & Support.
''',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Modal Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Legal Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: subtextColor,
                  ),
                ),
              ),
            ),
          ),
          // Bottom Accept Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC84C00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'I Understand & Accept',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
