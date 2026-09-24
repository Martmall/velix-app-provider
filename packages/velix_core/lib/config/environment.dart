import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

enum VelixEnvironment { mock, development, production }

class AppConfig {
  static VelixEnvironment environment = VelixEnvironment.production;

  static const String liveHost = 'https://velix-backend-a4jx.onrender.com';
  static const String localHost = 'http://localhost:8000';
  static const String androidLocalHost = 'http://10.0.2.2:8000';

  static bool get isMock => environment == VelixEnvironment.mock;
  static bool get isDev => environment == VelixEnvironment.development;
  static bool get isProd => environment == VelixEnvironment.production;

  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (customUrl.isNotEmpty) return customUrl;

    if (environment == VelixEnvironment.mock) {
      return 'http://mock.velix.internal/api/v1';
    }

    if (environment == VelixEnvironment.development) {
      if (kIsWeb) {
        return '$localHost/api';
      }
      try {
        if (Platform.isAndroid) {
          return '$androidLocalHost/api';
        }
      } catch (_) {}
      return '$localHost/api';
    }

    return '$liveHost/api';
  }

  static String get serverHost {
    if (environment == VelixEnvironment.development) {
      if (kIsWeb) return localHost;
      try {
        if (Platform.isAndroid) return androidLocalHost;
      } catch (_) {}
      return localHost;
    }
    return liveHost;
  }
}
