import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class GradeItem {
  const GradeItem({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.enrollmentId,
    required this.sectionId,
    required this.sectionName,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.subjectComponentId,
    required this.subjectComponentName,
    required this.termId,
    required this.termName,
    required this.mark,
    required this.status,
    required this.color,
    required this.date,
    required this.grade,
    required this.section,
    required this.type,
  });

  final String id;
  final int studentId;
  final String studentName;
  final int enrollmentId;
  final int sectionId;
  final String sectionName;
  final String className;
  final int subjectId;
  final String subjectName;
  final int subjectComponentId;
  final String subjectComponentName;
  final int termId;
  final String termName;
  final int mark;
  final String status;
  final Color color;
  final String date;
  final String grade;
  final String section;
  final String type;

  factory GradeItem.fromApiResponse(Map<String, dynamic> json) {
    final student = _asMap(json['student']);
    final section = _asMap(json['section']);
    final subject = _asMap(json['subject']);
    final component = _asMap(json['subject_component']);
    final term = _asMap(json['term']);

    final rawSectionName = _asString(section['name']);
    final rawGradeName = _gradeLabelFromClassName(rawSectionName);
    final rawTypeName = _asString(json['type'], fallback: _asString(component['name']));
    final rawMark = _asInt(json['mark']);

    return GradeItem(
      id: '${json['id'] ?? ''}',
      studentId: _asInt(student['id']),
      studentName: _asString(student['full_name']),
      enrollmentId: _asInt(json['enrollment_id']),
      sectionId: _asInt(section['id']),
      sectionName: rawSectionName,
      className: rawGradeName,
      subjectId: _asInt(subject['id']),
      subjectName: _asString(subject['name']),
      subjectComponentId: _asInt(component['id']),
      subjectComponentName: _asString(component['name']),
      termId: _asInt(term['id']),
      termName: _asString(term['name']),
      mark: rawMark,
      status: computeStatus(rawMark),
      color: computeColor(rawMark),
      date: _asString(json['updated_at'], fallback: _asString(json['created_at'])),
      grade: rawGradeName,
      section: rawSectionName,
      type: _mapTypeLabel(rawTypeName),
    );
  }

  GradeItem copyWith({
    String? id,
    int? studentId,
    String? studentName,
    int? enrollmentId,
    int? sectionId,
    String? sectionName,
    String? className,
    int? subjectId,
    String? subjectName,
    int? subjectComponentId,
    String? subjectComponentName,
    int? termId,
    String? termName,
    int? mark,
    String? status,
    Color? color,
    String? date,
    String? grade,
    String? section,
    String? type,
  }) {
    return GradeItem(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
      className: className ?? this.className,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectComponentId: subjectComponentId ?? this.subjectComponentId,
      subjectComponentName: subjectComponentName ?? this.subjectComponentName,
      termId: termId ?? this.termId,
      termName: termName ?? this.termName,
      mark: mark ?? this.mark,
      status: status ?? this.status,
      color: color ?? this.color,
      date: date ?? this.date,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      type: type ?? this.type,
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static String _asString(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();
    if (value is Map) {
      final candidate = value['name'] ?? value['label'] ?? value['type'] ?? value['value'];
      return _asString(candidate, fallback: fallback);
    }
    return value.toString();
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    if (value is Map) {
      return _asInt(value['id'] ?? value['value'] ?? value['code'], fallback: fallback);
    }
    return fallback;
  }

  static String _gradeLabelFromClassName(String className) {
    final regex = RegExp(r'^(الصف\s+\w+)');
    final match = regex.firstMatch(className);
    if (match != null) {
      return match.group(1) ?? className;
    }
    return className;
  }

  static String computeStatus(int score) {
    if (score >= 90) return 'ممتاز';
    if (score >= 80) return 'جيد جداً';
    if (score >= 70) return 'جيد';
    if (score >= 60) return 'مقبول';
    return 'ضعيف';
  }

  static Color computeColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.primary;
    if (score >= 70) return AppColors.warning;
    if (score >= 60) return AppColors.info;
    return AppColors.error;
  }

  static String _mapTypeLabel(String rawType) {
    final normalized = rawType.trim().toLowerCase();
    if (normalized == 'written' || normalized == 'oral' || normalized == 'practical') {
      return normalized;
    }
    return normalized.isNotEmpty ? normalized : 'written';
  }
}
