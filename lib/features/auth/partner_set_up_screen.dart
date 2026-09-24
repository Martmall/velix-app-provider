import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class PartnerSetUpScreen extends ConsumerStatefulWidget {
  const PartnerSetUpScreen({super.key});

  @override
  ConsumerState<PartnerSetUpScreen> createState() => _PartnerSetUpScreenState();
}

class _PartnerSetUpScreenState extends ConsumerState<PartnerSetUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _taxIdController;

  bool _isDocUploaded = false;
  String? _uploadedDocUrl;
  String? _uploadedDocName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(partnerAuthProvider);
    _businessNameController = TextEditingController(text: auth.user?.businessName ?? '');
    _taxIdController = TextEditingController(text: auth.user?.cacNumber ?? '');
    if (auth.user?.cacDocumentUrl != null && auth.user!.cacDocumentUrl!.isNotEmpty) {
      _isDocUploaded = true;
      _uploadedDocUrl = auth.user!.cacDocumentUrl;
      _uploadedDocName = _uploadedDocUrl!.split('/').last.split('?').first;
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await ImagePickerModal.show(
      context: context,
      title: 'Attach Business / CAC Document',
      isDocument: true,
      category: 'cac',
    );
    if (result != null && mounted) {
      final fileName = result.split('/').last.split('?').first;
      setState(() {
        _isDocUploaded = true;
        _uploadedDocUrl = result;
        _uploadedDocName = fileName.isNotEmpty ? fileName : 'CAC_Certificate.pdf';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CAC Document ($fileName) attached & uploaded!'),
          backgroundColor: const Color(0xFF0C1830),
        ),
      );
    }
  }

  void _submitKYC() {
    if (_formKey.currentState!.validate()) {
      if (!_isDocUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please attach your business registration document (PDF/Image).')),
        );
        return;
      }
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _isLoading = false);
          final bName = _businessNameController.text.trim();
          final taxId = _taxIdController.text.trim();
          final docUrl = _uploadedDocUrl ?? 'CAC_Certificate_${DateTime.now().millisecondsSinceEpoch}.pdf';

          ref.read(partnerAuthProvider.notifier).updateBusinessDetails(
            businessName: bName,
            cacNumber: taxId,
            cacDocumentUrl: docUrl,
          );

          _showUnderReviewDialog();
        }
      });
    }
  }

  void _showUnderReviewDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final docBoxBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.hourglass_top, color: Color(0xFFC84C00), size: 28),
            const SizedBox(width: 10),
            Text('Under Admin Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your business details and registration documents have been submitted to the Admin Verification Desk.',
              style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: docBoxBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _uploadedDocName ?? 'CAC_Certificate.pdf',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Once an Administrator approves your documents in the Admin Portal, your fleet and booking dashboard will be fully activated.',
              style: TextStyle(fontSize: 12, color: subtextColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.partnerHome);
            },
            child: const Text('Go to Dashboard (Pending Approval)', style: TextStyle(color: Color(0xFFC84C00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF9FAFB);

    final auth = ref.watch(partnerAuthProvider);
    final hasSubmitted = auth.user?.cacDocumentUrl != null || _isDocUploaded;
    final isApproved = auth.user?.cacStatus == 'approved';

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
              context.go(AppRoutes.partnerSignIn);
            }
          },
        ),
        title: Text(
          'Vendor Business Setup',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business Verification', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 6),
                Text('Enter business details and upload tax / CAC registration documentation.', style: TextStyle(fontSize: 13, color: subtextColor)),
                const SizedBox(height: 20),

                // Submission Status Card (if submitted)
                if (hasSubmitted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? (isDark ? const Color(0xFF0D2E1A) : const Color(0xFFD1FAE5))
                          : (isDark ? const Color(0xFF2C220E) : const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isApproved ? Icons.verified : Icons.hourglass_top,
                              color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isApproved ? 'CAC Approved by Administrator' : 'Status: Under Admin Review',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isApproved ? const Color(0xFF047857) : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isApproved
                              ? 'Your business verification has been approved. Your fleet listings and vendor payouts are fully activated.'
                              : 'Your submitted CAC documents are being audited by the Velix Verification Desk at /admin/partner-verification.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isApproved ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46)) : (isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                          ),
                        ),
                        if (_uploadedDocName != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _uploadedDocName!,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('Attached', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Card Container
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
                      Text('Business Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _businessNameController,
                        style: TextStyle(fontSize: 14, color: textColor),
                        decoration: _buildInputDecoration('e.g. Adebayo Luxury Motors Ltd', inputBg, borderColor, subtextColor),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter registered business name' : null,
                      ),
                      const SizedBox(height: 18),
                      Text('CAC / Tax ID Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _taxIdController,
                        style: TextStyle(fontSize: 14, color: textColor),
                        decoration: _buildInputDecoration('e.g. CAC-RC-881920', inputBg, borderColor, subtextColor),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter CAC or Tax ID' : null,
                      ),
                      const SizedBox(height: 18),
                      Text('CAC / Registration Document', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDocument,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isDocUploaded ? const Color(0xFF10B981) : borderColor,
                              width: _isDocUploaded ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _isDocUploaded ? const Color(0xFFD1FAE5) : (isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _isDocUploaded ? Icons.check_circle : Icons.upload_file,
                                  color: _isDocUploaded ? const Color(0xFF10B981) : const Color(0xFFC84C00),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isDocUploaded ? (_uploadedDocName ?? 'Document Attached') : 'Attach CAC Certificate (PDF/JPG)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _isDocUploaded ? const Color(0xFF10B981) : textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isDocUploaded ? 'Tap to replace file' : 'Max size 10MB',
                                      style: TextStyle(fontSize: 11, color: subtextColor),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtextColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PartnerOrangeButton(
                  text: hasSubmitted ? 'Update Verification Details' : 'Complete Verification & Open Dashboard',
                  isLoading: _isLoading,
                  onPressed: _submitKYC,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, Color inputBg, Color borderColor, Color hintColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor, fontSize: 13),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
    );
  }
}
