class TeacherDashboardResponse {
  const TeacherDashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final TeacherDashboardSummary data;

  factory TeacherDashboardResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return TeacherDashboardResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: TeacherDashboardSummary.fromJson(
        dataJson is Map<String, dynamic>
            ? dataJson
            : Map<String, dynamic>.from(dataJson ?? {}),
      ),
    );
  }
}

class TeacherDashboardSummary {
  const TeacherDashboardSummary({
    required this.presentStudentsCount,
    required this.activeStudentsCount,
    required this.attendancePercentage,
    required this.pendingAbsenceJustificationRequestsCount,
    required this.unreadNotesCount,
    required this.pendingTasksCount,
    required this.todayAnnouncementsCount,
  });

  final int presentStudentsCount;
  final int activeStudentsCount;
  final double attendancePercentage;
  final int pendingAbsenceJustificationRequestsCount;
  final int unreadNotesCount;
  final int pendingTasksCount;
  final int todayAnnouncementsCount;

  factory TeacherDashboardSummary.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardSummary(
      presentStudentsCount: _parseInt(json['present_students_count']),
      activeStudentsCount: _parseInt(json['active_students_count']),
      attendancePercentage: _parseDouble(json['attendance_percentage']),
      pendingAbsenceJustificationRequestsCount: _parseInt(json['pending_absence_justification_requests_count']),
      unreadNotesCount: _parseInt(json['unread_notes_count']),
      pendingTasksCount: _parseInt(json['pending_tasks_count']),
      todayAnnouncementsCount: _parseInt(json['today_announcements_count']),
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}
