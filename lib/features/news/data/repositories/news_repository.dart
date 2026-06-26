import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/teacher_news_item.dart';

class NewsRepository {
  NewsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<TeacherNewsItem>> fetchNews(String token) async {
    final response = await _sendGet('/api/teacher/news', token);
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
        .map((item) => TeacherNewsItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TeacherUnreadCount> fetchUnreadCount(String token) async {
    final response = await _sendGet('/api/teacher/news/unread-count', token);
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is Map<String, dynamic>) {
      return TeacherUnreadCount.fromJson(data);
    }

    return const TeacherUnreadCount(unreadCount: 0);
  }

  Future<void> markAsRead(String token, int newsId) async {
    await _sendPost('/api/teacher/news/$newsId/mark-as-read', token);
  }

  Future<TeacherUnreadCount> markAllAsRead(String token) async {
    final response = await _sendPost('/api/teacher/news/mark-all-as-read', token);
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is Map<String, dynamic>) {
      return TeacherUnreadCount.fromJson(data);
    }

    return const TeacherUnreadCount(unreadCount: 0);
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

  Future<dynamic> _sendPost(String path, String token) async {
    try {
      return await _apiClient.post(
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
