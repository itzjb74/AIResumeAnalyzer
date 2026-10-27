import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb

class ApiService {
  // Automatically switch the URL based on the platform
  static String get baseUrl {
    if (kIsWeb) {
      // If running on Chrome or Web
      return 'http://127.0.0.1:8000';
    } else {
      // If running on Android Emulator
      // Note: If you use a physical phone, replace this with your computer's Wi-Fi IP (e.g., 'http://192.168.1.5:8000')
      return 'http://10.0.2.2:8000';
    }
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
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
        throw Exception('Could not connect to the server. Is FastAPI running?');
      }
      throw Exception(e.response?.data['detail'] ?? e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
