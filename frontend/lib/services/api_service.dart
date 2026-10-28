import 'dart:typed_data';

import 'package:dio/dio.dart';

class ApiService {
  // Live Render Backend URL
  static const String baseUrl =
      'https://airesumeanalyzer-backend-bxxv.onrender.com';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      // Increased to 60 seconds to allow Render's free tier to wake up from sleep
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<Map<String, dynamic>> analyzeResume({
    required Uint8List fileBytes,
    required String fileName,
    required String jobDescription,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      'job_description': jobDescription,
    });

    try {
      final res = await _dio.post('/api/analyze', data: formData);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // If the server is down, give a clearer error message
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Could not connect to the server. Please try again in a minute.',
        );
      }
      throw Exception(e.response?.data['detail'] ?? e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
