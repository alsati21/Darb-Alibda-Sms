import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    String? fcmToken,
  }) async {
    final path = '/api/teacher/login';
    final uri = Uri.parse('${_apiClient.baseUrl}$path');
    if (kDebugMode) {
      debugPrint('[AuthRepository] POST $uri');
    }

    late http.Response response;
    try {
      response = await _apiClient.post(
        path,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: {
          'phone': phone,
          'password': password,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}). تأكد من أن السيرفر يعمل وأن الرابط صحيح.');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}). تأكد من الرابط والشبكة.');
    }

    if (kDebugMode) {
      debugPrint('[AuthRepository] login response: ${response.statusCode}');
    }

    final decodedBody = _decodeResponse(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractMessage(decodedBody) ?? 'فشل تسجيل الدخول';
      throw Exception(message);
    }

    if (decodedBody is Map<String, dynamic>) {
      return decodedBody;
    }

    return <String, dynamic>{'data': decodedBody};
  }

  Future<Map<String, dynamic>> fetchProfile(String token) async {
    final path = '/api/teacher/me';
    final uri = Uri.parse('${_apiClient.baseUrl}$path');
    if (kDebugMode) {
      debugPrint('[AuthRepository] GET $uri');
    }

    late http.Response response;
    try {
      response = await _apiClient.get(
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

    if (kDebugMode) {
      debugPrint('[AuthRepository] profile response: ${response.statusCode}');
    }

    final decodedBody = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractMessage(decodedBody) ?? 'فشل جلب الملف الشخصي';
      throw Exception(message);
    }

    if (decodedBody is Map<String, dynamic>) {
      return decodedBody;
    }

    return <String, dynamic>{'data': decodedBody};
  }

  Future<void> logout(String token) async {
    final path = '/api/teacher/logout';
    final uri = Uri.parse('${_apiClient.baseUrl}$path');
    if (kDebugMode) {
      debugPrint('[AuthRepository] POST $uri');
    }

    late http.Response response;
    try {
      response = await _apiClient.post(
        path,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال أثناء تسجيل الخروج (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الاتصال بالخادم أثناء تسجيل الخروج (${_apiClient.baseUrl}).');
    }

    if (kDebugMode) {
      debugPrint('[AuthRepository] logout response: ${response.statusCode}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decodedBody = _decodeResponse(response.body);
      final message = _extractMessage(decodedBody) ?? 'فشل تسجيل الخروج';
      throw Exception(message);
    }
  }

  /// Update teacher profile. `data` should contain the profile fields to update.
  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> data, {String? avatarPath}) async {
    final path = '/api/teacher/profile';
    final uri = Uri.parse('${_apiClient.baseUrl}$path');
    if (kDebugMode) debugPrint('[AuthRepository] UPDATE $uri');

    late http.Response response;
    try {
      if (avatarPath != null && avatarPath.isNotEmpty) {
        // send multipart
        final fields = <String, String>{};
        data.forEach((k, v) {
          if (v != null) fields[k] = v.toString();
        });
        response = await _apiClient.multipartPost(
          path,
          headers: {'Authorization': 'Bearer $token'},
          fields: fields,
          fileFieldName: 'avatar',
          filePath: avatarPath,
        );
      } else {
        response = await _apiClient.post(
          path,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: data,
        );
      }
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}).');
    }

    if (kDebugMode) debugPrint('[AuthRepository] updateProfile response: ${response.statusCode}');

    final decodedBody = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // If validation errors exist, throw a structured exception so UI can show inline errors
      if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('errors')) {
        final errors = decodedBody['errors'] as Map<String, dynamic>;
        throw ApiValidationException(errors: errors, message: _extractMessage(decodedBody));
      }
      final message = _extractMessage(decodedBody) ?? 'فشل تحديث الملف الشخصي';
      throw Exception(message);
    }

    if (decodedBody is Map<String, dynamic>) return decodedBody;
    return <String, dynamic>{'data': decodedBody};
  }

  /// Trigger forgot password flow. `identifier` can be phone or email depending on backend.
  Future<Map<String, dynamic>> forgotPassword(String identifier) async {
    final path = '/api/teacher/forgot-password';
    final uri = Uri.parse('${_apiClient.baseUrl}$path');
    if (kDebugMode) debugPrint('[AuthRepository] POST $uri');

    late http.Response response;
    try {
      response = await _apiClient.post(
        path,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: {'identifier': identifier},
      );
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}).');
    }

    if (kDebugMode) debugPrint('[AuthRepository] forgotPassword response: ${response.statusCode}');

    final decodedBody = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractMessage(decodedBody) ?? 'فشل طلب استعادة كلمة المرور';
      throw Exception(message);
    }

    if (decodedBody is Map<String, dynamic>) return decodedBody;
    return <String, dynamic>{'data': decodedBody};
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

  String? _extractMessage(dynamic decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      final message = decodedBody['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final error = decodedBody['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }

    if (decodedBody is String && decodedBody.isNotEmpty) {
      return decodedBody;
    }

    return null;
  }
}

class ApiValidationException implements Exception {
  ApiValidationException({required this.errors, this.message});

  final Map<String, dynamic> errors;
  final String? message;

  @override
  String toString() => message ?? 'Validation failed';
}
