import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final SecureStorageService _storage = SecureStorageService();
  bool _isRefreshing = false;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Keep baseUrl synced with AppConfig
          if (options.baseUrl != AppConfig.baseUrl) {
            options.baseUrl = AppConfig.baseUrl;
          }
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Attempt automatic token refresh on 401 Unauthorized
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final refreshToken = await _storage.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                final refreshResponse = await Dio(
                  BaseOptions(baseUrl: AppConfig.baseUrl),
                ).post('/refresh-token', data: {'refresh_token': refreshToken});

                if (refreshResponse.statusCode == 200) {
                  final newAccessToken = refreshResponse.data['data']?['api_token'] ??
                      refreshResponse.data['api_token'];
                  final newRefreshToken = refreshResponse.data['data']?['refresh_token'] ??
                      refreshResponse.data['refresh_token'] ??
                      refreshToken;

                  if (newAccessToken != null) {
                    await _storage.saveToken(newAccessToken);
                    await _storage.saveRefreshToken(newRefreshToken);

                    final retryOptions = error.requestOptions;
                    retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    final clonedResponse = await dio.fetch(retryOptions);
                    _isRefreshing = false;
                    return handler.resolve(clonedResponse);
                  }
                }
              }
            } catch (_) {
              await _storage.clearAll();
            } finally {
              _isRefreshing = false;
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.delete<T>(path, data: data, queryParameters: queryParameters);
  }

  static String parseErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map) {
          if (data['message'] != null) return data['message'].toString();
          if (data['error'] != null) return data['error'].toString();
          if (data['errors'] != null) return data['errors'].toString();
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to Velix server. Please verify your network.';
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          if (status == 401) return 'Authentication required or session expired. Please sign in.';
          if (status == 403) return 'Access denied. You do not have permission for this action.';
          if (status == 404) return 'Requested resource was not found.';
          if (status == 422) return 'Invalid data submitted. Please check your input.';
          if (status == 429) return 'Too many requests. Please try again in a moment.';
          if (status != null && status >= 500) return 'Server error ($status). Please try again later.';
          return 'Request failed with status $status.';
        default:
          return error.message ?? 'An unexpected network error occurred.';
      }
    }
    return error?.toString() ?? 'An unexpected error occurred.';
  }
}
