import '../config/environment.dart';

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
  /// The listing's pickup location -- POST /bookings needs it as `pickupLocationId`.
  final String? locationId;
  final int? year;
  final String? description;

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
    this.locationId,
    this.year,
    this.description,
  });

  /// Parses the backend's vehicle shape (GET /vehicle-list, /vehicle-detail, /provider-vehicles).
  /// Missing values stay empty/zero rather than being invented, so the UI never shows a price,
  /// rating or feature a partner didn't actually list.
  factory CarModel.fromJson(Map<String, dynamic> json) {
    final brand = (json['make'] ?? '').toString();
    final model = (json['model'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final name = title.isNotEmpty ? title : (brand.isNotEmpty ? '$brand $model'.trim() : 'Vehicle');
    final category = (json['category'] ?? '').toString().toUpperCase();

    final images = (json['images'] is List)
        ? (json['images'] as List).map((u) => AppConfig.resolveUrl(u.toString())).toList()
        : <String>[];
    final mainImage = json['main_image'] != null ? AppConfig.resolveUrl(json['main_image'].toString()) : null;
    final img = mainImage ?? (images.isNotEmpty ? images.first : _getDefaultCarImage(name, brand, category));

    final location = json['location'] is Map ? json['location'] as Map : null;
    final address = location?['address']?.toString() ?? '';
    final city = location?['city']?.toString() ?? '';
    final locationStr = [address, city].where((part) => part.isNotEmpty).join(', ');

    final status = (json['status'] ?? '').toString().toUpperCase();

    return CarModel(
      id: (json['id'] ?? '').toString(),
      name: name,
      brand: brand,
      category: category,
      pricePerDay: (json['daily_rate'] as num?)?.toDouble() ?? 0.0,
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['review_count'] as num?)?.toInt() ?? 0,
      imageUrl: img,
      transmission: _titleCase((json['transmission'] ?? '').toString()),
      fuelType: _titleCase((json['fuel_type'] ?? '').toString()),
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      partnerId: (json['provider_id'] ?? '').toString(),
      partnerName: (json['provider_name'] ?? '').toString(),
      partnerAvatar: '',
      isAvailable: status == 'AVAILABLE',
      location: locationStr,
      features: (json['features'] is List)
          ? (json['features'] as List).map((f) => f.toString()).where((f) => f.isNotEmpty).toList()
          : const [],
      galleryImages: images.isNotEmpty ? images : [img],
      licensePlate: json['plate_number']?.toString(),
      locationId: location?['id']?.toString(),
      year: (json['year'] as num?)?.toInt(),
      description: json['description']?.toString(),
    );
  }

  static String _titleCase(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1).toLowerCase();

  static String _getDefaultCarImage(String name, String brand, String category) {
    final nameLower = name.toLowerCase();
    final brandLower = brand.toLowerCase();
    final catLower = category.toLowerCase();

    if (brandLower.contains('mercedes') || nameLower.contains('benz') || nameLower.contains('gle') || nameLower.contains('c-class') || nameLower.contains('s-class')) {
      return 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85';
    } else if (brandLower.contains('toyota') || nameLower.contains('camry') || nameLower.contains('venza') || nameLower.contains('land cruiser') || nameLower.contains('corolla')) {
      return 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=1200&q=85';
    } else if (brandLower.contains('range') || brandLower.contains('land rover') || nameLower.contains('velar') || catLower.contains('luxury')) {
      return 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85';
    } else if (brandLower.contains('tesla') || catLower.contains('electric')) {
      return 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=85';
    } else if (brandLower.contains('bmw')) {
      return 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1200&q=85';
    } else if (brandLower.contains('porsche') || catLower.contains('sports')) {
      return 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=85';
    } else if (catLower.contains('suv')) {
      return 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=85';
    }
    return 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85';
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
    String? locationId,
    int? year,
    String? description,
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
      locationId: locationId ?? this.locationId,
      year: year ?? this.year,
      description: description ?? this.description,
    );
  }
}
