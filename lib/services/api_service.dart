import 'package:dio/dio.dart';

class ApiService {
  // Base URL untuk endpoint API
  final String baseUrl;
  final Dio _dio;

  ApiService({required this.baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
        ));

  // Fungsi GET untuk mengambil data
  Future<Response?> getRequest(String endpoint,
      {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return response;
    } catch (error) {
      print('Error GET $endpoint: $error');
      return null;
    }
  }

  // Fungsi POST untuk mengirim data
  Future<Response?> postRequest(String endpoint, Map<String, dynamic> data,
      {Map<String, dynamic>? headers}) async {
    final response = await _dio.post(
      endpoint,
      data: data,
      options: Options(
        headers: headers ?? {},
      ),
    );
    return response;
  }

  // Fungsi PUT untuk update data
  Future<Response?> putRequest(String endpoint, Map<String, dynamic> data,
      {Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(
          headers: headers ?? {},
        ),
      );
      return response;
    } catch (error) {
      print('Error PUT $endpoint: $error');
      return null;
    }
  }

  // Fungsi DELETE untuk menghapus data
  Future<Response?> deleteRequest(String endpoint,
      {Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(
          headers: headers ?? {},
        ),
      );
      return response;
    } catch (error) {
      print('Error DELETE $endpoint: $error');
      return null;
    }
  }

  // Fungsi khusus untuk handling request dengan autentikasi token
  Future<Response?> authenticatedRequest(String endpoint, String token,
      {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: params,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (error) {
      print('Error Authenticated GET $endpoint: $error');
      return null;
    }
  }
}
