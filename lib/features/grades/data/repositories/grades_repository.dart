import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../../presentation/models/grade_item.dart';
import '../../presentation/models/subject_component.dart';

class GradesRepository {
  GradesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<GradeItem>> fetchMarks(String token) async {
    final response = await _sendGet('/api/teacher/marks/students', token);
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! List) {
      return [];
    }

    final items = <GradeItem>[];
    for (final sectionRaw in data.whereType<Map>()) {
      final section = Map<String, dynamic>.from(sectionRaw);
      final sectionId = section['section_id'] is int
          ? section['section_id'] as int
          : int.tryParse('${section['section_id']}') ?? 0;
      final sectionName = section['section_name'] as String? ?? '';
      final className = section['class'] as String? ?? '';
      final students = section['students'];
      if (students is! List) continue;

      for (final studentRaw in students.whereType<Map>()) {
        final student = Map<String, dynamic>.from(studentRaw);
        final studentId = student['student_id'] is int
            ? student['student_id'] as int
            : int.tryParse('${student['student_id']}') ?? 0;
        final studentName = student['student_name'] as String? ?? '';
        final enrollmentId = student['enrollment_id'] is int
            ? student['enrollment_id'] as int
            : int.tryParse('${student['enrollment_id']}') ?? 0;
        final grades = student['grades'];

        if (grades is! List || grades.isEmpty) {
          items.add(
            GradeItem(
              id: 'student-$studentId-empty',
              studentId: studentId,
              studentName: studentName,
              enrollmentId: enrollmentId,
              sectionId: sectionId,
              sectionName: sectionName,
              className: className,
              subjectId: 0,
              subjectName: '',
              subjectComponentId: 0,
              subjectComponentName: '',
              termId: 0,
              termName: '',
              mark: 0,
              status: GradeItem.computeStatus(0),
              color: GradeItem.computeColor(0),
              date: '',
              grade: className,
              section: sectionName,
              type: 'written',
            ),
          );
          continue;
        }

        for (final gradeRaw in grades.whereType<Map>()) {
          final gradeJson = Map<String, dynamic>.from(gradeRaw);
          final subjectName = gradeJson['subject_name'] as String? ?? '';
          final type = _mapTypeLabel(gradeJson['type'] as String? ?? '');
          final mark = gradeJson['score'] is int
              ? gradeJson['score'] as int
              : int.tryParse('${gradeJson['score']}') ?? 0;
          final parsedTerm = gradeJson['term'];
          final parsedTermId = gradeJson['term_id'] is int
              ? gradeJson['term_id'] as int
              : (parsedTerm is Map
              ? int.tryParse('${parsedTerm['id']}') ?? 0
              : 0);
          final parsedTermName =
              gradeJson['term_name'] as String? ??
                  (parsedTerm is Map ? parsedTerm['name'] as String? ?? '' : '');
          final id = gradeJson['id'] is int
              ? gradeJson['id'].toString()
              : '${gradeJson['id']}';
          final subjectId = gradeJson['subject_id'] is int
              ? gradeJson['subject_id'] as int
              : int.tryParse('${gradeJson['subject_id']}') ?? 0;
          final componentId = gradeJson['component_id'] is int
              ? gradeJson['component_id'] as int
              : int.tryParse('${gradeJson['component_id']}') ?? 0;

          items.add(
            GradeItem(
              id: id,
              studentId: studentId,
              studentName: studentName,
              enrollmentId: enrollmentId,
              sectionId: sectionId,
              sectionName: sectionName,
              className: className,
              subjectId: subjectId,
              subjectName: subjectName,
              subjectComponentId: componentId,
              subjectComponentName: gradeJson['type'] as String? ?? '',
              termId: parsedTermId,
              termName: parsedTermName,
              mark: mark,
              status: GradeItem.computeStatus(mark),
              color: GradeItem.computeColor(mark),
              date: '',
              grade: className,
              section: sectionName,
              type: type,
            ),
          );
        }
      }
    }

    return items;
  }

  List<Map<String, dynamic>> _extractComponentRows(dynamic decoded) {
    final rows = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    void walk(dynamic value) {
      if (value is List) {
        for (final item in value) {
          walk(item);
        }
        return;
      }

      if (value is Map) {
        final map = Map<String, dynamic>.from(value);

        final idValue = map['id'] ?? map['component_id'] ?? map['subject_component_id'];
        final nameValue = map['name'] ??
            map['type'] ??
            map['component_name'] ??
            map['subject_component_name'] ??
            map['label'] ??
            map['componentType'];

        final hasComponentIdentity = idValue != null && nameValue != null;
        if (hasComponentIdentity) {
          final id = int.tryParse('$idValue') ?? 0;
          final name = '$nameValue'.trim();
          if (id > 0 && name.isNotEmpty) {
            final key = '$id:$name';
            if (!seenIds.contains(key)) {
              seenIds.add(key);
              rows.add(map);
            }
          }
          return;
        }

        for (final nested in map.values) {
          walk(nested);
        }
      }
    }

    walk(decoded);
    return rows;
  }

  Future<List<SubjectComponent>> fetchSubjectComponents(String token, int subjectId) async {
    try {
      final response = await _sendGet('/api/teacher/subjects/$subjectId/components', token);
      final decoded = _decodeResponse(response.body);
      final rows = _extractComponentRows(decoded);
      if (rows.isEmpty) return const [];

      final components = <SubjectComponent>[];
      final seen = <String>{};

      for (final map in rows) {
        final idValue = map['id'] ?? map['component_id'] ?? map['subject_component_id'];
        final nameValue = map['name'] ??
            map['type'] ??
            map['component_name'] ??
            map['subject_component_name'] ??
            map['label'] ??
            map['componentType'];

        final id = int.tryParse('$idValue') ?? 0;
        final name = '$nameValue'.trim();
        if (id > 0 && name.isNotEmpty) {
          final key = '$id:$name';
          if (!seen.contains(key)) {
            seen.add(key);
            components.add(SubjectComponent(id: id, name: name));
          }
        }
      }
      return components;
    } catch (_) {
      return [];
    }
  }

  Future<GradeItem> updateMark({
    required String token,
    required int markId,
    required int mark,
    String? type,
  }) async {
    final response = await _sendPost(
      '/api/teacher/marks/$markId',
      token,
      body: {
        'mark': mark,
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('لم يتم استلام نتيجة تعديل العلامة من الخادم');
    }

    return GradeItem.fromApiResponse(Map<String, dynamic>.from(data));
  }

  Future<GradeItem> addMark({
    required String token,
    required int studentId,
    required int sectionId,
    required int subjectId,
    required int subjectComponentId,
    required int termId,
    required int mark,
    String? type,
  }) async {
    final response = await _sendPost(
      '/api/teacher/marks',
      token,
      body: {
        'student_id': studentId,
        'section_id': sectionId,
        'subject_id': subjectId,
        'subject_component_id': subjectComponentId,
        'term_id': termId,
        'mark': mark,
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('لم يتم استلام نتيجة إضافة العلامة من الخادم');
    }

    return GradeItem.fromApiResponse(Map<String, dynamic>.from(data));
  }

  Future<void> deleteMark({required String token, required int markId}) async {
    final response = await _sendPost(
      '/api/teacher/marks/delete/$markId',
      token,
      body: {},
    );
    final decodedBody = _decodeResponse(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة غير صحيحة من الخادم');
    }

    final data = decodedBody['data'];
    if (data is! Map<String, dynamic> || data['deleted'] != true) {
      throw Exception('فشل حذف العلامة');
    }
  }

  // ───────────────────────────────────────────────
  // طبقة الحماية: timeout + فحص status code
  // ───────────────────────────────────────────────

  Future<dynamic> _sendGet(String path, String token) async {
    try {
      final response = await _apiClient
          .get(
        path,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 15));
      _validateResponse(response);
      return response;
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}).');
    }
  }

  Future<dynamic> _sendPost(
      String path,
      String token, {
        required Map<String, dynamic> body,
      }) async {
    try {
      final response = await _apiClient
          .post(
        path,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      )
          .timeout(const Duration(seconds: 15));
      _validateResponse(response);
      return response;
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم (${_apiClient.baseUrl}).');
    } on SocketException {
      throw Exception('تعذر الوصول إلى الخادم (${_apiClient.baseUrl}).');
    }
  }

  /// فحص الـ status code واستخراج رسالة الخطأ من الـ body
  void _validateResponse(dynamic response) {
    final statusCode = (response.statusCode as int?) ?? 0;

    if (statusCode >= 200 && statusCode < 300) return;

    String message = 'حدث خطأ غير متوقع (كود $statusCode)';
    try {
      final body = response.body as String? ?? '';
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final msg = decoded['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          message = msg;
        } else {
          final errors = decoded['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty) {
              message = first.first.toString();
            } else {
              message = first.toString();
            }
          }
        }
      }
    } catch (_) {}

    if (statusCode == 422) {
      throw Exception(message);
    }
    if (statusCode == 401 || statusCode == 403) {
      throw Exception('انتهت الجلسة. يرجى إعادة تسجيل الدخول.');
    }
    if (statusCode == 404) {
      throw Exception('العنصر المطلوب غير موجود.');
    }
    if (statusCode >= 500) {
      throw Exception('خطأ في الخادم. حاول مرة أخرى لاحقاً.');
    }

    throw Exception(message);
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

  static String _mapTypeLabel(String rawType) {
    final normalized = rawType.trim().toLowerCase();
    if (normalized == 'written' || normalized == 'oral' || normalized == 'practical') {
      return normalized;
    }
    return normalized.isNotEmpty ? normalized : 'written';
  }
}