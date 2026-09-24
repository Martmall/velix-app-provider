import 'dart:async';
import '../models/car_model.dart';
import '../data_sources/remote/vehicle_remote_data_source.dart';
import '../services/realtime_service.dart';

abstract class IVehicleRepository {
  Future<List<CarModel>> getVehicles({String? category, String? searchQuery, String? location});
  Stream<List<CarModel>> streamVehicles({String? category, String? searchQuery, String? location});
  Future<CarModel?> getVehicleById(String id);
  Future<void> toggleFavorite(String carId);
  Future<List<CarModel>> getFavorites();
}

class RemoteVehicleRepository implements IVehicleRepository {
  final VehicleRemoteDataSource _remote = VehicleRemoteDataSource();
  final VelixRealtimeService _realtime = VelixRealtimeService();

  @override
  Stream<List<CarModel>> streamVehicles({String? category, String? searchQuery, String? location}) async* {
    // 1. Initial snapshot from backend API
    try {
      yield await getVehicles(category: category, searchQuery: searchQuery, location: location);
    } catch (_) {
      yield [];
    }

    // 2. Real-time stream from Supabase
    try {
      final supaStream = _realtime.streamVehicles();
      await for (final rawList in supaStream) {
        if (rawList.isNotEmpty) {
          var mapped = rawList.map((m) => CarModel.fromJson(m)).toList();
          if (category != null && category.isNotEmpty && category != 'All') {
            final cleanCat = category.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
            mapped = mapped.where((c) => c.category.toLowerCase().contains(cleanCat)).toList();
          }
          if (searchQuery != null && searchQuery.trim().isNotEmpty) {
            final q = searchQuery.toLowerCase().trim();
            mapped = mapped.where((c) => c.name.toLowerCase().contains(q) || c.brand.toLowerCase().contains(q) || c.location.toLowerCase().contains(q)).toList();
          }
          yield mapped;
        } else {
          yield await getVehicles(category: category, searchQuery: searchQuery, location: location);
        }
      }
    } catch (_) {
      yield await getVehicles(category: category, searchQuery: searchQuery, location: location);
    }
  }

  @override
  Future<List<CarModel>> getVehicles({String? category, String? searchQuery, String? location}) async {
    return _remote.getVehicles(
      category: category,
      search: searchQuery,
    );
  }

  @override
  Future<CarModel?> getVehicleById(String id) async {
    return _remote.getVehicleById(id);
  }

  @override
  Future<void> toggleFavorite(String carId) async {
    await _remote.toggleFavorite(carId);
  }

  @override
  Future<List<CarModel>> getFavorites() async {
    return _remote.getFavorites();
  }
}
