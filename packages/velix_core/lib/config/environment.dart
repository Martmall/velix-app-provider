import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

enum VelixEnvironment { development, production }

/// Build-time configuration. Everything here comes from `--dart-define`, so one codebase builds
/// for any backend without source edits:
///
///   flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/api
///   flutter run --dart-define=VELIX_ENV=development        # local backend on port 8000
///
/// API_BASE_URL wins over everything else when set.
class AppConfig {
  static const String _envName = String.fromEnvironment('VELIX_ENV', defaultValue: 'production');
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static const VelixEnvironment environment =
      _envName == 'development' ? VelixEnvironment.development : VelixEnvironment.production;

  /// Default production backend, used only when no API_BASE_URL is passed at build time.
  static const String liveHost = 'https://velix-backend-a4jx.onrender.com';
  static const String localHost = 'http://localhost:8000';
  static const String androidLocalHost = 'http://10.0.2.2:8000';

  static bool get isDev => environment == VelixEnvironment.development;
  static bool get isProd => environment == VelixEnvironment.production;

  /// Base URL for API calls, including the `/api` prefix.
  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _stripTrailingSlash(_apiBaseUrlOverride);
    return '$serverHost/api';
  }

  /// Scheme + host (+ port) of the backend, for resolving relative URLs like `/storage/...`.
  static String get serverHost {
    if (_apiBaseUrlOverride.isNotEmpty) return Uri.parse(_apiBaseUrlOverride).origin;
    if (isProd) return liveHost;
    if (kIsWeb) return localHost;
    try {
      if (Platform.isAndroid) return androidLocalHost;
    } catch (_) {}
    return localHost;
  }

  /// Turns a backend-relative path (e.g. `/storage/x.jpg`) into an absolute URL.
  static String resolveUrl(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) return pathOrUrl;
    return '$serverHost${pathOrUrl.startsWith('/') ? '' : '/'}$pathOrUrl';
  }

  static String _stripTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
