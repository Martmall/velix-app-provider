import 'dart:async';
import '../models/booking_model.dart';
import '../models/car_model.dart';
import '../network/api_client.dart';
import '../data_sources/remote/booking_remote_data_source.dart';

/// Booking lifecycle (booking.service.ts):
///   customer creates -> PENDING -> partner confirms -> CONFIRMED (or REJECTED)
///   -> partner starts at pickup -> ACTIVE -> partner completes at return -> COMPLETED.
/// Either party can cancel before the rental starts.
abstract class IBookingRepository {
  Future<BookingModel> createBooking({
    required CarModel car,
    required DateTime pickupAt,
    required DateTime dropoffAt,
    String? notes,
  });

  /// The signed-in user's bookings: their own as a customer, or those on their vehicles as a
  /// partner (scoped by the backend).
  Future<List<BookingModel>> getMyBookings();
  Stream<List<BookingModel>> streamMyBookings();
  Future<BookingModel> getBookingById(String id);

  Future<BookingModel> confirmBooking(String id);
  Future<BookingModel> rejectBooking(String id, {String? reason});
  Future<BookingModel> cancelBooking(String id, {String? reason});
  Future<BookingModel> startRental(String id);
  Future<BookingModel> completeRental(String id);
}

class RemoteBookingRepository implements IBookingRepository {
  final BookingRemoteDataSource _remote = BookingRemoteDataSource();
  static const _refreshInterval = Duration(seconds: 30);

  @override
  Future<BookingModel> createBooking({
    required CarModel car,
    required DateTime pickupAt,
    required DateTime dropoffAt,
    String? notes,
  }) {
    final locationId = car.locationId;
    if (locationId == null || locationId.isEmpty) {
      throw ApiException('This vehicle has no pickup location yet, so it can\'t be booked.');
    }
    return _remote.createBooking(
      vehicleId: car.id,
      pickupLocationId: locationId,
      pickupAt: pickupAt,
      dropoffAt: dropoffAt,
      notes: notes,
    );
  }

  @override
  Future<List<BookingModel>> getMyBookings() async {
    final bookings = await _remote.getBookings();
    bookings.sort((a, b) => b.startDate.compareTo(a.startDate));
    return bookings;
  }

  /// Polls instead of a realtime subscription: the bookings live in the backend's Postgres,
  /// which isn't wired to Supabase Realtime.
  @override
  Stream<List<BookingModel>> streamMyBookings() async* {
    while (true) {
      yield await getMyBookings();
      await Future<void>.delayed(_refreshInterval);
    }
  }

  @override
  Future<BookingModel> getBookingById(String id) => _remote.getBookingById(id);

  @override
  Future<BookingModel> confirmBooking(String id) => _remote.confirmBooking(id);

  @override
  Future<BookingModel> rejectBooking(String id, {String? reason}) => _remote.rejectBooking(id, reason: reason);

  @override
  Future<BookingModel> cancelBooking(String id, {String? reason}) => _remote.cancelBooking(id, reason: reason);

  @override
  Future<BookingModel> startRental(String id) => _remote.startRental(id);

  @override
  Future<BookingModel> completeRental(String id) => _remote.completeRental(id);
}
