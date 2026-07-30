import 'dart:convert';

import 'package:flutter/material.dart';

class ClassStudent {
  const ClassStudent({
    required this.studentId,
    required this.fullName,
    required this.attendanceStatus,
    required this.registryNumber,
    required this.parentName,
  });

  final int studentId;
  final String fullName;
  final String attendanceStatus;
  final String registryNumber;
  final String parentName;

  factory ClassStudent.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'];
    final parentMap = parent is Map
        ? Map<String, dynamic>.from(parent)
        : <String, dynamic>{};

    return ClassStudent(
      studentId: _toInt(json['student_id']) != 0
          ? _toInt(json['student_id'])
          : _toInt(json['id']),
      fullName: _normalizeString(json['full_name']),
      attendanceStatus: _normalizeString(json['attendance_status']),
      registryNumber: _normalizeString(json['registry_number']),
      parentName: _normalizeString(parentMap['name']),
    );
  }

  static String _normalizeString(dynamic value) {
    final text = value == null ? '' : '$value'.trim();
    if (text.isEmpty) return '';

    if (!text.contains(RegExp(r'[ØÐÝÞÙÚÛÜ]'))) return text;

    try {
      return utf8.decode(latin1.encode(text), allowMalformed: true);
    } catch (_) {
      return text;
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class ClassItem {
  const ClassItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.color,
    required this.students,
    required this.grade,
    required this.subject,
    this.studentList = const <ClassStudent>[],
  });

  final int id;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color color;
  final int students;
  final String grade;
  final String subject;
  final List<ClassStudent> studentList;

  ClassItem copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? status,
    Color? statusColor,
    IconData? icon,
    Color? color,
    int? students,
    String? grade,
    String? subject,
    List<ClassStudent>? studentList,
  }) {
    return ClassItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      students: students ?? this.students,
      grade: grade ?? this.grade,
      subject: subject ?? this.subject,
      studentList: studentList ?? this.studentList,
    );
  }
}
