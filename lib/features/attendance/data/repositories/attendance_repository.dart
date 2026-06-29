import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/teacher_attendance_section.dart';

class AttendanceRepository {
  AttendanceRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<TeacherAttendanceSection>> fetchSectionsWithStudents(String token) async {
    final response = await _sendGet('/api/teacher/sections-with-students', token);
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
        .map((item) => TeacherAttendanceSection.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<AttendanceBatchUpdateResult> batchUpdateAttendance({
    required String token,
    required int sectionId,
    required String date,
    required int scheduleId,
    required List<Map<String, dynamic>> students,
  }) async {
    final response = await _sendPost(
      '/api/teacher/attendance/sections/$sectionId/batch-update',
      token,
      body: {
        'date': date,
        'schedule_id': scheduleId,
        'students': students,
      },
    );

    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is Map<String, dynamic>) {
      return AttendanceBatchUpdateResult.fromJson(data);
    }

    throw Exception('لم يتم استلام نتيجة الحضور من الخادم');
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

  Future<dynamic> _sendPost(String path, String token, {required Map<String, dynamic> body}) async {
    try {
      return await _apiClient.post(
        path,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
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
