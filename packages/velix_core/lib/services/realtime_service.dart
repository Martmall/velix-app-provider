import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class VelixRealtimeService {
  static final VelixRealtimeService _instance = VelixRealtimeService._internal();
  factory VelixRealtimeService() => _instance;
  VelixRealtimeService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize({String? url, String? anonKey}) async {
    if (_initialized) return;

    final targetUrl = url ?? SupabaseConfig.supabaseUrl;
    final targetKey = anonKey ?? SupabaseConfig.supabaseAnonKey;

    try {
      await Supabase.initialize(
        url: targetUrl,
        // ignore: deprecated_member_use
        anonKey: targetKey,
        debug: kDebugMode,
      );
      _initialized = true;
      debugPrint('[VelixRealtimeService] Supabase Realtime initialized successfully.');
    } catch (e) {
      debugPrint('[VelixRealtimeService] Supabase initialize warning/error: $e');
    }
  }

  /// Real-time stream of booking status updates for a specific customer
  Stream<List<Map<String, dynamic>>> streamCustomerBookings(String customerId) {
    final supa = client;
    if (supa == null) return const Stream.empty();

    try {
      return supa
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('customer_user_id', customerId)
          .order('created_at', ascending: false)
          .handleError((err) {
            debugPrint('[VelixRealtimeService] streamCustomerBookings suppressed error: $err');
          });
    } catch (e) {
      debugPrint('[VelixRealtimeService] streamCustomerBookings exception: $e');
      return const Stream.empty();
    }
  }

  /// Real-time stream of incoming and active bookings for a fleet partner
  Stream<List<Map<String, dynamic>>> streamPartnerBookings(String partnerId) {
    final supa = client;
    if (supa == null) return const Stream.empty();

    try {
      return supa
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('vendor_id', partnerId)
          .order('created_at', ascending: false)
          .handleError((err) {
            debugPrint('[VelixRealtimeService] streamPartnerBookings suppressed error: $err');
          });
    } catch (e) {
      debugPrint('[VelixRealtimeService] streamPartnerBookings exception: $e');
      return const Stream.empty();
    }
  }

  /// Real-time stream for a single specific booking
  Stream<List<Map<String, dynamic>>> streamSingleBooking(String bookingId) {
    final supa = client;
    if (supa == null) return const Stream.empty();

    try {
      return supa
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('id', bookingId)
          .handleError((err) {
            debugPrint('[VelixRealtimeService] streamSingleBooking suppressed error: $err');
          });
    } catch (e) {
      debugPrint('[VelixRealtimeService] streamSingleBooking exception: $e');
      return const Stream.empty();
    }
  }

  /// Real-time stream of live vehicles / fleet updates
  Stream<List<Map<String, dynamic>>> streamVehicles() {
    final supa = client;
    if (supa == null) return const Stream.empty();

    try {
      return supa
          .from('vehicles')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .handleError((err) {
            debugPrint('[VelixRealtimeService] streamVehicles suppressed error: $err');
          });
    } catch (e) {
      debugPrint('[VelixRealtimeService] streamVehicles exception: $e');
      return const Stream.empty();
    }
  }

  /// Real-time stream of user notifications
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    final supa = client;
    if (supa == null) return const Stream.empty();

    try {
      return supa
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .handleError((err) {
            debugPrint('[VelixRealtimeService] streamNotifications suppressed error: $err');
          });
    } catch (e) {
      debugPrint('[VelixRealtimeService] streamNotifications exception: $e');
      return const Stream.empty();
    }
  }

  /// Real-time stream of chat/support messages
  Stream<List<Map<String, dynamic>>> streamChatMessages(String bookingId) {
    final supa = client;
    if (supa == null) return const Stream.empty();

    try {
      return supa
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('booking_id', bookingId)
          .order('created_at', ascending: true)
          .handleError((err) {
            debugPrint('[VelixRealtimeService] streamChatMessages suppressed error: $err');
          });
    } catch (e) {
      debugPrint('[VelixRealtimeService] streamChatMessages exception: $e');
      return const Stream.empty();
    }
  }

  /// Real-time stream of disputes for partners and users
  Stream<List<Map<String, dynamic>>> streamDisputes({String? partnerId, String? userId}) {
    final supa = client;
    if (supa == null) return const Stream.empty();

    try {
      var query = supa.from('disputes').stream(primaryKey: ['id']);
      if (partnerId != null && partnerId.isNotEmpty) {
        query = query.eq('partner_id', partnerId);
      } else if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      return query.order('created_at', ascending: false).handleError((err) {
        debugPrint('[VelixRealtimeService] streamDisputes suppressed error: $err');
      });
    } catch (e) {
      debugPrint('[VelixRealtimeService] streamDisputes exception: $e');
      return const Stream.empty();
    }
  }
}
