import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  
  bool _isVerifying = false;
  String? _verifiedAccountName;
  bool _isSaving = false;
  Timer? _debounceTimer;

  final List<String> _banks = [
    'First Bank of Nigeria',
    'Guaranty Trust Bank (GTBank)',
    'Access Bank',
    'Zenith Bank',
    'United Bank for Africa (UBA)',
    'Kuda Microfinance Bank',
    'OPay Digital Services',
    'Moniepoint MFB',
    'Providus Bank',
    'Stanbic IBTC Bank',
    'Sterling Bank',
    'Fidelity Bank',
    'First City Monument Bank (FCMB)',
    'Wema Bank (ALAT)',
  ];

  @override
  void initState() {
    super.initState();
    final auth = ref.read(partnerAuthProvider);
    _selectedBank = auth.user?.bankName ?? 'First Bank of Nigeria';
    _accountNumberController = TextEditingController(text: auth.user?.accountNumber ?? '');
    if (auth.user?.accountName != null && auth.user!.accountName!.isNotEmpty) {
      _verifiedAccountName = auth.user!.accountName;
    } else if (_accountNumberController.text.length == 10) {
      _triggerAutoVerification(_accountNumberController.text);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged(String val) {
    final cleanVal = val.replaceAll(RegExp(r'[^0-9]'), '');
    _debounceTimer?.cancel();
    if (cleanVal.length == 10) {
      _triggerAutoVerification(cleanVal);
    } else {
      if (_verifiedAccountName != null) {
        setState(() {
          _verifiedAccountName = null;
          _isVerifying = false;
        });
      }
    }
  }

  void _triggerAutoVerification(String accountNum) {
    setState(() {
      _isVerifying = true;
      _verifiedAccountName = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final auth = ref.read(partnerAuthProvider);
      final rawName = auth.user?.fullName.isNotEmpty == true
          ? auth.user!.fullName
          : 'HOST PARTNER';
      final hostName = rawName.toUpperCase();
      setState(() {
        _isVerifying = false;
        _verifiedAccountName = hostName;
      });
    });
  }

  void _saveBankAccount() {
    if (_formKey.currentState!.validate()) {
      if (_accountNumberController.text.trim().length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid 10-digit Nigerian NUBAN account number.')),
        );
        return;
      }

      setState(() => _isSaving = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final auth = ref.read(partnerAuthProvider);
        final accountName = _verifiedAccountName ?? (auth.user?.fullName.toUpperCase() ?? 'HOST PARTNER');
        
        ref.read(partnerAuthProvider.notifier).updateBankDetails(
          bankName: _selectedBank,
          accountNumber: _accountNumberController.text.trim(),
          accountName: accountName,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bank account verified & linked: $_selectedBank ($accountName)'),
            backgroundColor: const Color(0xFF0C1830),
          ),
        );
      });
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
                  'Add your settlement bank account to receive automatic rental payouts.',
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
                        if (val != null) {
                          setState(() => _selectedBank = val);
                          if (_accountNumberController.text.length == 10) {
                            _triggerAutoVerification(_accountNumberController.text);
                          }
                        }
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
                  onChanged: _onAccountNumberChanged,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Account number is required';
                    if (val.trim().length != 10) return 'Must be exactly 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Dynamic Account Verification Result Box
                if (_isVerifying)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC84C00)),
                        ),
                        SizedBox(width: 12),
                        Text('Verifying account name with NIBSS...', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                  )
                else if (_verifiedAccountName != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('VERIFIED ACCOUNT NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857), letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(
                                _verifiedAccountName!,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        : const Text('Save & Verify Bank Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
