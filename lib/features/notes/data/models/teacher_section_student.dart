import 'dart:convert';

class TeacherSectionStudent {
  const TeacherSectionStudent({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhone,
    required this.sectionId,
    required this.sectionName,
    required this.className,
  });

  final int id;
  final String fullName;
  final String parentName;
  final String parentPhone;
  final int sectionId;
  final String sectionName;
  final String className;

  String get displayLabel {
    final sectionLabel = sectionName.isNotEmpty ? sectionName : 'A';
    final parentLabel = parentName.isNotEmpty ? ' • $parentName' : '';
    return '$fullName • شعبة $sectionLabel$parentLabel';
  }

  factory TeacherSectionStudent.fromJson(
    Map<String, dynamic> json, {
    required int fallbackSectionId,
  }) {
    final parent = _readMap(json['parent']);
    final fullName = _readString(json['full_name']);
    final firstName = _readString(json['first_name']);
    final lastName = _readString(json['last_name']);
    final resolvedFullName = fullName.isNotEmpty
        ? fullName
        : [firstName, lastName].where((v) => v.isNotEmpty).join(' ');

    return TeacherSectionStudent(
      id: _readInt(json['student_id']) != 0
          ? _readInt(json['student_id'])
          : _readInt(json['id']),
      fullName: resolvedFullName,
      parentName: _readString(parent['name']),
      parentPhone: _readString(parent['phone']),
      sectionId: json['section_id'] is int
          ? json['section_id'] as int
          : fallbackSectionId,
      sectionName: _readString(json['section_name']),
      className: _readString(json['class_name']),
    );
  }

  static String _readString(dynamic value) {
    final text = value == null ? '' : '$value'.trim();
    if (text.isEmpty) return '';

    if (!hasMojibake(text)) return text;

    try {
      return utf8.decode(latin1.encode(text), allowMalformed: true);
    } catch (_) {
      return text;
    }
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static bool hasMojibake(String value) {
    return value.contains(RegExp(r'[ØÐÝÞÙÚÛÜ]'));
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}
