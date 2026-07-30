import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/parent_note.dart';
import '../models/teacher_section.dart';

class ParentNotesRepository {
  ParentNotesRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ParentNote>> fetchNotes(String token) async {
    final response = await _sendGet('/api/teacher/parent-notes', token);
    final decoded = _decodeResponse(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decoded['data'];
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => ParentNote.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<TeacherSection>> fetchSectionsWithStudents(String token) async {
    final response = await _sendGet('/api/teacher/sections-with-students', token);
    final decoded = _decodeResponse(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decoded['data'];
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => TeacherSection.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ParentNote> createNote({
    required String token,
    required String title,
    required String content,
    required List<int> studentIds,
    required List<int> sectionIds,
    List<String> attachmentPaths = const [],
  }) async {
    final path = '/api/teacher/parent-notes';
    final response = await _sendMultipart(
      path,
      token,
      fields: <String, String>{
        'title': title,
        'content': content,
      },
      extraFields: [
        for (final studentId in studentIds)
          ApiMultipartField(fieldName: 'student_ids[]', value: studentId.toString()),
        for (final sectionId in sectionIds)
          ApiMultipartField(fieldName: 'section_ids[]', value: sectionId.toString()),
      ],
      files: attachmentPaths
          .map((path) => ApiMultipartFile(fieldName: 'attachments[]', filePath: path))
          .toList(),
    );

    final decoded = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(decoded) ?? 'فشل إنشاء الملاحظة');
    }

    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is Map<String, dynamic>) {
      final notes = data['notes'];
      if (notes is List && notes.isNotEmpty) {
        final first = notes.first;
        if (first is Map) return ParentNote.fromJson(Map<String, dynamic>.from(first));
      }
    }

    throw Exception('لم يتم العثور على بيانات الملاحظة بعد الإنشاء');
  }

  Future<ParentNote> updateNote({
    required String token,
    required int id,
    required String title,
    required String content,
  }) async {
    final response = await _sendPost(
      '/api/teacher/parent-notes/$id',
      token,
      body: {'title': title, 'content': content},
    );

    final decoded = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(decoded) ?? 'فشل تعديل الملاحظة');
    }

    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is Map<String, dynamic>) {
      return ParentNote.fromJson(data);
    }

    throw Exception('استجابة غير صحيحة من الخادم');
  }

  Future<int> deleteNote({required String token, required int id}) async {
    final response = await _sendPost('/api/teacher/parent-notes/delete/$id', token);
    final decoded = _decodeResponse(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(decoded) ?? 'فشل حذف الملاحظة');
    }

    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is Map<String, dynamic> && data['deleted'] == true) {
      return _readInt(data['id']);
    }

    return id;
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

  Future<dynamic> _sendPost(String path, String token, {Object? body}) async {
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

  Future<dynamic> _sendMultipart(
    String path,
    String token, {
    Map<String, String>? fields,
    List<ApiMultipartField>? extraFields,
    List<ApiMultipartFile>? files,
  }) async {
    try {
      return await _apiClient.multipartPost(
        path,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        fields: fields,
        extraFields: extraFields,
        files: files,
      );
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

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}