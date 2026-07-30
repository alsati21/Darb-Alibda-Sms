import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:darb_alibda_sms/core/network/api_client.dart';
import 'package:darb_alibda_sms/features/classes/data/repositories/classes_repository.dart';
import 'package:darb_alibda_sms/features/notes/data/models/teacher_section_student.dart';

void main() {
  test('fetchClasses keeps students attached to each section', () async {
    final body = jsonEncode({
      'data': [
        {
          'section_id': 1,
          'section_name': 'الرابعة',
          'section_full_name': 'الصف السادس الابتدائي - الرابعة',
          'class_id': 1,
          'class_name': 'الصف السادس الابتدائي',
          'total_students': 2,
          'attendance': {
            'date': '2026-08-16',
            'present': 1,
            'absent': 1,
            'late': 0,
            'excused': 0,
            'percentage': 50,
          },
          'schedules': [],
          'students': [
            {
              'student_id': 3,
              'full_name': 'عمر أحمد نزار',
              'attendance_status': 'absent',
            },
            {
              'student_id': 4,
              'full_name': 'ريم حسين عبدالله',
              'attendance_status': 'present',
            },
          ],
        },
      ],
    });

    final repository = ClassesRepository(
      apiClient: ApiClient(
        inner: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(body),
            200,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
          );
        }),
      ),
    );

    final items = await repository.fetchClasses();

    expect(items, isNotEmpty);
    expect(items.first.studentList, hasLength(2));
    expect(items.first.studentList.first.fullName, 'عمر أحمد نزار');
    expect(items.first.studentList.first.attendanceStatus, 'absent');
  });

  test(
    'teacher section student model reads student_id and parent name from API payload',
    () {
      final student = TeacherSectionStudent.fromJson({
        'student_id': 42,
        'full_name': 'حسن علي',
        'section_id': 7,
        'section_name': 'الرابعة',
        'class_name': 'الصف السادس الابتدائي',
        'parent': {'name': 'أبو حسن', 'phone': '0999999999'},
      }, fallbackSectionId: 0);

      expect(student.id, 42);
      expect(student.fullName, 'حسن علي');
      expect(student.parentName, 'أبو حسن');
      expect(student.sectionId, 7);
    },
  );
}
