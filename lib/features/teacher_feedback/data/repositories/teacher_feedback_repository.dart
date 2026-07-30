import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/teacher_feedback_item.dart';

class TeacherFeedbackSubmissionResult {
  TeacherFeedbackSubmissionResult({required this.message, required this.item});

  final String message;
  final TeacherFeedbackItem item;
}

class TeacherFeedbackRepository {
  TeacherFeedbackRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<TeacherFeedbackItem>> fetchSuggestions(String token) async {
    final response = await _sendGet('/api/teacher/suggestions', token);
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
        .map((item) => TeacherFeedbackItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TeacherFeedbackItem> fetchSuggestion(String token, int suggestionId) async {
    final response = await _sendGet('/api/teacher/suggestions/$suggestionId', token);
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('تعذر جلب تفاصيل الاقتراح');
    }

    return TeacherFeedbackItem.fromJson(data);
  }

  Future<TeacherFeedbackSubmissionResult> submitSuggestion({
    required String token,
    required String title,
    required String body,
  }) async {
    final response = await _sendPost(
      '/api/teacher/suggestion',
      token,
      body: {
        'title': title,
        'body': body,
      },
    );

    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    if (decodedBody['success'] != true) {
      throw Exception(_readString(decodedBody['message'], fallback: 'فشل إرسال الاقتراح'));
    }

    final data = decodedBody['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('تعذر حفظ الاقتراح');
    }

    return TeacherFeedbackSubmissionResult(
      message: _readString(decodedBody['message'], fallback: 'تم إرسال الاقتراح بنجاح.'),
      item: TeacherFeedbackItem.fromJson(data),
    );
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

  String _readString(dynamic value, {required String fallback}) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? fallback : text;
  }
}
