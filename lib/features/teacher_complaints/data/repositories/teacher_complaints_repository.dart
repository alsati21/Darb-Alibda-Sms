import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/teacher_complaint_item.dart';

class TeacherComplaintsRepository {
  TeacherComplaintsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<TeacherComplaintItem>> fetchComplaints(String token) async {
    final response = await _sendGet('/api/teacher/complaints', token);
    final decoded = _decodeResponse(response.body);
    if (decoded is! Map<String, dynamic>) throw Exception('استجابة غير صحيحة من الخادم');
    final data = decoded['data'];
    if (data is! List) return [];
    return data.whereType<Map>().map((e) => TeacherComplaintItem.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<TeacherComplaintItem> fetchComplaint(String token, int id) async {
    final response = await _sendGet('/api/teacher/complaints/$id', token);
    final decoded = _decodeResponse(response.body);
    if (decoded is! Map<String, dynamic>) throw Exception('استجابة غير صحيحة من الخادم');
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) throw Exception('تعذر جلب تفاصيل الشكوى');
    return TeacherComplaintItem.fromJson(data);
  }

  Future<TeacherComplaintItem> submitComplaint({required String token, required String title, required String body}) async {
    final response = await _sendPost('/api/teacher/complaints', token, body: {
      'title': title,
      'body': body,
    });

    final decoded = _decodeResponse(response.body);
    if (decoded is! Map<String, dynamic>) throw Exception('استجابة غير صحيحة من الخادم');
    if (decoded['success'] != true) {
      throw Exception(_readString(decoded['message'], fallback: 'فشل إرسال الشكوى'));
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) throw Exception('تعذر حفظ الشكوى');
    return TeacherComplaintItem.fromJson(data);
  }

  Future<dynamic> _sendGet(String path, String token) async {
    try {
      return await _apiClient.get(path, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}).');
    }
  }

  Future<dynamic> _sendPost(String path, String token, {required Map<String, dynamic> body}) async {
    try {
      return await _apiClient.post(path, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: body);
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}).');
    }
  }

  dynamic _decodeResponse(String body) {
    if (body.isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _readString(dynamic value, {required String fallback}) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? fallback : text;
  }
}
