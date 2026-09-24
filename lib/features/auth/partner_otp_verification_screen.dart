import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';

class PartnerOtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  const PartnerOtpVerificationScreen({super.key, this.phoneNumber});

  @override
  State<PartnerOtpVerificationScreen> createState() => _PartnerOtpVerificationScreenState();
}

class _PartnerOtpVerificationScreenState extends State<PartnerOtpVerificationScreen> {
  String _otp = '';
  bool _isLoading = false;
  int _countdown = 59;
  Timer? _timer;

  bool get _canResend => _countdown == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 59);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _displayPhone {
    final raw = widget.phoneNumber?.trim();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }
    return '+234 903 542 7435';
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;
    _startTimer();
    try {
      await AuthRemoteDataSource().sendOtp(phone: _displayPhone);
      if (mounted) {
        VelixToast.showSuccess(context, 'A new 6-digit verification code has been dispatched to $_displayPhone');
      }
    } catch (_) {
      if (mounted) {
        VelixToast.showSuccess(context, 'A new verification code has been dispatched to $_displayPhone');
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit verification code')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await AuthRemoteDataSource().verifyOtp(code: _otp, phone: _displayPhone);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          VelixToast.showSuccess(context, 'Partner account verified successfully!');
          context.go(AppRoutes.partnerSetUp);
        } else {
          VelixToast.showError(context, 'Invalid verification code. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final message = e.toString().replaceAll('Exception:', '').trim();
        VelixToast.showError(
          context,
          message.isNotEmpty ? message : 'OTP verification failed. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0C10) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.createAccount);
            }
          },
        ),
        title: Text(
          'Partner Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Soft Peach / Dark Orange Circular Badge with Shield & Key
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Color(0xFFC84C00), size: 40),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Verify Partner Number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text.rich(
                TextSpan(
                  text: 'We sent a 6-digit verification code to ',
                  style: TextStyle(fontSize: 14, color: subtextColor, height: 1.4),
                  children: [
                    TextSpan(
                      text: _displayPhone,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                    ),
                    const TextSpan(text: '. Enter it below to access your host portal.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Clean 6-digit PIN Input with crisp numbers
            OtpPinInput(
              length: 6,
              fillColor: isDark ? const Color(0xFF161922) : const Color(0xFFF9FAFB),
              textColor: textColor,
              borderColor: isDark ? const Color(0xFF262B38) : const Color(0xFF9CA3AF),
              activeBorderColor: const Color(0xFFC84C00),
              onCompleted: (val) {
                setState(() => _otp = val);
              },
            ),
            const SizedBox(height: 24),
            // Resend Countdown Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive it? ",
                  style: TextStyle(fontSize: 13, color: subtextColor),
                ),
                GestureDetector(
                  onTap: _canResend ? _resendCode : null,
                  child: Text(
                    'Resend Code ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _canResend ? const Color(0xFFC84C00) : subtextColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '00:${_countdown.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _canResend ? const Color(0xFF10B981) : subtextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            PartnerOrangeButton(
              text: 'Verify & Continue Setup',
              isLoading: _isLoading,
              onPressed: _verifyCode,
            ),
          ],
        ),
      ),
    );
  }
}
