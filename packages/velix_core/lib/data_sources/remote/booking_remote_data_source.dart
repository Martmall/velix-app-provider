import '../../models/booking_model.dart';
import '../../models/car_model.dart';
import '../../network/api_client.dart';
import 'vehicle_remote_data_source.dart';

/// REST /bookings. The list is scoped server-side by role: a customer gets their own bookings,
/// a partner gets bookings on their vehicles.
class BookingRemoteDataSource {
  final ApiClient _apiClient = ApiClient();
  final VehicleRemoteDataSource _vehicles = VehicleRemoteDataSource();

  // Vehicle details rarely change; cache them for the session so a list refresh doesn't refetch.
  static final Map<String, CarModel> _vehicleCache = {};

  /// Bookings only carry a vehicleId, so name/image/location are joined in from
  /// GET /vehicle-detail -- the same approach as the web app's useEnrichedBookings.
  Future<List<BookingModel>> _withVehicles(List<BookingModel> bookings) async {
    final missing = bookings.map((b) => b.carId).where((id) => id.isNotEmpty && !_vehicleCache.containsKey(id)).toSet();
    await Future.wait(missing.map((id) async {
      try {
        _vehicleCache[id] = await _vehicles.getVehicleById(id);
      } catch (_) {
        // Listing no longer public (e.g. deactivated); the booking still shows, just unnamed.
      }
    }));
    return bookings.map((b) {
      final car = _vehicleCache[b.carId];
      return car != null ? b.withVehicle(car) : b.copyWith(carName: 'Vehicle');
    }).toList();
  }

  Future<List<BookingModel>> getBookings({BookingStatus? status}) async {
    final bookings = <BookingModel>[];
    for (var page = 1; page <= 5; page++) {
      final response = await _apiClient.get('/bookings', queryParameters: {
        if (status != null) 'status': status.name.toUpperCase(),
        'per_page': 100,
        'page': page,
      });
      bookings.addAll(ApiClient.listFrom(response.data).map(BookingModel.fromJson));
      final pagination = response.data is Map ? response.data['pagination'] : null;
      if (pagination is! Map || pagination['next_page'] == null) break;
    }
    return _withVehicles(bookings);
  }

  Future<BookingModel> getBookingById(String id) async {
    final response = await _apiClient.get('/bookings/$id');
    return (await _withVehicles([BookingModel.fromJson(ApiClient.objectFrom(response.data))])).first;
  }

  /// Creates a PENDING booking. The server computes the price (subtotal + fee + tax) and checks
  /// availability; the returned booking carries the authoritative totals.
  Future<BookingModel> createBooking({
    required String vehicleId,
    required String pickupLocationId,
    String? dropoffLocationId,
    required DateTime pickupAt,
    required DateTime dropoffAt,
    String? notes,
  }) async {
    final response = await _apiClient.post('/bookings', data: {
      'vehicleId': vehicleId,
      'pickupLocationId': pickupLocationId,
      if (dropoffLocationId != null && dropoffLocationId != pickupLocationId) 'dropoffLocationId': dropoffLocationId,
      'pickupAt': pickupAt.toUtc().toIso8601String(),
      'dropoffAt': dropoffAt.toUtc().toIso8601String(),
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    return (await _withVehicles([BookingModel.fromJson(ApiClient.objectFrom(response.data))])).first;
  }

  Future<BookingModel> _transition(String id, String action, [Map<String, dynamic>? body]) async {
    final response = await _apiClient.patch('/bookings/$id/$action', data: body);
    return (await _withVehicles([BookingModel.fromJson(ApiClient.objectFrom(response.data))])).first;
  }

  /// Partner accepts a pending request.
  Future<BookingModel> confirmBooking(String id) => _transition(id, 'confirm');

  Future<BookingModel> rejectBooking(String id, {String? reason}) =>
      _transition(id, 'reject', {if (reason != null) 'reason': reason});

  Future<BookingModel> cancelBooking(String id, {String? reason}) =>
      _transition(id, 'cancel', {if (reason != null) 'reason': reason});

  /// Partner hands the vehicle over (CONFIRMED -> ACTIVE).
  Future<BookingModel> startRental(String id) => _transition(id, 'start');

  /// Partner takes the vehicle back (ACTIVE -> COMPLETED).
  Future<BookingModel> completeRental(String id) => _transition(id, 'complete');

  Future<void> assignDriver(String bookingId, String driverId) async {
    await _apiClient.post('/bookings/$bookingId/assign-driver', data: {'driverId': driverId});
  }
}
