import 'package:flutter_test/flutter_test.dart';
import 'package:darb_alibda_sms/features/attendance/data/models/teacher_attendance_section.dart';

void main() {
  group('TeacherAttendanceSection parsing', () {
    test('parses sections, schedules and students from the teacher API payload', () {
      final json = {
        'section_id': 1,
        'section_name': 'أ',
        'section_full_name': 'غير معروف - أ',
        'class_id': 1,
        'class_name': 'غير معروف',
        'total_students': 3,
        'attendance': {
          'date': '2026-06-29',
          'present': 0,
          'absent': 0,
          'late': 0,
          'excused': 0,
          'percentage': 0,
        },
        'schedules': [
          {
            'schedule_id': 1,
            'subject_name': 'الرياضيات',
            'day': 'mon',
            'time_slot': {
              'id': 1,
              'name': 'الحصة الأولى',
              'start_time': '2026-06-29T08:00:00.000000Z',
              'end_time': '2026-06-29T08:45:00.000000Z',
            },
            'term_name': 'الفصل الأول',
          }
        ],
        'students': [
          {
            'student_id': 1,
            'enrollment_id': 1,
            'registry_number': 'STU001',
            'full_name': 'باسم محمد أحمد',
            'first_name': 'باسم',
            'last_name': 'أحمد',
            'email': 'student1@example.com',
            'phone': '0505555555',
            'gender': 'male',
            'birth_date': '2010-05-15',
            'parent': {
              'id': 4,
              'name': 'ولي الأمر الأول',
              'email': 'parent1@example.com',
              'phone': '0503333333',
            },
            'attendance_status': 'present',
          }
        ],
      };

      final section = TeacherAttendanceSection.fromJson(json);

      expect(section.sectionId, 1);
      expect(section.sectionName, 'أ');
      expect(section.className, 'غير معروف');
      expect(section.schedules.length, 1);
      expect(section.students.length, 1);
      expect(section.students.first.fullName, 'باسم محمد أحمد');
      expect(section.students.first.attendanceStatus, 'present');
    });

    test('deduplicates students that arrive with the same student_id', () {
      final json = {
        'section_id': 1,
        'section_name': 'أ',
        'section_full_name': 'غير معروف - أ',
        'class_id': 1,
        'class_name': 'غير معروف',
        'total_students': 3,
        'attendance': {
          'date': '2026-06-29',
          'present': 0,
          'absent': 0,
          'late': 0,
          'excused': 0,
          'percentage': 0,
        },
        'schedules': const <Map<String, dynamic>>[],
        'students': [
          {
            'student_id': 1,
            'enrollment_id': 1,
            'registry_number': 'STU001',
            'full_name': 'باسم محمد أحمد',
            'first_name': 'باسم',
            'last_name': 'أحمد',
            'email': 'student1@example.com',
            'phone': '0505555555',
            'gender': 'male',
            'birth_date': '2010-05-15',
            'parent': {
              'id': 4,
              'name': 'ولي الأمر الأول',
              'email': 'parent1@example.com',
              'phone': '0503333333',
            },
            'attendance_status': 'present',
          },
          {
            'student_id': 1,
            'enrollment_id': 3,
            'registry_number': 'STU001',
            'full_name': 'باسم محمد أحمد',
            'first_name': 'باسم',
            'last_name': 'أحمد',
            'email': 'student1@example.com',
            'phone': '0505555555',
            'gender': 'male',
            'birth_date': '2010-05-15',
            'parent': {
              'id': 4,
              'name': 'ولي الأمر الأول',
              'email': 'parent1@example.com',
              'phone': '0503333333',
            },
            'attendance_status': 'absent',
          },
        ],
      };

      final section = TeacherAttendanceSection.fromJson(json);

      expect(section.students.length, 1);
      expect(section.students.first.studentId, 1);
      expect(section.students.first.attendanceStatus, 'absent');
    });
  });
}
