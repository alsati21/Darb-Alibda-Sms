import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiMultipartFile {
  const ApiMultipartFile({required this.fieldName, required this.filePath});

  final String fieldName;
  final String filePath;
}

class ApiMultipartField {
  const ApiMultipartField({required this.fieldName, required this.value});

  final String fieldName;
  final String value;
}

class ApiClient {
  ApiClient({http.Client? inner, String? baseUrl, Duration? timeout})
    : _inner = inner ?? http.Client(),
      baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://drab-alibda-sms.duckdns.org',
          ),
      timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _inner;
  final String baseUrl;
  final Duration timeout;

  Uri _build(String path) => Uri.parse(baseUrl + path);

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = _build(path);
    if (kDebugMode) {
      debugPrint('[ApiClient] GET $uri');
    }
    final res = await _inner.get(uri, headers: headers).timeout(timeout);
    if (kDebugMode) {
      debugPrint('[ApiClient] GET ${res.statusCode} ${uri.path}');
      // كانت الاستجابة (body) ما بتنطبع أبدًا لطلبات GET (خلافًا لـ
      // post())، يعني ما كان في أي طريقة نتأكد شو رجع السيرفر فعليًا
      // من endpoint المكوّنات (subjects/{id}/components) عشان نشخّص
      // مشاكل زي "لا يوجد مكوّن مطابق". صرنا نطبعها هون كمان.
      debugPrint('[ApiClient] GET BODY = ${res.body}');
    }
    return res;
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = _build(path);

    try {
      final requestHeaders = Map<String, String>.from(
        headers ?? const <String, String>{},
      );
      if (body != null &&
          body is! String &&
          !requestHeaders.containsKey('Content-Type')) {
        requestHeaders['Content-Type'] = 'application/json';
      }

      final encoded = body is String ? body : jsonEncode(body ?? {});

      // كانت هاي بتطبع بدون فحص kDebugMode، يعني ممكن تسرب بيانات
      // (تضمّن أحيانًا التوكن جوا headers منفصل، بس البودي نفسه ممكن
      // يحمل بيانات حساسة) حتى بنسخة release. صرنا نطبعها بوضع
      // debug فقط، متل باقي نداءات debugPrint بهاد الملف.
      if (kDebugMode) {
        debugPrint("REQUEST: $encoded");
      }

      final res = await _inner
          .post(uri, headers: requestHeaders, body: encoded)
          .timeout(timeout);

      if (kDebugMode) {
        debugPrint("STATUS = ${res.statusCode}");
        debugPrint("BODY = ${res.body}");
      }

      return res;
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint("ERROR = $e");
        debugPrintStack(stackTrace: s);
      }
      rethrow;
    }
  }

  /// Send multipart POST with optional file. `fileFieldName` is the form field name for the file.
  Future<http.Response> multipartPost(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<ApiMultipartField>? extraFields,
    List<ApiMultipartFile>? files,
    String? fileFieldName,
    String? filePath,
  }) async {
    final uri = _build(path);
    if (kDebugMode) debugPrint('[ApiClient] MULTIPART POST $uri');

    final request = http.MultipartRequest('POST', uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (extraFields != null) {
      for (final field in extraFields) {
        request.files.add(
          http.MultipartFile.fromString(field.fieldName, field.value),
        );
      }
    }

    final multipartFiles = <ApiMultipartFile>[
      if (files != null) ...files,
      if (fileFieldName != null && filePath != null)
        ApiMultipartFile(fieldName: fileFieldName, filePath: filePath),
    ];

    for (final multipartFile in multipartFiles) {
      request.files.add(
        await http.MultipartFile.fromPath(
          multipartFile.fieldName,
          multipartFile.filePath,
        ),
      );
    }

    final streamed = await _inner.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    if (kDebugMode) {
      debugPrint('[ApiClient] MULTIPART ${response.statusCode} ${uri.path}');
    }
    return response;
  }

  void close() => _inner.close();
}
