import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/teacher_schedule.dart';

class ScheduleRepository {
  ScheduleRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<TeacherTodayScheduleItem>> fetchTodaySchedule(String token) async {
    final response = await _sendGet('/api/teacher/schedule/today', token);
    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((item) => TeacherTodayScheduleItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, List<TeacherWeekScheduleItem>>> fetchWeekSchedule(String token) async {
    final response = await _sendGet('/api/teacher/schedule/week', token);
    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! Map) {
      return <String, List<TeacherWeekScheduleItem>>{};
    }

    final result = <String, List<TeacherWeekScheduleItem>>{};
    for (final entry in data.entries) {
      final dayName = '${entry.key ?? ''}'.trim();
      final items = entry.value;
      if (items is List) {
        result[dayName] = items
            .whereType<Map>()
            .map((item) => TeacherWeekScheduleItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    return result;
  }

  Future<dynamic> _sendGet(String path, String token) async {
    try {
      return await _apiClient.get(
        path,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}).');
    }
  }

  dynamic _decodeResponse(String body) {
    if (body.isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
