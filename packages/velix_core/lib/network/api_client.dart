import 'dart:async';
import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../storage/secure_storage_service.dart';

/// An API failure with the backend's own message, ready to show to the user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final SecureStorageService _storage = SecureStorageService();

  /// Shared by every request that hits a 401 while a refresh is in flight, so concurrent
  /// failures trigger exactly one /refresh-token call instead of one each.
  Future<bool>? _refreshing;

  final StreamController<void> _sessionExpired = StreamController<void>.broadcast();

  /// Fires when the refresh token is rejected and the stored session has been cleared. Apps
  /// listen to this to send the user back to sign-in.
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  // Calls that must never trigger a refresh: they either don't need a session or *are* the
  // session exchange, so a 401 from them is a real answer (e.g. wrong password).
  static const _noRefreshPaths = {
    '/login',
    '/register',
    '/refresh-token',
    '/social-login',
    '/verify-registration-otp',
    '/request-login-otp',
    '/verify-login-otp',
  };

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        // Render's free tier and a cold VPS process can take a while on the first request.
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          final request = error.requestOptions;
          final canRefresh = error.response?.statusCode == 401 &&
              !_noRefreshPaths.contains(request.path) &&
              request.extra['retried'] != true;
          if (!canRefresh) return handler.next(error);

          final refreshed = await (_refreshing ??= _refreshSession().whenComplete(() => _refreshing = null));
          if (!refreshed) return handler.next(error);

          try {
            final token = await _storage.getToken();
            request.headers['Authorization'] = 'Bearer $token';
            request.extra['retried'] = true;
            return handler.resolve(await dio.fetch(request));
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        },
      ),
    );
  }

  Future<bool> _refreshSession() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession();
      return false;
    }
    try {
      // A bare Dio, so this call doesn't go through the interceptor above.
      final response = await Dio(BaseOptions(baseUrl: AppConfig.baseUrl))
          .post('/refresh-token', data: {'refresh_token': refreshToken});
      final data = response.data is Map ? response.data['data'] : null;
      final access = data is Map ? data['api_token'] : null;
      final refresh = data is Map ? data['refresh_token'] : null;
      if (access is! String || access.isEmpty) {
        await _expireSession();
        return false;
      }
      await _storage.saveToken(access);
      if (refresh is String && refresh.isNotEmpty) await _storage.saveRefreshToken(refresh);
      return true;
    } on DioException catch (e) {
      // Only a definite rejection ends the session; a network blip shouldn't log the user out.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) await _expireSession();
      return false;
    }
  }

  Future<void> _expireSession() async {
    await _storage.clearAll();
    _sessionExpired.add(null);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _guard(() => dio.get<T>(path, queryParameters: queryParameters));

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _guard(() => dio.post<T>(path, data: data, queryParameters: queryParameters));

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _guard(() => dio.put<T>(path, data: data, queryParameters: queryParameters));

  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _guard(() => dio.patch<T>(path, data: data, queryParameters: queryParameters));

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _guard(() => dio.delete<T>(path, data: data, queryParameters: queryParameters));

  /// Every call surfaces failures as [ApiException] carrying the server's message, so callers
  /// (and the UI) never see a raw DioException.
  Future<Response<T>> _guard<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException(parseErrorMessage(e), statusCode: e.response?.statusCode);
    }
  }

  /// The `data` array of a list response (`{ pagination, data: [...] }`), as maps.
  static List<Map<String, dynamic>> listFrom(dynamic body) {
    final raw = body is Map ? body['data'] : body;
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  /// The `data` object of a single-item response (`{ data: {...} }`).
  static Map<String, dynamic> objectFrom(dynamic body) {
    final raw = body is Map && body['data'] is Map ? body['data'] : body;
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  /// Extracts the most useful message from the backend's error shapes:
  /// `{ error: { message } }`, `{ message }`, `{ error: "..." }`, and validation errors
  /// (`{ all_message: { field: [msg] } }`).
  static String parseErrorMessage(dynamic error) {
    if (error is ApiException) return error.message;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final validation = data['all_message'];
        if (validation is Map && validation.isNotEmpty) {
          final first = validation.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        final nested = data['error'];
        if (nested is Map && nested['message'] != null) return nested['message'].toString();
        if (data['message'] != null) return data['message'].toString();
        if (nested is String && nested.isNotEmpty) return nested;
      } else if (data is String && data.isNotEmpty && data.length < 300) {
        return data;
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to Velix server. Please verify your network.';
        default:
          break;
      }
      final status = error.response?.statusCode;
      if (status == 401) return 'Your session has expired. Please sign in again.';
      if (status == 403) return 'You do not have permission for this action.';
      if (status == 404) return 'Requested resource was not found.';
      if (status == 429) return 'Too many requests. Please try again in a moment.';
      if (status != null && status >= 500) return 'Server error ($status). Please try again later.';
      return error.message ?? 'An unexpected network error occurred.';
    }
    return error?.toString().replaceFirst('Exception: ', '') ?? 'An unexpected error occurred.';
  }
}
