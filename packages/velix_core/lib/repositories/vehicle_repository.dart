import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';
import '../data_sources/remote/vehicle_remote_data_source.dart';

abstract class IVehicleRepository {
  Future<List<CarModel>> getVehicles({String? category, String? searchQuery, String? location});
  Stream<List<CarModel>> streamVehicles({String? category, String? searchQuery, String? location});
  Future<CarModel?> getVehicleById(String id);
  Future<PriceEstimate> getPriceEstimate(String vehicleId, DateTime start, DateTime end);

  /// Favourites are kept on this device only -- the backend has no favourites API.
  Future<bool> toggleFavorite(String carId);
  Future<List<CarModel>> getFavorites();
  Future<Set<String>> getFavoriteIds();
}

class RemoteVehicleRepository implements IVehicleRepository {
  final VehicleRemoteDataSource _remote = VehicleRemoteDataSource();
  static const _favoritesKey = 'velix_favorite_vehicle_ids';
  static const _refreshInterval = Duration(minutes: 1);

  @override
  Stream<List<CarModel>> streamVehicles({String? category, String? searchQuery, String? location}) async* {
    // Fetch now, then refresh periodically so availability changes show up. Errors propagate so
    // the screen can show them instead of a silently empty list.
    while (true) {
      yield await getVehicles(category: category, searchQuery: searchQuery, location: location);
      await Future<void>.delayed(_refreshInterval);
    }
  }

  @override
  Future<List<CarModel>> getVehicles({String? category, String? searchQuery, String? location}) async {
    final cars = await _remote.getVehicles(category: category, search: searchQuery);
    final favorites = await getFavoriteIds();
    // City filtering is client-side: /vehicle-list has no location filter.
    final city = location?.trim().toLowerCase();
    return cars
        .where((c) => city == null || city.isEmpty || city == 'all locations' || c.location.toLowerCase().contains(city))
        .map((c) => favorites.contains(c.id) ? c.copyWith(isFavorite: true) : c)
        .toList();
  }

  @override
  Future<CarModel?> getVehicleById(String id) async {
    final car = await _remote.getVehicleById(id);
    final favorites = await getFavoriteIds();
    return favorites.contains(car.id) ? car.copyWith(isFavorite: true) : car;
  }

  @override
  Future<PriceEstimate> getPriceEstimate(String vehicleId, DateTime start, DateTime end) =>
      _remote.getPriceEstimate(vehicleId, start, end);

  @override
  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? const []).toSet();
  }

  @override
  Future<bool> toggleFavorite(String carId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_favoritesKey) ?? const []).toSet();
    final nowFavorite = !ids.remove(carId);
    if (nowFavorite) ids.add(carId);
    await prefs.setStringList(_favoritesKey, ids.toList());
    return nowFavorite;
  }

  @override
  Future<List<CarModel>> getFavorites() async {
    final ids = await getFavoriteIds();
    final cars = <CarModel>[];
    for (final id in ids) {
      try {
        cars.add((await _remote.getVehicleById(id)).copyWith(isFavorite: true));
      } catch (_) {
        // The listing was removed or is no longer public; drop it from the list.
      }
    }
    return cars;
  }
}
