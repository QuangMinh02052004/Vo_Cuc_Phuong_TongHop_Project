import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;
  ApiException(this.message, {this.statusCode, this.data});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (e, handler) {
        final msg = _extractMessage(e);
        handler.reject(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: ApiException(msg,
              statusCode: e.response?.statusCode, data: e.response?.data),
        ));
      },
    ));
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;
  Dio get dio => _dio;

  static String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? e.message ?? 'Lỗi kết nối')
          .toString();
    }
    return e.message ?? 'Lỗi kết nối';
  }

  Options? _opt(String? token) {
    if (token == null || token.isEmpty) return null;
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<dynamic> get(String url,
      {Map<String, dynamic>? query, String? token}) async {
    try {
      final r =
          await _dio.get(url, queryParameters: query, options: _opt(token));
      return r.data;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Lỗi');
    }
  }

  Future<dynamic> post(String url,
      {dynamic body, Map<String, dynamic>? query, String? token}) async {
    try {
      final r = await _dio.post(url,
          data: body, queryParameters: query, options: _opt(token));
      return r.data;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Lỗi');
    }
  }

  Future<dynamic> patch(String url, {dynamic body, String? token}) async {
    try {
      final r = await _dio.patch(url, data: body, options: _opt(token));
      return r.data;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Lỗi');
    }
  }

  Future<dynamic> delete(String url, {dynamic body, String? token}) async {
    try {
      final r = await _dio.delete(url, data: body, options: _opt(token));
      return r.data;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Lỗi');
    }
  }
}
