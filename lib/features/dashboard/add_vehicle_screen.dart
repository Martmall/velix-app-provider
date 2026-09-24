import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/partner_app_providers.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  final CarModel? initialCar;

  const AddVehicleScreen({super.key, this.initialCar});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _plateController;
  late TextEditingController _descController;
  late TextEditingController _videoUrlController;

  String _selectedCategory = 'SUV';
  String _selectedTransmission = 'Automatic';
  String _selectedFuel = 'Gasoline';
  final int _selectedSeats = 5;
  String _selectedLocation = 'Lekki Phase 1, Lagos';
  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> _photos = [];
  final List<DateTime> _blockedDates = [];

  final Map<String, bool> _features = {
    'GPS Navigation': false,
    'Leather Seats': false,
    'Sunroof': false,
    'Keyless Remote Entry': false,
    'Bluetooth': false,
    'Apple CarPlay': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialCar != null) {
      final c = widget.initialCar!;
      _nameController = TextEditingController(text: c.name);
      _brandController = TextEditingController(text: c.brand);
      _priceController = TextEditingController(text: c.pricePerDay.toStringAsFixed(0));
      _plateController = TextEditingController(text: c.licensePlate ?? '');
      _descController = TextEditingController(text: c.location);
      _videoUrlController = TextEditingController(text: c.videoUrl ?? '');
      _selectedCategory = c.category;
      _selectedTransmission = c.transmission;
      _selectedFuel = c.fuelType;
      _isAvailable = c.isAvailable;
      _photos.clear();
      _photos.add(c.imageUrl);
      _photos.addAll(c.galleryImages.where((img) => img != c.imageUrl));
      for (final f in c.features) {
        _features[f] = true;
      }
      for (final d in c.unavailableDates) {
        final parsed = DateTime.tryParse(d);
        if (parsed != null) _blockedDates.add(parsed);
      }
    } else {
      _nameController = TextEditingController();
      _brandController = TextEditingController();
      _priceController = TextEditingController();
      _plateController = TextEditingController();
      _descController = TextEditingController();
      _videoUrlController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _plateController.dispose();
    _descController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  String? _extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url.trim());
    return match?.group(1);
  }

  Future<void> _addPhoto() async {
    final selectedPhoto = await ImagePickerModal.show(
      context: context,
      title: 'Add Vehicle Photo',
      isVehicle: true,
      category: 'vehicle',
    );

    if (selectedPhoto != null && mounted) {
      setState(() {
        _photos.add(selectedPhoto);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle photo captured and added!'),
          backgroundColor: Color(0xFF0C1830),
        ),
      );
    }
  }

  Future<void> _pickBlockedDateRange() async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFC84C00),
                    onPrimary: Colors.white,
                    surface: Color(0xFF161922),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFC84C00),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF0C1830),
                  ),
                ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        var current = pickedRange.start;
        while (!current.isAfter(pickedRange.end)) {
          if (!_blockedDates.any((d) => d.year == current.year && d.month == current.month && d.day == current.day)) {
            _blockedDates.add(current);
          }
          current = current.add(const Duration(days: 1));
        }
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please capture or select at least 1 real vehicle photo.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final price = double.tryParse(_priceController.text) ?? 50000.0;
      final selectedFeats = _features.entries.where((e) => e.value).map((e) => e.key).toList();
      final carName = _nameController.text.trim();
      final authState = ref.read(partnerAuthProvider);
      final partnerId = authState.user?.id ?? 'host_${DateTime.now().millisecondsSinceEpoch}';
      final partnerName = authState.user?.fullName.isNotEmpty == true ? authState.user!.fullName : 'Host Partner';
      final videoUrl = _videoUrlController.text.trim().isNotEmpty ? _videoUrlController.text.trim() : null;
      final unavailableDateStrings = _blockedDates.map((d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}').toList();

      if (widget.initialCar != null) {
        final updatedCar = widget.initialCar!.copyWith(
          name: carName,
          brand: _brandController.text.trim(),
          category: _selectedCategory,
          pricePerDay: price,
          transmission: _selectedTransmission,
          fuelType: _selectedFuel,
          imageUrl: _photos.first,
          galleryImages: _photos,
          features: selectedFeats,
          location: '$_selectedLocation - ${_descController.text.trim()}',
          videoUrl: videoUrl,
          isAvailable: _isAvailable,
          unavailableDates: unavailableDateStrings,
        );
        await ref.read(fleetRepoProvider).addVehicle(updatedCar);
      } else {
        final newCar = CarModel(
          id: 'car_${DateTime.now().millisecondsSinceEpoch}',
          name: carName,
          brand: _brandController.text.trim(),
          category: _selectedCategory,
          pricePerDay: price,
          rating: 5.0,
          reviewsCount: 0,
          imageUrl: _photos.first,
          galleryImages: _photos,
          transmission: _selectedTransmission,
          fuelType: _selectedFuel,
          seats: _selectedSeats,
          partnerId: partnerId,
          partnerName: partnerName,
          partnerAvatar: authState.user?.avatarUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          isFavorite: false,
          isAvailable: _isAvailable,
          location: '$_selectedLocation - ${_descController.text.trim()}',
          features: selectedFeats,
          videoUrl: videoUrl,
          unavailableDates: unavailableDateStrings,
        );
        await ref.read(fleetRepoProvider).addVehicle(newCar);
      }

      ref.invalidate(partnerFleetProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        VelixToast.showSuccess(
          context,
          widget.initialCar != null
              ? 'Vehicle updated successfully!'
              : 'New vehicle published to fleet successfully!',
          title: widget.initialCar != null ? 'Vehicle Updated' : 'Vehicle Published',
        );
        context.go(AppRoutes.myVehicles);
      }
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
    final inputBg = isDark ? const Color(0xFF1F2430) : const Color(0xFFF9FAFB);

    final ytId = _extractYoutubeId(_videoUrlController.text);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: const VelixBackButton(fallbackRoute: AppRoutes.myVehicles),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.initialCar != null ? 'Edit Vehicle Listing' : 'Add Vehicle Listing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            Text(widget.initialCar != null ? 'Update details for this vehicle' : 'Enter vehicle details to publish on Velix',
                style: TextStyle(fontSize: 11, color: subtextColor)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.brightness_2_outlined, color: textColor),
            onPressed: () {
              ref.read(appThemeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ref.watch(partnerAuthProvider).user?.cacStatus != 'approved') ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Business (CAC) Verification Required',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              ref.watch(partnerAuthProvider).user?.cacDocumentUrl != null
                                  ? 'Your CAC certificate is currently under review by Admin at /admin/partner-verification. Listings will go live upon approval.'
                                  : 'Please complete your CAC business verification before your vehicle listings can accept live bookings.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                            ),
                            if (ref.watch(partnerAuthProvider).user?.cacDocumentUrl == null) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.partnerSetUp),
                                child: const Text(
                                  'Complete CAC Registration →',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Section 1: Photos & Media
              _buildSectionHeader(Icons.camera_alt_outlined, 'Vehicle Photos & Media', textColor, isDark),
              const SizedBox(height: 12),
              // Photos Container Box
              GestureDetector(
                onTap: _addPhoto,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC84C00), width: 1.5),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 36, color: Color(0xFFC84C00)),
                      SizedBox(height: 8),
                      Text('Upload Vehicle Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                      SizedBox(height: 4),
                      Text('Tap to select real images (JPG, PNG)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Photo Thumbnails Row
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _photos.length) {
                      return GestureDetector(
                        onTap: _addPhoto,
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2430) : const Color(0xFFF4F6F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Color(0xFFC84C00), size: 20),
                              Text('Add More', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                            ],
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(image: NetworkImage(_photos[index]), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // YouTube Link Card Section
              _buildCardContainer(cardBg, borderColor, [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.play_circle_fill, color: Color(0xFFFF0000), size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text('YouTube Car Video (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Add a YouTube link showcasing the car to build trust and boost bookings', style: TextStyle(fontSize: 11, color: subtextColor)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _videoUrlController,
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: _buildInputDecoration('e.g. https://www.youtube.com/watch?v=dQw4w9WgXcQ', inputBg, borderColor, subtextColor).copyWith(
                    prefixIcon: const Icon(Icons.link, color: Color(0xFFFF0000), size: 18),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (ytId != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage('https://img.youtube.com/vi/$ytId/0.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                ],
              ]),

              const SizedBox(height: 20),
              // Section 2: Vehicle Details
              _buildSectionHeader(Icons.directions_car_outlined, 'Vehicle Details', textColor, isDark),
              const SizedBox(height: 12),
              _buildCardContainer(cardBg, borderColor, [
                Text('Vehicle Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: _buildInputDecoration('e.g. Toyota Land Cruiser Prado', inputBg, borderColor, subtextColor),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Brand', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _brandController,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: _buildInputDecoration('e.g. Toyota', inputBg, borderColor, subtextColor),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            dropdownColor: cardBg,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: _buildInputDecoration('Select', inputBg, borderColor, subtextColor),
                            items: ['SUV', 'Sedan', 'Luxury', 'Sports', 'Convertible']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transmission', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedTransmission,
                            dropdownColor: cardBg,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: _buildInputDecoration('Select', inputBg, borderColor, subtextColor),
                            items: ['Automatic', 'Manual'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) => setState(() => _selectedTransmission = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fuel Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedFuel,
                            dropdownColor: cardBg,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: _buildInputDecoration('Select', inputBg, borderColor, subtextColor),
                            items: ['Gasoline', 'Hybrid', 'Electric'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                            onChanged: (val) => setState(() => _selectedFuel = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 20),
              // Section 3: Availability & Calendar
              _buildSectionHeader(Icons.calendar_month_outlined, 'Availability & Calendar', textColor, isDark),
              const SizedBox(height: 12),
              _buildCardContainer(cardBg, borderColor, [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available for Instant Booking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 2),
                        Text('Allow users to book this vehicle immediately', style: TextStyle(fontSize: 11, color: subtextColor)),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeThumbColor: const Color(0xFFC84C00),
                      activeTrackColor: const Color(0xFFC84C00).withValues(alpha: 0.3),
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Blocked / Unavailable Dates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 2),
                        Text('${_blockedDates.length} dates blocked from booking', style: TextStyle(fontSize: 11, color: subtextColor)),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickBlockedDateRange,
                      icon: const Icon(Icons.date_range, size: 16, color: Color(0xFFC84C00)),
                      label: const Text('Add Range', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC84C00))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC84C00)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                if (_blockedDates.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _blockedDates.map((date) {
                      return Chip(
                        backgroundColor: isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9),
                        side: const BorderSide(color: Color(0xFFC84C00)),
                        label: Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC84C00)),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFFC84C00)),
                        onDeleted: () => setState(() => _blockedDates.remove(date)),
                      );
                    }).toList(),
                  ),
                ],
              ]),

              const SizedBox(height: 20),
              // Section 4: Pricing & Location
              _buildSectionHeader(Icons.account_balance_wallet_outlined, 'Pricing & Location', textColor, isDark),
              const SizedBox(height: 12),
              _buildCardContainer(cardBg, borderColor, [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Rate (₦)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: _buildInputDecoration('e.g. 65000', inputBg, borderColor, subtextColor),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedLocation,
                            dropdownColor: cardBg,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: _buildInputDecoration('Select', inputBg, borderColor, subtextColor),
                            items: ['Lekki Phase 1, Lagos', 'Ikeja GRA, Lagos', 'Victoria Island, Lagos', 'Maitama, Abuja']
                                .map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedLocation = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 20),
              // Section 5: Features Checkboxes
              _buildSectionHeader(Icons.star_outline, 'Vehicle Features', textColor, isDark),
              const SizedBox(height: 12),
              _buildCardContainer(cardBg, borderColor, [
                Column(
                  children: _features.keys.map((feat) {
                    final isChecked = _features[feat] ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? (isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9))
                            : (isDark ? const Color(0xFF1F2430) : const Color(0xFFF9FAFB)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isChecked ? const Color(0xFFC84C00) : borderColor,
                          width: isChecked ? 1.5 : 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          feat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                            color: isChecked ? const Color(0xFFC84C00) : textColor,
                          ),
                        ),
                        value: isChecked,
                        activeColor: const Color(0xFFC84C00),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                          width: 2,
                        ),
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _features[feat] = val ?? false),
                      ),
                    );
                  }).toList(),
                ),
              ]),

              const SizedBox(height: 24),
              PartnerOrangeButton(
                text: widget.initialCar != null ? 'Update Vehicle Details' : 'Publish Vehicle Listing',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color textColor, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A1B14) : const Color(0xFFFDF0E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFC84C00)),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildCardContainer(Color cardBg, Color borderColor, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  InputDecoration _buildInputDecoration(String hint, Color inputBg, Color borderColor, Color hintColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC84C00), width: 1.5)),
    );
  }
}
