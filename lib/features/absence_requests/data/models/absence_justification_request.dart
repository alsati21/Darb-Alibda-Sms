class AbsenceJustificationRequest {
  AbsenceJustificationRequest({
    required this.id,
    required this.studentName,
    required this.className,
    required this.absenceDate,
    required this.reason,
    required this.status,
    required this.reviewNote,
    required this.parentName,
    required this.parentPhone,
    required this.hasAttachment,
    required this.createdAt,
  });

  final int id;
  final String studentName;
  final String className;
  final String absenceDate;
  final String reason;
  final String status;
  final String reviewNote;
  final String parentName;
  final String parentPhone;
  final bool hasAttachment;
  final String createdAt;

  factory AbsenceJustificationRequest.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'];
    final parentJson = json['parent'];
    final attachments = json['attachments'];

    return AbsenceJustificationRequest(
      id: _toInt(json['id']),
      studentName: _readString(studentJson is Map ? studentJson['full_name'] : null),
      className: _readString(json['class_name']) + (json['section_name'] != null ? ' • ${_readString(json['section_name'])}' : ''),
      absenceDate: _readString(json['absence_date']),
      reason: _readString(json['reason']),
      status: _readString(json['status']),
      reviewNote: _readString(json['review_note']),
      parentName: _readString(parentJson is Map ? parentJson['name'] : null),
      parentPhone: _readString(parentJson is Map ? parentJson['phone'] : null),
      hasAttachment: attachments is List && attachments.isNotEmpty,
      createdAt: _readString(json['created_at']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static String _readString(dynamic value) {
    return '${value ?? ''}'.trim();
  }
}
