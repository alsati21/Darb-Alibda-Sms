import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/teacher_dashboard_summary.dart';

class DashboardRepository {
  DashboardRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<TeacherDashboardResponse> fetchTeacherDashboard(String token) async {
    final path = '/api/teacher/dashboard';
    final uri = Uri.parse('${_apiClient.baseUrl}$path');
    if (kDebugMode) debugPrint('[DashboardRepository] GET $uri');

    try {
      final response = await _apiClient.get(
        path,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        debugPrint('[DashboardRepository] status=${response.statusCode} body=${response.body}');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('فشل تحميل لوحة التحكم');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('استجابة غير صالحة من الخادم');
      }

      return TeacherDashboardResponse.fromJson(decoded);
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم');
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('حدث خطأ غير متوقع');
    }
  }
}
