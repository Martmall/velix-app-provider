import '../../models/car_model.dart';
import '../../network/api_client.dart';

class VehicleRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<CarModel>> getVehicles({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? partnerId,
  }) async {
    try {
      final response = await _apiClient.get('/vehicle-list', queryParameters: {
        if (category != null && category != 'All') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (partnerId != null) 'provider_id': partnerId,
        'per_page': 100,
      });
      final rawData = response.data;
      List list = [];
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map) {
        list = rawData['data'] ?? rawData['vehicles'] ?? rawData['items'] ?? rawData['cars'] ?? [];
      }
      return list.map((json) => CarModel.fromJson(json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json))).toList();
    } catch (_) {
      // Also attempt /vehicles fallback
      final response = await _apiClient.get('/vehicles', queryParameters: {
        if (category != null && category != 'All') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      final rawData = response.data;
      List list = [];
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map) {
        list = rawData['data'] ?? rawData['vehicles'] ?? rawData['items'] ?? rawData['cars'] ?? [];
      }
      return list.map((json) => CarModel.fromJson(json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json))).toList();
    }
  }

  Future<CarModel> getVehicleById(String id) async {
    try {
      final response = await _apiClient.get('/vehicle-detail', queryParameters: {'vehicle_id': id});
      return CarModel.fromJson(response.data['data'] ?? response.data);
    } catch (_) {
      final response = await _apiClient.get('/vehicles/$id');
      return CarModel.fromJson(response.data['data'] ?? response.data);
    }
  }

  Future<List<CarModel>> getFavorites() async {
    try {
      final response = await _apiClient.get('/user-favorites');
      final List list = response.data['data'] ?? [];
      return list.map((json) => CarModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final response = await _apiClient.post('/save-favorite', data: {'vehicle_id': id});
      return response.data['isFavorite'] ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<List<CarModel>> getPartnerVehicles() async {
    final response = await _apiClient.get('/provider-vehicles');
    final List list = response.data['data'] ?? [];
    return list.map((json) => CarModel.fromJson(json)).toList();
  }

  Future<CarModel> addVehicle(CarModel car) async {
    final response = await _apiClient.post('/vehicle-save', data: {
      'name': car.name,
      'make': car.brand,
      'model': car.name,
      'category': car.category,
      'daily_rate': car.pricePerDay,
      'image': car.imageUrl,
      'transmission': car.transmission,
      'fuel_type': car.fuelType,
      'seats': car.seats,
      'city': car.location,
      'features': car.features,
      'gallery_images': car.galleryImages,
    });
    return CarModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> removeVehicle(String id) async {
    await _apiClient.post('/vehicle-delete/$id');
  }
}
