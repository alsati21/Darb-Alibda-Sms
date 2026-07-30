import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/teacher_notification_item.dart';

class TeacherNotificationSummary {
  const TeacherNotificationSummary({
    required this.unreadCount,
    required this.readCount,
    required this.unread,
    required this.read,
  });

  final int unreadCount;
  final int readCount;
  final List<TeacherNotificationItem> unread;
  final List<TeacherNotificationItem> read;
}

class TeacherNotificationsRepository {
  TeacherNotificationsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<TeacherNotificationSummary> fetchNotifications(String token) async {
    final response = await _sendGet('/api/teacher/notification', token);
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! Map<String, dynamic>) {
      return const TeacherNotificationSummary(unreadCount: 0, readCount: 0, unread: [], read: []);
    }

    return TeacherNotificationSummary(
      unreadCount: _toInt(data['unread_count']),
      readCount: _toInt(data['read_count']),
      unread: _extractNotifications(data['unread']),
      read: _extractNotifications(data['read']),
    );
  }

  Future<void> markAsRead(String token, String notificationId) async {
    final response = await _sendPost('/api/teacher/notification/$notificationId/mark-as-read', token);
    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic> || decodedBody['success'] != true) {
      throw Exception(_readMessage(decodedBody, fallback: 'فشل تعليم الإشعار كمقروء'));
    }
  }

  Future<int> markAllAsRead(String token) async {
    final response = await _sendPost('/api/teacher/notification/mark-all-as-read', token);
    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic> || decodedBody['success'] != true) {
      throw Exception(_readMessage(decodedBody, fallback: 'فشل تعليم الإشعارات كمقروءة'));
    }

    final data = decodedBody['data'];
    if (data is Map<String, dynamic>) {
      return _toInt(data['marked_count']);
    }
    return 0;
  }

  Future<void> deleteNotification(String token, String notificationId) async {
    final response = await _sendPost('/api/teacher/notification/$notificationId', token);
    final decodedBody = _decodeResponse(response.body);
    if (decodedBody is! Map<String, dynamic> || decodedBody['success'] != true) {
      throw Exception(_readMessage(decodedBody, fallback: 'فشل حذف الإشعار'));
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



  List<TeacherNotificationItem> _extractNotifications(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return const [];
    }

    final parent = source['parent'];
    if (parent is! List) {
      return const [];
    }

    return parent
        .whereType<Map>()
        .map((item) => TeacherNotificationItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
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

  String _readMessage(dynamic decodedBody, {required String fallback}) {
    if (decodedBody is Map<String, dynamic>) {
      final message = '${decodedBody['message'] ?? ''}'.trim();
      if (message.isNotEmpty) return message;
    }
    return fallback;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}
