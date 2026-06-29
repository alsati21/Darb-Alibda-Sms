import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? inner, String? baseUrl, Duration? timeout})
    : _inner = inner ?? http.Client(),
      baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://127.0.0.1:8000',
          ),
      timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _inner;
  final String baseUrl;
  final Duration timeout;

  Uri _build(String path) => Uri.parse(baseUrl + path);

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = _build(path);
    if (kDebugMode) debugPrint('[ApiClient] GET $uri');
    final res = await _inner.get(uri, headers: headers).timeout(timeout);
    if (kDebugMode) debugPrint('[ApiClient] GET ${res.statusCode} ${uri.path}');
    return res;
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = _build(path);

    try {
      final requestHeaders = Map<String, String>.from(headers ?? const <String, String>{});
      if (body != null && body is! String && !requestHeaders.containsKey('Content-Type')) {
        requestHeaders['Content-Type'] = 'application/json';
      }

      final encoded = body is String ? body : jsonEncode(body ?? {});

      debugPrint("REQUEST: $encoded");

      final res = await _inner
          .post(uri, headers: requestHeaders, body: encoded)
          .timeout(timeout);

      debugPrint("STATUS = ${res.statusCode}");
      debugPrint("BODY = ${res.body}");

      return res;
    } catch (e, s) {
      debugPrint("ERROR = $e");
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  /// Send multipart POST with optional file. `fileFieldName` is the form field name for the file.
  Future<http.Response> multipartPost(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    String? fileFieldName,
    String? filePath,
  }) async {
    final uri = _build(path);
    if (kDebugMode) debugPrint('[ApiClient] MULTIPART POST $uri');

    final request = http.MultipartRequest('POST', uri);
    if (headers != null) request.headers.addAll(headers);
    if (fields != null) request.fields.addAll(fields);

    if (fileFieldName != null && filePath != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        fileFieldName,
        filePath,
      );
      request.files.add(multipartFile);
    }

    final streamed = await _inner.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    if (kDebugMode)
      debugPrint('[ApiClient] MULTIPART ${response.statusCode} ${uri.path}');
    return response;
  }

  void close() => _inner.close();
}
