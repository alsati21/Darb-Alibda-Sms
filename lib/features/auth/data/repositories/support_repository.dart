import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/support_info.dart';

class SupportRepository {
  SupportRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SupportInfo> fetchSupportInfo() async {
    final response = await _sendGet('/api/teacher/support');
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('لم يتمكن من جلب بيانات الدعم');
    }

    return SupportInfo.fromJson(data);
  }

  Future<dynamic> _sendGet(String path) async {
    try {
      return await _apiClient.get(
        path,
        headers: {
          'Accept': 'application/json',
        //  'Authorization': 'Bearer $token',
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
