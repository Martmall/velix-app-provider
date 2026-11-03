import 'package:dio/dio.dart';
import '../../models/car_model.dart';
import '../../network/api_client.dart';
import '../../network/upload_file.dart';

/// The backend's VehicleCategory enum (schema.prisma).
const vehicleCategories = ['SEDAN', 'SUV', 'HATCHBACK', 'LUXURY', 'VAN_MINIBUS', 'PICKUP_TRUCK'];

/// Maps a UI label ("SUV", "Van / Minibus", "Luxury Cars") to a backend category, or null when
/// it doesn't correspond to one (e.g. "All").
String? toVehicleCategory(String? label) {
  if (label == null) return null;
  final normalized = label.toUpperCase().replaceAll(RegExp(r'[^A-Z]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  if (vehicleCategories.contains(normalized)) return normalized;
  for (final category in vehicleCategories) {
    if (normalized.startsWith(category) || category.startsWith(normalized)) return category;
  }
  return null;
}

/// What a partner fills in to list a vehicle (POST /vehicle-save).
class VehicleDraft {
  /// Set when editing an existing listing (POST /vehicle-save updates it in place).
  final String? id;
  final String title;
  final String make;
  final String model;
  final int year;
  final double dailyRate;
  final String category;
  final int? seats;
  final String? transmission;
  final String? fuelType;
  final String? plateNumber;
  final String? color;
  final String? description;
  final String address;
  final String? city;
  final String? state;
  final List<String> features;

  VehicleDraft({
    this.id,
    required this.title,
    required this.make,
    required this.model,
    required this.year,
    required this.dailyRate,
    required this.category,
    required this.address,
    this.seats,
    this.transmission,
    this.fuelType,
    this.plateNumber,
    this.color,
    this.description,
    this.city,
    this.state,
    this.features = const [],
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'make': make,
        'model': model,
        'year': year,
        'daily_rate': dailyRate,
        'category': toVehicleCategory(category) ?? 'SEDAN',
        if (seats != null) 'seats': seats,
        if (transmission != null) 'transmission': transmission!.toLowerCase(),
        if (fuelType != null) 'fuel_type': fuelType!.toLowerCase(),
        if (plateNumber != null && plateNumber!.isNotEmpty) 'plate_number': plateNumber,
        if (color != null && color!.isNotEmpty) 'color': color,
        if (description != null && description!.isNotEmpty) 'description': description,
        'location': {
          'address': address,
          if (city != null && city!.isNotEmpty) 'city': city,
          if (state != null && state!.isNotEmpty) 'state': state,
          'country': 'Nigeria',
        },
        if (features.isNotEmpty) 'features': features,
      };
}

/// GET /vehicle-price-estimate: the base rental price. Service fee and tax are added when the
/// booking is created (see BookingModel's breakdown).
class PriceEstimate {
  final int days;
  final double basePrice;
  final double dailyRate;
  final bool available;
  PriceEstimate({required this.days, required this.basePrice, required this.dailyRate, required this.available});

  factory PriceEstimate.fromJson(Map<String, dynamic> json) => PriceEstimate(
        days: (json['days'] as num?)?.toInt() ?? 0,
        basePrice: (json['total'] as num?)?.toDouble() ?? 0,
        dailyRate: (json['daily_rate'] as num?)?.toDouble() ?? 0,
        available: json['available'] != false,
      );
}

class VehicleRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  // The backend caps per_page at 100; walk the pages up to a sane limit.
  static const _pageSize = 100;
  static const _maxPages = 5;

  Future<List<CarModel>> _allPages(String path, Map<String, dynamic> query) async {
    final cars = <CarModel>[];
    for (var page = 1; page <= _maxPages; page++) {
      final response = await _apiClient.get(path, queryParameters: {...query, 'per_page': _pageSize, 'page': page});
      cars.addAll(ApiClient.listFrom(response.data).map(CarModel.fromJson));
      final pagination = response.data is Map ? response.data['pagination'] : null;
      if (pagination is! Map || pagination['next_page'] == null) break;
    }
    return cars;
  }

  Future<List<CarModel>> getVehicles({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? partnerId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final backendCategory = toVehicleCategory(category);
    return _allPages('/vehicle-list', {
      if (backendCategory != null) 'category': backendCategory,
      if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (partnerId != null) 'provider_id': partnerId,
      if (startDate != null) 'start_date': startDate.toUtc().toIso8601String(),
      if (endDate != null) 'end_date': endDate.toUtc().toIso8601String(),
    });
  }

  Future<CarModel> getVehicleById(String id) async {
    final response = await _apiClient.get('/vehicle-detail', queryParameters: {'vehicle_id': id});
    return CarModel.fromJson(ApiClient.objectFrom(response.data));
  }

  Future<PriceEstimate> getPriceEstimate(String vehicleId, DateTime start, DateTime end) async {
    final response = await _apiClient.get('/vehicle-price-estimate', queryParameters: {
      'vehicle_id': vehicleId,
      'start_date': start.toUtc().toIso8601String(),
      'end_date': end.toUtc().toIso8601String(),
    });
    return PriceEstimate.fromJson(ApiClient.objectFrom(response.data));
  }

  /// The signed-in partner's own listings (scoped server-side).
  Future<List<CarModel>> getPartnerVehicles() => _allPages('/provider-vehicles', const {});

  /// Creates a listing, then uploads its photos (max 10). Returns the listing with photos.
  Future<CarModel> addVehicle(VehicleDraft draft, {List<UploadFile> photos = const []}) async {
    final response = await _apiClient.post('/vehicle-save', data: draft.toJson());
    final created = CarModel.fromJson(ApiClient.objectFrom(response.data));
    if (photos.isEmpty) return created;
    return uploadPhotos(created.id, photos);
  }

  Future<CarModel> uploadPhotos(String vehicleId, List<UploadFile> photos) async {
    final form = FormData();
    for (final photo in photos.take(10)) {
      form.files.add(MapEntry('photos', await photo.toMultipart()));
    }
    final response = await _apiClient.post('/vehicle-photos/$vehicleId', data: form);
    return CarModel.fromJson(ApiClient.objectFrom(response.data));
  }

  Future<void> updateStatus(String vehicleId, String status) async {
    await _apiClient.post('/vehicle-status-update', data: {'vehicle_id': vehicleId, 'status': status});
  }

  Future<void> removeVehicle(String id) async {
    await _apiClient.post('/vehicle-delete/$id');
  }
}
