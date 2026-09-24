import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/routes.dart';

class DevPreviewScreen extends StatefulWidget {
  const DevPreviewScreen({super.key});

  @override
  State<DevPreviewScreen> createState() => _DevPreviewScreenState();
}

class _DevPreviewScreenState extends State<DevPreviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  String _selectedCategory = 'ALL';

  final List<Map<String, dynamic>> _sections = [
    {
      'id': 'ONBOARDING',
      'category': '1. VENDOR ONBOARDING & AUTH',
      'icon': Icons.security,
      'screens': [
        {'title': '01. Vendor Onboarding 1', 'route': AppRoutes.vendorOnboarding1, 'icon': Icons.splitscreen},
        {'title': '02. Vendor Onboarding 2', 'route': AppRoutes.vendorOnboarding2, 'icon': Icons.splitscreen},
        {'title': '03. Vendor Onboarding 3', 'route': AppRoutes.vendorOnboarding3, 'icon': Icons.splitscreen},
        {'title': '04. Vendor Onboarding 4', 'route': AppRoutes.vendorOnboarding4, 'icon': Icons.splitscreen},
        {'title': '05. Partner Sign In Page', 'route': AppRoutes.partnerSignIn, 'icon': Icons.login},
        {'title': '06. Create Account', 'route': AppRoutes.createAccount, 'icon': Icons.person_add},
        {'title': '07. Partner Set Up Page (KYC)', 'route': AppRoutes.partnerSetUp, 'icon': Icons.badge},
      ]
    },
    {
      'id': 'FLEET',
      'category': '2. HOST DASHBOARD & FLEET MANAGEMENT',
      'icon': Icons.dashboard,
      'screens': [
        {'title': '08. Partner Home / Host Portal', 'route': AppRoutes.partnerHome, 'icon': Icons.home},
        {'title': '09. My Vehicles / Fleet Inventory', 'route': AppRoutes.myVehicles, 'icon': Icons.directions_car},
        {'title': '10. Add Vehicle / Listing Form', 'route': AppRoutes.addVehicle, 'icon': Icons.add_circle},
      ]
    },
    {
      'id': 'BOOKINGS',
      'category': '3. BOOKINGS, PICKUPS & RETURNS',
      'icon': Icons.calendar_month,
      'screens': [
        {'title': '11. Bookings / Rental Requests', 'route': AppRoutes.partnerBookings, 'icon': Icons.receipt_long},
        {'title': '12. Verify Pickup 1 (Baseline Photos)', 'route': AppRoutes.verifyPickup1, 'icon': Icons.qr_code},
        {'title': '13. Verify Pickup 2 (OTP Access Code)', 'route': AppRoutes.verifyPickup2, 'icon': Icons.pin},
        {'title': '14. Partner Trip Updates Feed', 'route': AppRoutes.partnerTripUpdates, 'icon': Icons.feed},
        {'title': '15. Verify Return 1 (Active Rentals)', 'route': AppRoutes.verifyReturn1, 'icon': Icons.assignment_return},
        {'title': '16. Verify Return 2 (Return Code Payout)', 'route': AppRoutes.verifyReturn2, 'icon': Icons.numbers},
      ]
    },
    {
      'id': 'FINANCE',
      'category': '4. FINANCE, DISPUTES & PROFILE',
      'icon': Icons.account_balance_wallet,
      'screens': [
        {'title': '17. My Earnings & Revenue Analytics', 'route': AppRoutes.earnings, 'icon': Icons.show_chart},
        {'title': '18. Support & Claims Disputes', 'route': AppRoutes.supportDisputes, 'icon': Icons.support},
        {'title': '19. Partner Profile & Host Settings', 'route': AppRoutes.partnerProfile, 'icon': Icons.person},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1830),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1830),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Velix Partner App — Developer Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFC84C00).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC84C00)),
              ),
              child: const Text(
                '18 Screens Verified',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter / Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filter = val.toLowerCase()),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search 18 partner screens...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
            ),
          ),
          // Category Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All Screens'),
                const SizedBox(width: 8),
                _buildFilterChip('ONBOARDING', '1. Onboarding & KYC'),
                const SizedBox(width: 8),
                _buildFilterChip('FLEET', '2. Host & Fleet'),
                const SizedBox(width: 8),
                _buildFilterChip('BOOKINGS', '3. Pickups & Returns'),
                const SizedBox(width: 8),
                _buildFilterChip('FINANCE', '4. Earnings & Profile'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _sections.length,
              itemBuilder: (context, sectionIdx) {
                final section = _sections[sectionIdx];
                final sectionId = section['id'] as String;

                if (_selectedCategory != 'ALL' && _selectedCategory != sectionId) {
                  return const SizedBox.shrink();
                }

                final List<Map<String, dynamic>> rawScreens = section['screens'];
                final filteredScreens = rawScreens.where((s) {
                  final title = (s['title'] as String).toLowerCase();
                  final route = (s['route'] as String).toLowerCase();
                  return title.contains(_filter) || route.contains(_filter);
                }).toList();

                if (filteredScreens.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Row(
                        children: [
                          Icon(section['icon'] as IconData, size: 18, color: const Color(0xFFC84C00)),
                          const SizedBox(width: 8),
                          Text(
                            section['category'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC84C00),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${filteredScreens.length} Screens',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    ...filteredScreens.map((item) {
                      return Card(
                        color: const Color(0xFF1E293B),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(item['icon'] as IconData, color: Colors.white70, size: 20),
                          title: Text(
                            item['title'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          subtitle: Text(
                            item['route'] as String,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFC84C00), size: 14),
                          onTap: () => context.go(item['route'] as String),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = _selectedCategory == id;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFC84C00),
      backgroundColor: const Color(0xFF1E293B),
      onSelected: (_) => setState(() => _selectedCategory = id),
    );
  }
}
