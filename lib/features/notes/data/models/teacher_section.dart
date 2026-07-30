import 'dart:convert';

import 'teacher_section_student.dart';

class TeacherSection {
  const TeacherSection({
    required this.sectionId,
    required this.sectionFullName,
    required this.className,
    required this.sectionName,
    required this.students,
  });

  final int sectionId;
  final String sectionFullName;
  final String className;
  final String sectionName;
  final List<TeacherSectionStudent> students;

  String get displayLabel => sectionFullName.isNotEmpty
      ? sectionFullName
      : '$className • شعبة $sectionName';

  factory TeacherSection.fromJson(Map<String, dynamic> json) {
    final studentsValue = json['students'];
    final sectionId = json['section_id'] is int
        ? json['section_id'] as int
        : int.tryParse('${json['section_id']}') ?? 0;
    final students = studentsValue is List
        ? studentsValue
              .whereType<Map>()
              .map(
                (item) => TeacherSectionStudent.fromJson(
                  Map<String, dynamic>.from(item),
                  fallbackSectionId: sectionId,
                ),
              )
              .toList()
        : <TeacherSectionStudent>[];

    return TeacherSection(
      sectionId: sectionId,
      sectionFullName: _normalizeText(json['section_full_name']),
      className: _normalizeText(json['class_name']),
      sectionName: _normalizeText(json['section_name']),
      students: students,
    );
  }

  static String _normalizeText(dynamic value) {
    final text = value == null ? '' : '$value'.trim();
    if (text.isEmpty) return '';

    if (!hasMojibake(text)) return text;

    try {
      return utf8.decode(latin1.encode(text), allowMalformed: true);
    } catch (_) {
      return text;
    }
  }

  static bool hasMojibake(String value) {
    return value.contains(RegExp(r'[ØÐÝÞÙÚÛÜ]'));
  }
}
