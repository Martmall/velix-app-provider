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

  List<CarModel> _filterVehicles(List<CarModel> list, String? category, String? searchQuery, String? location) {
    var result = list;
    if (category != null && category.isNotEmpty && category != 'All') {
      final cleanCat = category.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
      result = result.where((c) {
        final catLower = c.category.toLowerCase();
        return catLower.contains(cleanCat) || cleanCat.contains(catLower);
      }).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((c) => c.name.toLowerCase().contains(q) || c.brand.toLowerCase().contains(q) || c.location.toLowerCase().contains(q)).toList();
    }
    if (location != null && location.trim().isNotEmpty && location != 'All Locations') {
      final loc = location.toLowerCase().trim();
      result = result.where((c) => c.location.toLowerCase().contains(loc)).toList();
    }
    return result;
  }

  @override
  Stream<List<CarModel>> streamVehicles({String? category, String? searchQuery, String? location}) async* {
    // 1. Initial snapshot from backend API (with sampleCars fallback)
    try {
      final initial = await getVehicles(category: category, searchQuery: searchQuery, location: location);
      yield initial;
    } catch (_) {
      yield _filterVehicles(CarModel.sampleCars, category, searchQuery, location);
    }

    // 2. Real-time stream from Supabase
    try {
      final supaStream = _realtime.streamVehicles();
      await for (final rawList in supaStream) {
        if (rawList.isNotEmpty) {
          var mapped = rawList.map((m) => CarModel.fromJson(m)).toList();
          yield _filterVehicles(mapped, category, searchQuery, location);
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
    try {
      final remoteList = await _remote.getVehicles(
        category: category,
        search: searchQuery,
      );
      if (remoteList.isNotEmpty) {
        return _filterVehicles(remoteList, category, searchQuery, location);
      }
    } catch (_) {}
    return _filterVehicles(CarModel.sampleCars, category, searchQuery, location);
  }

  @override
  Future<CarModel?> getVehicleById(String id) async {
    try {
      return await _remote.getVehicleById(id);
    } catch (_) {
      final sample = CarModel.sampleCars.where((c) => c.id == id).toList();
      return sample.isNotEmpty ? sample.first : CarModel.sampleCars.first;
    }
  }

  @override
  Future<void> toggleFavorite(String carId) async {
    await _remote.toggleFavorite(carId);
  }

  @override
  Future<List<CarModel>> getFavorites() async {
    try {
      final favs = await _remote.getFavorites();
      if (favs.isNotEmpty) return favs;
    } catch (_) {}
    return [CarModel.sampleCars[0], CarModel.sampleCars[2]];
  }
}
