import 'dart:async';
import '../models/booking_model.dart';
import '../data_sources/remote/booking_remote_data_source.dart';
import '../services/realtime_service.dart';

abstract class IBookingRepository {
  Future<BookingModel> createBooking({
    required String carId,
    required String carName,
    required String carImage,
    required String userId,
    required String userName,
    required String partnerId,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    required String dropoffLocation,
    required double totalPrice,
    required String paymentMethod,
  });

  Future<List<BookingModel>> getUserBookings(String userId);
  Stream<List<BookingModel>> streamUserBookings(String userId);
  Future<List<BookingModel>> getPartnerBookings(String partnerId);
  Stream<List<BookingModel>> streamPartnerBookings(String partnerId);
  Future<BookingModel?> getBookingById(String id);
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
  Future<void> toggleKeylessRemote(String bookingId, bool isUnlocked);
}

class RemoteBookingRepository implements IBookingRepository {
  final BookingRemoteDataSource _remote = BookingRemoteDataSource();
  final VelixRealtimeService _realtime = VelixRealtimeService();

  @override
  Stream<List<BookingModel>> streamUserBookings(String userId) async* {
    try {
      yield await getUserBookings(userId);
    } catch (_) {
      yield [];
    }

    try {
      final supaStream = _realtime.streamCustomerBookings(userId);
      await for (final rawList in supaStream) {
        if (rawList.isNotEmpty) {
          yield rawList.map((m) => BookingModel.fromJson(m)).toList();
        } else {
          yield await getUserBookings(userId);
        }
      }
    } catch (_) {
      yield await getUserBookings(userId);
    }
  }

  @override
  Stream<List<BookingModel>> streamPartnerBookings(String partnerId) async* {
    try {
      yield await getPartnerBookings(partnerId);
    } catch (_) {
      yield [];
    }

    try {
      final supaStream = _realtime.streamPartnerBookings(partnerId);
      await for (final rawList in supaStream) {
        if (rawList.isNotEmpty) {
          yield rawList.map((m) => BookingModel.fromJson(m)).toList();
        } else {
          yield await getPartnerBookings(partnerId);
        }
      }
    } catch (_) {
      yield await getPartnerBookings(partnerId);
    }
  }

  @override
  Future<BookingModel> createBooking({
    required String carId,
    required String carName,
    required String carImage,
    required String userId,
    required String userName,
    required String partnerId,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    required String dropoffLocation,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    final booking = BookingModel(
      id: 'VLX-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}-NG',
      carId: carId,
      carName: carName,
      carImage: carImage,
      userId: userId,
      userName: userName,
      partnerId: partnerId,
      startDate: startDate,
      endDate: endDate,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      totalPrice: totalPrice,
      status: BookingStatus.confirmed,
      paymentMethod: paymentMethod,
    );

    return _remote.createBooking(booking);
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final list = await _remote.getBookings(userId: userId);
    return list.where((b) => b.userId == userId || userId.isEmpty).toList();
  }

  @override
  Future<List<BookingModel>> getPartnerBookings(String partnerId) async {
    final list = await _remote.getBookings(partnerId: partnerId);
    return list.where((b) => b.partnerId == partnerId || partnerId.isEmpty).toList();
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    return _remote.getBookingById(id);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    if (status == BookingStatus.active) {
      await _remote.verifyPickup(bookingId);
    } else if (status == BookingStatus.completed) {
      await _remote.verifyReturn(bookingId);
    }
  }

  @override
  Future<void> toggleKeylessRemote(String bookingId, bool isUnlocked) async {
    await _remote.toggleKeyless(bookingId, isUnlocked);
  }
}
