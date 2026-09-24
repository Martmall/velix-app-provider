import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class MyVehiclesScreen extends ConsumerStatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  ConsumerState<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends ConsumerState<MyVehiclesScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0C10) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF262B38) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9);

    final fleetAsync = ref.watch(partnerFleetProvider);
    var cars = fleetAsync.valueOrNull ?? [];

    if (_selectedFilter == 'Available') {
      cars = cars.where((c) => c.isAvailable).toList();
    } else if (_selectedFilter == 'Booked') {
      cars = cars.where((c) => !c.isAvailable).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      cars = cars.where((c) => c.name.toLowerCase().contains(q) || c.category.toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const VelixBackButton(fallbackRoute: AppRoutes.partnerHome),
        title: Text(
          'My Vehicles',
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
          IconButton(
            icon: Icon(Icons.notifications_none, color: textColor),
            onPressed: () => context.go(AppRoutes.partnerTripUpdates),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  // Search Bar Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search Vehicles',
                      hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: subtextColor),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', isDark, cardBg, textColor, borderColor),
                        const SizedBox(width: 8),
                        _buildFilterChip('Available', isDark, cardBg, textColor, borderColor),
                        const SizedBox(width: 8),
                        _buildFilterChip('Maintenance', isDark, cardBg, textColor, borderColor),
                        const SizedBox(width: 8),
                        _buildFilterChip('Booked', isDark, cardBg, textColor, borderColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Vehicles Inventory List
            Expanded(
              child: cars.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.directions_car_outlined, size: 36, color: subtextColor),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No vehicles in fleet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the button below to add your first vehicle to the Velix rental catalog.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: subtextColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: cars.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final item = cars[index];
                        return _buildVehicleCard(item, isDark, cardBg, textColor, subtextColor, borderColor);
                      },
                    ),
            ),
            // Sticky Add New Vehicle Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PartnerOrangeButton(
                text: '+ Add New Vehicle',
                onPressed: () => context.go(AppRoutes.addVehicle),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
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

  Widget _buildFilterChip(String label, bool isDark, Color cardBg, Color textColor, Color borderColor) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC84C00) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFC84C00) : borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF374151)),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(CarModel item, bool isDark, Color cardBg, Color textColor, Color subtextColor, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.imageUrl.isNotEmpty
                      ? item.imageUrl
                      : CarImageCatalog.getImageForCar(item.name, category: item.category),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6),
                    child: Center(
                      child: Icon(Icons.directions_car, size: 80, color: subtextColor),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isAvailable ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isAvailable ? 'Available' : 'Booked',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₦${item.pricePerDay.toStringAsFixed(0)}/day',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.brand} • ${item.category} • ${item.location}',
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSpecBadge(Icons.settings_outlined, item.transmission, isDark, subtextColor, textColor),
                    const SizedBox(width: 8),
                    _buildSpecBadge(Icons.people_outline, '${item.seats} Seats', isDark, subtextColor, textColor),
                    const SizedBox(width: 8),
                    _buildSpecBadge(Icons.local_gas_station_outlined, item.fuelType, isDark, subtextColor, textColor),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(AppRoutes.addVehicle, extra: item),
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                        label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC84C00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: cardBg,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('Remove Vehicle', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              content: Text('Are you sure you want to remove "${item.name}" from your active fleet?', style: TextStyle(color: subtextColor)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Cancel', style: TextStyle(color: subtextColor)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref.read(fleetRepoProvider).removeVehicle(item.id);
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${item.name} removed from fleet.')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                        label: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF331616) : const Color(0xFFFEE2E2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBadge(IconData icon, String label, bool isDark, Color subtextColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: subtextColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: textColor)),
        ],
      ),
    );
  }
}
