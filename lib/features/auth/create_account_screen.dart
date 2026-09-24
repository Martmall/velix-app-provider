import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  CountryCode _selectedCountry = CountryCode.defaultCountry;
  bool _isCustomerRole = false;
  bool _obscurePassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  Future<void> _pickCountryCode() async {
    final picked = await CountryCodePickerModal.show(
      context: context,
      selectedCountry: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeTerms) {
        VelixToast.showInfo(
          context,
          'Please accept the Terms of Service & Privacy Policy to continue',
          title: 'Terms Required',
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final rawPhone = _phoneController.text.trim();
        final formattedPhone = rawPhone.startsWith('+') ? rawPhone : '${_selectedCountry.dialCode} $rawPhone';

        final success = await ref.read(partnerAuthProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: formattedPhone,
          password: _passwordController.text,
        );

        if (success && mounted) {
          setState(() => _isLoading = false);
          VelixToast.showSuccess(
            context,
            'Partner account created for ${_nameController.text.trim()}!',
            title: 'Registration Successful',
          );
          context.go(AppRoutes.otpVerification, extra: formattedPhone);
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          final message = e.toString().replaceAll('Exception:', '').trim();
          VelixToast.showError(
            context,
            message.isNotEmpty ? message : 'Partner registration failed. Please check your details.',
            title: 'Registration Failed',
          );
        }
      }
    }
  }

  Future<void> _socialSignUp(String provider) async {
    final user = await SocialAuthModal.show(
      context: context,
      provider: provider,
      isPartner: !_isCustomerRole,
    );

    if (user != null && mounted) {
      VelixToast.showSuccess(
        context,
        'Welcome, ${user.fullName}! Connected with $provider.',
        title: 'Account Connected',
      );
      context.go(AppRoutes.partnerSetUp);
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
    final roleToggleBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F5F8);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: VelixBackButton(fallbackRoute: AppRoutes.partnerSignIn),
                ),
                const SizedBox(height: 4),
                const VelixLogoHeader(),
                const SizedBox(height: 20),
                Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Join Nigeria's premium fleet host platform",
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Elevated Container Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Social Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _socialSignUp('Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: borderColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'G ',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                  Text(
                                    'Google',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _socialSignUp('Apple'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF1F2430) : const Color(0xFF0C1830),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.apple, color: Colors.white, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Apple',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider(color: borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'or continue with email',
                              style: TextStyle(color: subtextColor, fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: borderColor)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Segmented Role Selector Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: roleToggleBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCustomerRole = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isCustomerRole ? const Color(0xFFC84C00) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: _isCustomerRole ? Colors.white : subtextColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "I'm a Customer",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _isCustomerRole ? Colors.white : subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCustomerRole = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !_isCustomerRole ? const Color(0xFFC84C00) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_car_outlined,
                                        size: 16,
                                        color: !_isCustomerRole ? Colors.white : subtextColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "I Own a Car",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: !_isCustomerRole ? Colors.white : subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Full Name Field
                      Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _buildInputDecoration('e.g Chidi Okonkwo', inputBg, borderColor, subtextColor),
                        validator: (val) => val == null || val.isEmpty ? 'Full name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      // Email Address Field
                      Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _buildInputDecoration('you@example.com', inputBg, borderColor, subtextColor),
                        validator: (val) => val == null || val.isEmpty ? 'Email address required' : null,
                      ),
                      const SizedBox(height: 14),
                      // Phone Number Dual Field Row
                      Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickCountryCode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_selectedCountry.flag, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedCountry.dialCode,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.keyboard_arrow_down, size: 16, color: subtextColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _buildInputDecoration('0801 234 5678', inputBg, borderColor, subtextColor),
                              keyboardType: TextInputType.phone,
                              validator: (val) => val == null || val.isEmpty ? 'Phone number required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Password Field
                      Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _buildInputDecoration('Min. 8 characters', inputBg, borderColor, subtextColor).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: subtextColor,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) => val == null || val.length < 8 ? 'Min 8 characters required' : null,
                      ),
                      const SizedBox(height: 16),
                      // Agreement Checkbox Row
                      GestureDetector(
                        onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeTerms,
                                activeColor: const Color(0xFFC84C00),
                                checkColor: Colors.white,
                                side: BorderSide(color: subtextColor, width: 1.8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 12, color: subtextColor),
                                  children: [
                                    const TextSpan(text: 'I agree to Velix '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: const TextStyle(color: Color(0xFFC84C00), fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => LegalTermsModal.showTermsOfService(context),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(color: Color(0xFFC84C00), fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => LegalTermsModal.showPrivacyPolicy(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      PartnerOrangeButton(
                        text: 'Get Started',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(color: subtextColor, fontSize: 13)),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.partnerSignIn),
                            child: const Text('Login', style: TextStyle(color: Color(0xFFC84C00), fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, Color inputBg, Color borderColor, Color subtextColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: subtextColor, fontSize: 14),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5),
      ),
    );
  }
}
