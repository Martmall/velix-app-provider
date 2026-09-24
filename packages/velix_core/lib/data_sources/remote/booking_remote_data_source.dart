import '../../models/booking_model.dart';
import '../../network/api_client.dart';

class BookingRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<BookingModel>> getBookings({String? userId, String? partnerId}) async {
    try {
      final response = await _apiClient.get('/booking-list', queryParameters: {
        if (userId != null) 'customer_id': userId,
        if (partnerId != null) 'provider_id': partnerId,
        'per_page': 'all',
      });
      final List list = response.data['data'] ?? [];
      return list.map((json) => BookingModel.fromJson(json)).toList();
    } catch (_) {
      final response = await _apiClient.get('/bookings', queryParameters: {
        if (userId != null) 'userId': userId,
        if (partnerId != null) 'partnerId': partnerId,
      });
      final List list = response.data['data'] ?? [];
      return list.map((json) => BookingModel.fromJson(json)).toList();
    }
  }

  Future<BookingModel> getBookingById(String id) async {
    try {
      final response = await _apiClient.get('/booking-detail', queryParameters: {'booking_id': id});
      return BookingModel.fromJson(response.data['data'] ?? response.data);
    } catch (_) {
      final response = await _apiClient.get('/bookings/$id');
      return BookingModel.fromJson(response.data['data'] ?? response.data);
    }
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _apiClient.post('/booking-save', data: booking.toJson());
      return BookingModel.fromJson(response.data['data'] ?? response.data);
    } catch (_) {
      final response = await _apiClient.post('/bookings', data: booking.toJson());
      return BookingModel.fromJson(response.data['data'] ?? response.data);
    }
  }

  Future<BookingModel> confirmBooking(String id) async {
    final response = await _apiClient.patch('/bookings/$id/confirm');
    return BookingModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<BookingModel> rejectBooking(String id) async {
    final response = await _apiClient.patch('/bookings/$id/reject');
    return BookingModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<BookingModel> cancelBooking(String id, {String? reason}) async {
    final response = await _apiClient.patch('/bookings/$id/cancel', data: {
      if (reason != null) 'reason': reason,
    });
    return BookingModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<bool> toggleKeyless(String id, bool isUnlocked) async {
    try {
      final response = await _apiClient.post('/bookings/$id/keyless-toggle', data: {
        'isUnlocked': isUnlocked,
      });
      return response.data['isKeylessUnlocked'] ?? isUnlocked;
    } catch (_) {
      return isUnlocked;
    }
  }

  Future<BookingModel> verifyPickup(String id, {String? otp}) async {
    final response = await _apiClient.patch('/bookings/$id/start', data: {
      if (otp != null) 'otp': otp,
    });
    return BookingModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<BookingModel> verifyReturn(String id) async {
    final response = await _apiClient.patch('/bookings/$id/complete');
    return BookingModel.fromJson(response.data['data'] ?? response.data);
  }
}
