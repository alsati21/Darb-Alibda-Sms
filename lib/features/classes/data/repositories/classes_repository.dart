import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/models/class_item.dart';

class ClassesRepository {
  ClassesRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Fetch sections with students from the API.
  /// If [token] is provided it will be set as Authorization header.
  Future<List<ClassItem>> fetchClasses({String? token}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _apiClient.get(
      '/api/teacher/sections-with-students',
      headers: headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('خطأ في جلب الصفوف (${response.statusCode})');
    }

    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (body.isEmpty) return [];

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return [];

    final data = decoded['data'];
    if (data is! List) return [];

    final items = <ClassItem>[];
    for (final entry in data) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final sectionFullName = '${map['section_full_name'] ?? ''}'.trim();
      final totalStudents = map['total_students'] is int
          ? map['total_students'] as int
          : int.tryParse('${map['total_students']}') ?? 0;
      final className = '${map['class_name'] ?? ''}'.trim();
      final sectionName = '${map['section_name'] ?? ''}'.trim();

      final rawStudents = map['students'];
      final studentList = (rawStudents is List)
          ? rawStudents
                .whereType<Map>()
                .map(
                  (student) =>
                      ClassStudent.fromJson(Map<String, dynamic>.from(student)),
                )
                .toList()
          : <ClassStudent>[];

      String subject = '';
      final schedules = map['schedules'];
      if (schedules is List && schedules.isNotEmpty) {
        final first = schedules.first;
        if (first is Map && first['subject_name'] != null)
          subject = '${first['subject_name']}'.trim();
      }

      items.add(
        ClassItem(
          id: map['section_id'] is int
              ? map['section_id'] as int
              : int.tryParse('${map['section_id']}') ?? 0,
          title: sectionFullName.isNotEmpty ? sectionFullName : className,
          subtitle: '${totalStudents} طالب • شعبة $sectionName',
          status: 'نشط',
          statusColor: AppColors.primary,
          icon: Icons.class_,
          color: AppColors.primary,
          students: totalStudents,
          grade: className,
          subject: subject,
          studentList: studentList,
        ),
      );
    }

    return items;
  }
}
