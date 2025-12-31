import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

/// API客户端
class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;
  final StorageService _storage = StorageService();

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.current.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// 设置拦截器
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证Token
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (EnvConfig.current.enableLog) {
          debugPrint('[API] ${options.method} ${options.path}');
          if (options.data != null) {
            debugPrint('[API] Body: ${options.data}');
          }
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        if (EnvConfig.current.enableLog) {
          debugPrint('[API] Response: ${response.statusCode}');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (EnvConfig.current.enableLog) {
          debugPrint('[API] Error: ${error.message}');
        }

        // 处理Token过期
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // 重试原请求
            final opts = error.requestOptions;
            final token = await _storage.getAccessToken();
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              handler.resolve(response);
              return;
            } catch (e) {
              handler.reject(error);
              return;
            }
          }
        }

        handler.next(error);
      },
    ));
  }

  /// 刷新Token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/token/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.data['code'] == 0) {
        final data = response.data['data'];
        await _storage.saveTokens(
          data['accessToken'],
          data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[API] Refresh token failed: $e');
      return false;
    }
  }

  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 上传文件
  Future<ApiResponse<T>> upload<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?extraData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 处理错误
  ApiResponse<T> _handleError<T>(DioException e) {
    String message;
    int code;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        code = 10000;
        message = '网络连接超时';
        break;
      case DioExceptionType.connectionError:
        code = 10000;
        message = '网络连接失败';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.data is Map) {
          code = e.response?.data['code'] ?? 10000;
          message = e.response?.data['message'] ?? '请求失败';
        } else {
          code = e.response?.statusCode ?? 10000;
          message = '请求失败 (${e.response?.statusCode})';
        }
        break;
      default:
        code = 10000;
        message = '网络请求失败';
    }

    return ApiResponse<T>(
      code: code,
      message: message,
      data: null,
    );
  }

  /// 清理Token（登出时调用）
  Future<void> clearAuth() async {
    await _storage.clearTokens();
  }
}
