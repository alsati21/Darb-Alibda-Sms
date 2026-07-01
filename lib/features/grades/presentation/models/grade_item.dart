import 'package:flutter/material.dart';

class GradeItem {
  const GradeItem({
    required this.id,
    required this.studentName,
    required this.score,
    required this.status,
    required this.color,
    required this.date,
    required this.grade,
    required this.section,
    required this.type,
  });

  final String id;
  final String studentName;
  final int score;
  final String status;
  final Color color;
  final String date;
  final String grade;
  final String section;
  final String type;

  GradeItem copyWith({
    String? id,
    String? studentName,
    int? score,
    String? status,
    Color? color,
    String? date,
    String? grade,
    String? section,
    String? type,
  }) {
    return GradeItem(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      score: score ?? this.score,
      status: status ?? this.status,
      color: color ?? this.color,
      date: date ?? this.date,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      type: type ?? this.type,
    );
  }
}
