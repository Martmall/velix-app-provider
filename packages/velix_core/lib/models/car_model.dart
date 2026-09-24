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
}
