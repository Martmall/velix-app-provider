import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';
import '../../providers/partner_app_providers.dart';

class EditPersonalDetailsSheet extends ConsumerStatefulWidget {
  const EditPersonalDetailsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EditPersonalDetailsSheet(),
    );
  }

  @override
  ConsumerState<EditPersonalDetailsSheet> createState() => _EditPersonalDetailsSheetState();
}

class _EditPersonalDetailsSheetState extends ConsumerState<EditPersonalDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _avatarUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(partnerAuthProvider);
    _nameController = TextEditingController(text: auth.user?.fullName ?? '');
    _emailController = TextEditingController(text: auth.user?.email ?? '');
    _phoneController = TextEditingController(text: auth.user?.phone ?? '');
    _avatarUrl = auth.user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final photo = await ImagePickerModal.show(
      context: context,
      title: 'Update Profile Photo',
      category: 'avatar',
    );
    if (photo != null && mounted) {
      setState(() => _avatarUrl = photo);
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        ref.read(partnerAuthProvider.notifier).updatePersonalDetails(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          avatarUrl: _avatarUrl,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal profile details updated successfully!'),
            backgroundColor: Color(0xFF0C1830),
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
                    Text(
                      'Edit Personal Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Avatar Picker
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFFDF0E9),
                        backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty ? NetworkImage(_avatarUrl!) : null,
                        child: _avatarUrl == null || _avatarUrl!.isEmpty
                            ? Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
                                    : 'ME',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFC84C00),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Full Name
                Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: titleColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: inputBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),
                // Email Address
                Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: titleColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. partner@velix.ng',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: inputBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
                  ),
                  validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 16),
                // Phone Number
                Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: titleColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. +234 801 234 5678',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: inputBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC84C00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
