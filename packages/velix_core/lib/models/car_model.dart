class CarModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double pricePerDay;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final String transmission;
  final String fuelType;
  final int seats;
  final String partnerId;
  final String partnerName;
  final String partnerAvatar;
  final bool isFavorite;
  final bool isAvailable;
  final String location;
  final List<String> features;
  final List<String> galleryImages;
  final String? videoUrl;
  final List<String> unavailableDates;
  final String? licensePlate;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.pricePerDay,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.partnerId,
    required this.partnerName,
    required this.partnerAvatar,
    this.isFavorite = false,
    this.isAvailable = true,
    required this.location,
    this.features = const [],
    this.galleryImages = const [],
    this.videoUrl,
    this.unavailableDates = const [],
    this.licensePlate,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    final brand = (json['brand'] ?? json['make'] ?? '').toString();
    final model = (json['model'] ?? '').toString();
    final title = json['name'] ?? json['title'];
    final name = title != null && title.toString().isNotEmpty
        ? title.toString()
        : (brand.isNotEmpty ? '$brand $model'.trim() : 'Vehicle');
    final price = (json['pricePerDay'] ?? json['price_per_day'] ?? json['daily_rate'] as num?)?.toDouble() ?? 0.0;

    String img = (json['imageUrl'] ?? json['image_url'] ?? json['main_image_url'] ?? json['main_image'] ?? json['image'] ?? '').toString();
    if (img.isEmpty && json['photos'] is List && (json['photos'] as List).isNotEmpty) {
      final first = (json['photos'] as List).first;
      img = first is Map ? (first['url'] ?? first['photo_url'] ?? '') : first.toString();
    }
    if (img.isEmpty && json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = (json['images'] as List).first;
      img = first is Map ? (first['url'] ?? first['image_url'] ?? '') : first.toString();
    }

    final status = (json['operational_status'] ?? json['status'] ?? 'AVAILABLE').toString().toUpperCase();
    final isAvail = json['isAvailable'] ?? json['is_available'] ?? (status == 'AVAILABLE');
    final vid = json['videoUrl'] ?? json['video_url'] ?? json['youtube_url'];
    final unavail = json['unavailableDates'] ?? json['unavailable_dates'] ?? json['blocked_ranges'] ?? [];

    String locationStr = 'Lagos, Nigeria';
    final rawLoc = json['location'];
    if (rawLoc is Map) {
      final city = rawLoc['city']?.toString() ?? '';
      final address = rawLoc['address']?.toString() ?? '';
      if (address.isNotEmpty && city.isNotEmpty) {
        locationStr = '$address, $city';
      } else if (city.isNotEmpty) {
        locationStr = city;
      } else if (address.isNotEmpty) {
        locationStr = address;
      }
    } else if (rawLoc != null && rawLoc.toString().isNotEmpty) {
      locationStr = rawLoc.toString();
    } else if (json['city'] != null && json['city'].toString().isNotEmpty) {
      locationStr = json['city'].toString();
    }

    List<String> parsedFeatures = [];
    if (json['features'] is List) {
      parsedFeatures = (json['features'] as List).map((f) => f is Map ? (f['name'] ?? f['feature'] ?? '').toString() : f.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (parsedFeatures.isEmpty) {
      parsedFeatures = ['GPS Navigation', 'Air Conditioning', 'Bluetooth'];
    }

    List<String> parsedGallery = [];
    if (json['galleryImages'] is List) {
      parsedGallery = (json['galleryImages'] as List).map((g) => g.toString()).toList();
    } else if (json['gallery_images'] is List) {
      parsedGallery = (json['gallery_images'] as List).map((g) => g.toString()).toList();
    } else if (json['photos'] is List) {
      parsedGallery = (json['photos'] as List).map((p) => p is Map ? (p['url'] ?? p['photo_url'] ?? '').toString() : p.toString()).where((s) => s.isNotEmpty).toList();
    } else if (json['images'] is List) {
      parsedGallery = (json['images'] as List).map((i) => i is Map ? (i['url'] ?? i['image_url'] ?? '').toString() : i.toString()).where((s) => s.isNotEmpty).toList();
    }

    return CarModel(
      id: json['id']?.toString() ?? '',
      name: name,
      brand: brand,
      category: (json['category'] ?? json['category_name'] ?? 'SEDAN').toString().toUpperCase(),
      pricePerDay: price,
      rating: (json['rating'] ?? json['average_rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: (json['reviewsCount'] ?? json['reviews_count'] ?? json['review_count'] as num?)?.toInt() ?? 0,
      imageUrl: img,
      transmission: (json['transmission'] ?? 'Automatic').toString(),
      fuelType: (json['fuelType'] ?? json['fuel_type'] ?? 'Petrol').toString(),
      seats: (json['seats'] as num?)?.toInt() ?? 5,
      partnerId: (json['partnerId'] ?? json['partner_id'] ?? json['provider_id'] ?? json['vendor_id'] ?? '').toString(),
      partnerName: (json['partnerName'] ?? json['partner_name'] ?? json['provider_name'] ?? json['vendor_name'] ?? 'Velix Verified Partner').toString(),
      partnerAvatar: (json['partnerAvatar'] ?? json['partner_avatar'] ?? json['provider_avatar'] ?? '').toString(),
      isFavorite: json['isFavorite'] ?? json['is_favorite'] ?? false,
      isAvailable: isAvail,
      location: locationStr,
      features: parsedFeatures,
      galleryImages: parsedGallery,
      videoUrl: vid != null && vid.toString().isNotEmpty ? vid.toString() : null,
      unavailableDates: List<String>.from(unavail.map((u) => u.toString())),
      licensePlate: json['licensePlate'] ?? json['license_plate'] ?? json['plate_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price_per_day': pricePerDay,
      'pricePerDay': pricePerDay,
      'rating': rating,
      'reviews_count': reviewsCount,
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'transmission': transmission,
      'fuel_type': fuelType,
      'seats': seats,
      'partner_id': partnerId,
      'partnerId': partnerId,
      'partner_name': partnerName,
      'partner_avatar': partnerAvatar,
      'is_favorite': isFavorite,
      'is_available': isAvailable,
      'location': location,
      'features': features,
      'gallery_images': galleryImages,
      'video_url': videoUrl,
      'unavailable_dates': unavailableDates,
      'license_plate': licensePlate,
      'licensePlate': licensePlate,
    };
  }

  CarModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    double? pricePerDay,
    double? rating,
    int? reviewsCount,
    String? imageUrl,
    String? transmission,
    String? fuelType,
    int? seats,
    String? partnerId,
    String? partnerName,
    String? partnerAvatar,
    bool? isFavorite,
    bool? isAvailable,
    String? location,
    List<String>? features,
    List<String>? galleryImages,
    String? videoUrl,
    List<String>? unavailableDates,
    String? licensePlate,
  }) {
    return CarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      seats: seats ?? this.seats,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerAvatar: partnerAvatar ?? this.partnerAvatar,
      isFavorite: isFavorite ?? this.isFavorite,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      features: features ?? this.features,
      galleryImages: galleryImages ?? this.galleryImages,
      videoUrl: videoUrl ?? this.videoUrl,
      unavailableDates: unavailableDates ?? this.unavailableDates,
      licensePlate: licensePlate ?? this.licensePlate,
    );
  }

  static List<CarModel> get sampleCars => [
    CarModel(
      id: 'car_01',
      name: 'Mercedes-Benz GLE 450',
      brand: 'Mercedes-Benz',
      category: 'SUV',
      pricePerDay: 85000.0,
      rating: 4.9,
      reviewsCount: 48,
      imageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seats: 5,
      partnerId: 'prv_101',
      partnerName: 'Lekki Executive Motors',
      partnerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      location: 'Lekki Phase 1, Lagos',
      features: ['Panoramic Sunroof', '4MATIC AWD', 'Burmester Sound', '360 Camera', 'Leather Seats'],
      galleryImages: [
        'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85',
        'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
      ],
    ),
    CarModel(
      id: 'car_02',
      name: 'Toyota Camry V6 2023',
      brand: 'Toyota',
      category: 'SEDAN',
      pricePerDay: 35000.0,
      rating: 4.8,
      reviewsCount: 32,
      imageUrl: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=1200&q=85',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seats: 5,
      partnerId: 'prv_102',
      partnerName: 'Victoria Island Mobility',
      partnerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      location: 'Victoria Island, Lagos',
      features: ['Apple CarPlay', 'Adaptive Cruise Control', 'Lane Keep Assist', 'Chilling AC'],
      galleryImages: [
        'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=1200&q=85',
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=800&q=80',
      ],
    ),
    CarModel(
      id: 'car_03',
      name: 'Range Rover Velar R-Dynamic',
      brand: 'Land Rover',
      category: 'LUXURY',
      pricePerDay: 120000.0,
      rating: 5.0,
      reviewsCount: 26,
      imageUrl: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seats: 5,
      partnerId: 'prv_103',
      partnerName: 'Ikoyi Chauffeur Fleet',
      partnerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      location: 'Ikoyi, Lagos',
      features: ['Meridian Surround', 'Heated Seats', 'Terrain Response 2', 'Air Suspension'],
      galleryImages: [
        'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85',
        'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80',
      ],
    ),
    CarModel(
      id: 'car_04',
      name: 'Tesla Model 3 Dual Motor',
      brand: 'Tesla',
      category: 'ELECTRIC',
      pricePerDay: 75000.0,
      rating: 4.9,
      reviewsCount: 19,
      imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=85',
      transmission: 'Automatic',
      fuelType: 'Electric',
      seats: 5,
      partnerId: 'prv_104',
      partnerName: 'EcoRide Nigeria',
      partnerAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      location: 'Ikeja GRA, Lagos',
      features: ['Autopilot', '15-inch Touchscreen', 'Glass Roof', 'Instant Acceleration'],
      galleryImages: [
        'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=85',
      ],
    ),
    CarModel(
      id: 'car_05',
      name: 'Lexus RX 350 F-Sport',
      brand: 'Lexus',
      category: 'SUV',
      pricePerDay: 65000.0,
      rating: 4.85,
      reviewsCount: 41,
      imageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=85',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seats: 5,
      partnerId: 'prv_105',
      partnerName: 'Maitama Luxury Fleet',
      partnerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
      location: 'Maitama, Abuja',
      features: ['Mark Levinson Audio', 'Power Liftgate', 'Ventilated Seats', 'Blind Spot Monitor'],
      galleryImages: [
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=85',
      ],
    ),
    CarModel(
      id: 'car_06',
      name: 'Porsche 911 Carrera Cabriolet',
      brand: 'Porsche',
      category: 'SPORTS',
      pricePerDay: 250000.0,
      rating: 5.0,
      reviewsCount: 15,
      imageUrl: 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=85',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seats: 2,
      partnerId: 'prv_106',
      partnerName: 'Abuja Supercar Club',
      partnerAvatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=200&q=80',
      location: 'Central Area, Abuja',
      features: ['Sport Chrono Package', 'PDK Transmission', 'Convertible Soft Top', 'Bose Surround'],
      galleryImages: [
        'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=85',
      ],
    ),
  ];
}
