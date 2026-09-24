import 'dart:async';
import '../models/car_model.dart';
import '../data_sources/remote/vehicle_remote_data_source.dart';
import '../services/realtime_service.dart';

abstract class IFleetRepository {
  Future<List<CarModel>> getPartnerVehicles(String partnerId);
  Stream<List<CarModel>> streamPartnerVehicles(String partnerId);
  Future<CarModel> addVehicle(CarModel car);
  Future<void> removeVehicle(String vehicleId);
}

class RemoteFleetRepository implements IFleetRepository {
  final VehicleRemoteDataSource _remote = VehicleRemoteDataSource();
  final VelixRealtimeService _realtime = VelixRealtimeService();

  @override
  Stream<List<CarModel>> streamPartnerVehicles(String partnerId) async* {
    yield await getPartnerVehicles(partnerId);

    try {
      final supaStream = _realtime.streamVehicles();
      await for (final rawList in supaStream) {
        if (rawList.isNotEmpty) {
          final mapped = rawList
              .map((m) => CarModel.fromJson(m))
              .where((c) => c.partnerId == partnerId || partnerId.isEmpty)
              .toList();
          yield mapped.isNotEmpty ? mapped : await getPartnerVehicles(partnerId);
        } else {
          yield await getPartnerVehicles(partnerId);
        }
      }
    } catch (_) {
      yield await getPartnerVehicles(partnerId);
    }
  }

  @override
  Future<List<CarModel>> getPartnerVehicles(String partnerId) async {
    try {
      final cars = await _remote.getPartnerVehicles();
      return cars.where((c) => c.partnerId == partnerId || partnerId.isEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<CarModel> addVehicle(CarModel car) async {
    return await _remote.addVehicle(car);
  }

  @override
  Future<void> removeVehicle(String vehicleId) async {
    // Soft remove or call backend
  }
}

class MockFleetRepository extends RemoteFleetRepository {}


