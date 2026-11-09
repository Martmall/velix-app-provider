import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';
import '../../providers/partner_app_providers.dart';

class BankAccountSheet extends ConsumerStatefulWidget {
  const BankAccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BankAccountSheet(),
    );
  }

  @override
  ConsumerState<BankAccountSheet> createState() => _BankAccountSheetState();
}

class _BankAccountSheetState extends ConsumerState<BankAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  String _selectedBank = 'First Bank of Nigeria';
  late TextEditingController _accountNumberController;
  
  late final TextEditingController _accountNameController;
  bool _isSaving = false;

  // Bank -> CBN/NIBSS bank code, as Flutterwave's transfer API expects. Confirm against
  // Flutterwave's GET /banks/NG before relying on payouts for a new bank.
  static const Map<String, String> _bankCodes = {
    'First Bank of Nigeria': '011',
    'Guaranty Trust Bank (GTBank)': '058',
    'Access Bank': '044',
    'Zenith Bank': '057',
    'United Bank for Africa (UBA)': '033',
    'Kuda Microfinance Bank': '50211',
    'OPay Digital Services': '999992',
    'Moniepoint MFB': '50515',
    'Providus Bank': '101',
    'Stanbic IBTC Bank': '221',
    'Sterling Bank': '232',
    'Fidelity Bank': '070',
    'First City Monument Bank (FCMB)': '214',
    'Wema Bank (ALAT)': '035',
  };
  List<String> get _banks => _bankCodes.keys.toList();

  @override
  void initState() {
    super.initState();
    final user = ref.read(partnerAuthProvider).user;
    final savedBank = user?.bankName;
    _selectedBank = savedBank != null && _bankCodes.containsKey(savedBank) ? savedBank : _banks.first;
    _accountNumberController = TextEditingController(text: user?.accountNumber ?? '');
    _accountNameController = TextEditingController(text: user?.accountName ?? '');
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  /// Saves the payout account on the server (PATCH /provider/bank-details). There is no
  /// account-name lookup (NIBSS name enquiry) in the backend, so the holder name is typed in.
  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final ok = await ref.read(partnerAuthProvider.notifier).updateBankDetails(
          bankName: _selectedBank,
          bankCode: _bankCodes[_selectedBank]!,
          accountNumber: _accountNumberController.text.trim(),
          accountName: _accountNameController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.pop(context);
      VelixToast.showSuccess(context, 'Payout account saved: $_selectedBank');
    } else {
      VelixToast.showError(context, ref.read(partnerAuthProvider).error ?? 'Could not save the bank account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF9FAFB);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.account_balance, color: Color(0xFF10B981), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Bank Account Setup',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Add the bank account your withdrawals are paid into.',
                  style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                // Bank Selector
                Text('Select Bank', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBank,
                      isExpanded: true,
                      dropdownColor: cardBg,
                      style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w500),
                      items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBank = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Account Number Input
                Text('Account Number (10 digits)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'e.g. 0123456789',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: inputBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Account number is required';
                    if (val.trim().length != 10) return 'Must be exactly 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text('Account Holder Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountNameController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Exactly as on your bank account',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (val) => (val == null || val.trim().length < 3) ? 'Enter the account holder name' : null,
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveBankAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC84C00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Save Bank Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
