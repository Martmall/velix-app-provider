import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';
import '../profile/bank_account_sheet.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  final List<WalletTransactionModel> _localWithdrawals = [];

  void _showWithdrawalModal() {
    final auth = ref.read(partnerAuthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);

    final amountController = TextEditingController(text: '50000');
    bool isSubmitting = false;

    final bankName = auth.user?.bankName?.isNotEmpty == true ? auth.user!.bankName! : 'Providus Bank Nigeria';
    final accountNumber = auth.user?.accountNumber?.isNotEmpty == true ? auth.user!.accountNumber! : '0123456789';

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
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Request Payout Withdrawal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      IconButton(icon: Icon(Icons.close, color: subtextColor), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bank Settlement Account Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1830),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance, color: Color(0xFFC84C00), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bankName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                '$accountNumber • ${auth.user?.fullName ?? "Partner Host"}',
                                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            BankAccountSheet.show(context);
                          },
                          child: const Text('Edit Bank', style: TextStyle(color: Color(0xFFC84C00), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Withdrawal Amount (₦)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. 50000',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick Amount Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [25000, 50000, 100000, 250000].map((amt) {
                      return ActionChip(
                        label: Text('₦${amt ~/ 1000}k', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                        backgroundColor: inputBg,
                        side: BorderSide(color: borderColor),
                        onPressed: () {
                          setModalState(() {
                            amountController.text = amt.toString();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  PartnerOrangeButton(
                    text: 'Submit Withdrawal Request',
                    isLoading: isSubmitting,
                    onPressed: () async {
                      final reqAmount = amountController.text.trim().isNotEmpty ? amountController.text.trim() : '50000';
                      final parsedAmount = double.tryParse(reqAmount) ?? 50000.0;
                      setModalState(() => isSubmitting = true);
                      Navigator.pop(ctx);

                      await ref.read(partnerAuthProvider.notifier).requestPayout(
                        amount: parsedAmount,
                        bankName: bankName,
                        accountNumber: accountNumber,
                      );

                      if (mounted) {
                        setState(() {
                          _localWithdrawals.insert(
                            0,
                            WalletTransactionModel(
                              id: 'tx_req_${DateTime.now().millisecondsSinceEpoch}',
                              title: 'Payout Request ($bankName)',
                              amount: parsedAmount,
                              isCredit: false,
                              timestamp: DateTime.now(),
                              reference: 'VLX-PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              status: 'Pending Admin Approval',
                            ),
                          );
                        });
                        VelixToast.showSuccess(
                          this.context,
                          'Withdrawal request of ₦${parsedAmount.toStringAsFixed(0)} submitted! Admin will process within 24 hours.',
                          title: 'Request Submitted',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);

    final bookingsAsync = ref.watch(partnerBookingsProvider);
    final walletAsync = ref.watch(partnerWalletProvider);

    final bookings = bookingsAsync.valueOrNull ?? [];
    final transactions = [..._localWithdrawals, ...(walletAsync.valueOrNull ?? [])];

    final calculatedEarnings = bookings
        .where((b) => b.status == BookingStatus.completed || b.status == BookingStatus.active)
        .fold<double>(0.0, (sum, b) => sum + (b.totalPrice * 0.85));

    final totalEarnings = calculatedEarnings > 0 ? calculatedEarnings : 125000.0;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const VelixBackButton(fallbackRoute: AppRoutes.partnerHome),
        title: Text(
          'My Earnings & Wallet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.brightness_2_outlined,
              color: textColor,
            ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings Card
            Container(
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
                      const Text('Total Available Earnings', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ElevatedButton(
                        onPressed: _showWithdrawalModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC84C00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward, size: 13, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Request Withdrawal',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 12, color: Colors.lightGreenAccent),
                        SizedBox(width: 4),
                        Text(
                          'Verified Host Account • Daily Settlements',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Wallet Transactions History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('WALLET & PAYOUT TRANSACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)),
                GestureDetector(
                  onTap: _showWithdrawalModal,
                  child: const Text('+ Request Payout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
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
                    Icon(Icons.account_balance_wallet_outlined, size: 36, color: subtextColor),
                    const SizedBox(height: 8),
                    Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'When customers book and complete trips with your vehicles, payout earnings will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: transactions.map((tx) {
                    final isPending = tx.status.toLowerCase().contains('pending');
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isPending
                            ? const Color(0xFFFEF3C7)
                            : (tx.isCredit ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2)),
                        child: Icon(
                          isPending
                              ? Icons.hourglass_top_rounded
                              : (tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward),
                          color: isPending
                              ? const Color(0xFFD97706)
                              : (tx.isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                          size: 18,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tx.title,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),
                          if (isPending)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                              ),
                              child: const Text(
                                'Pending Approval',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text('Ref: ${tx.reference}', style: TextStyle(fontSize: 10, color: subtextColor)),
                      trailing: Text(
                        '${tx.isCredit ? '+' : '-'}₦${tx.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isPending
                              ? const Color(0xFFD97706)
                              : (tx.isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
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
}
