import 'package:flutter/material.dart';

class NoteItem {
  const NoteItem({
    required this.id,
    required this.content,
    required this.recipient,
    required this.date,
    required this.status,
    required this.color,
    required this.icon,
    required this.readCount,
    required this.totalCount,
    required this.grade,
    required this.section,
  });

  final String id;
  final String content;
  final String recipient;
  final String date;
  final String status;
  final Color color;
  final IconData icon;
  final int readCount;
  final int totalCount;
  final String grade;
  final String section;

  NoteItem copyWith({
    String? id,
    String? content,
    String? recipient,
    String? date,
    String? status,
    Color? color,
    IconData? icon,
    int? readCount,
    int? totalCount,
    String? grade,
    String? section,
  }) {
    return NoteItem(
      id: id ?? this.id,
      content: content ?? this.content,
      recipient: recipient ?? this.recipient,
      date: date ?? this.date,
      status: status ?? this.status,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      readCount: readCount ?? this.readCount,
      totalCount: totalCount ?? this.totalCount,
      grade: grade ?? this.grade,
      section: section ?? this.section,
    );
  }
}
