import 'package:flutter/material.dart';

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
    );
  }
}
