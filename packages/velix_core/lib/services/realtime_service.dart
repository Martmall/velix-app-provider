import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Initialises the Supabase client (used for Google OAuth). Booking/vehicle/notification data
/// does NOT come from Supabase tables: it lives in the backend's own Postgres and is read through
/// the REST API, so the old Supabase Realtime table streams were removed.
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
}
