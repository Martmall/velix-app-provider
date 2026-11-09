import 'dart:async';
import '../models/car_model.dart';
import '../network/upload_file.dart';
import '../data_sources/remote/vehicle_remote_data_source.dart';

/// A partner's own listings. Every call is scoped server-side to the signed-in partner.
abstract class IFleetRepository {
  Future<List<CarModel>> getPartnerVehicles();
  Stream<List<CarModel>> streamPartnerVehicles();
  Future<CarModel> addVehicle(VehicleDraft draft, {List<UploadFile> photos = const []});
  Future<CarModel> uploadPhotos(String vehicleId, List<UploadFile> photos);
  /// 'AVAILABLE' | 'UNAVAILABLE' | 'MAINTENANCE' | 'INACTIVE'
  Future<void> setVehicleStatus(String vehicleId, String status);
  Future<void> removeVehicle(String vehicleId);
}

class RemoteFleetRepository implements IFleetRepository {
  final VehicleRemoteDataSource _remote = VehicleRemoteDataSource();
  static const _refreshInterval = Duration(minutes: 1);

  @override
  Stream<List<CarModel>> streamPartnerVehicles() async* {
    while (true) {
      yield await getPartnerVehicles();
      await Future<void>.delayed(_refreshInterval);
    }
  }

  @override
  Future<List<CarModel>> getPartnerVehicles() => _remote.getPartnerVehicles();

  @override
  Future<CarModel> addVehicle(VehicleDraft draft, {List<UploadFile> photos = const []}) =>
      _remote.addVehicle(draft, photos: photos);

  @override
  Future<CarModel> uploadPhotos(String vehicleId, List<UploadFile> photos) => _remote.uploadPhotos(vehicleId, photos);

  @override
  Future<void> setVehicleStatus(String vehicleId, String status) => _remote.updateStatus(vehicleId, status);

  @override
  Future<void> removeVehicle(String vehicleId) => _remote.removeVehicle(vehicleId);
}
