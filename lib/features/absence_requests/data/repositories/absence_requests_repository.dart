import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/absence_justification_request.dart';

class AbsenceRequestsRepository {
  AbsenceRequestsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<AbsenceJustificationRequest>> fetchRequests(String token) async {
    final response = await _sendGet('/api/teacher/absence-justifications', token);
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
        .map((item) => AbsenceJustificationRequest.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> updateRequest({
    required String token,
    required int requestId,
    required String status,
    String reviewNote = '',
  }) async {
    final response = await _sendPost(
      '/api/teacher/absence-justifications/update/$requestId',
      token,
      body: {
        'status': status,
        'review_note': reviewNote,
      },
    );
    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic> || decodedBody['status'] != 'success') {
      throw Exception('فشل تحديث طلب الغياب');
    }
  }

  Future<void> deleteRequest({
    required String token,
    required int requestId,
  }) async {
    final response = await _sendPost(
      '/api/teacher/absence-justifications/destroy/$requestId',
      token,
      body: const <String, dynamic>{},
    );
    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic> || decodedBody['status'] != 'success') {
      throw Exception('فشل حذف طلب الغياب');
    }
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
