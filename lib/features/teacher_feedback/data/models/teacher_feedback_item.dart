class TeacherFeedbackItem {
  TeacherFeedbackItem({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    required this.statusLabel,
    required this.feedback,
    required this.isAcknowledged,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String body;
  final String status;
  final String statusLabel;
  final String? feedback;
  final bool isAcknowledged;
  final String createdAt;
  final String updatedAt;

  factory TeacherFeedbackItem.fromJson(Map<String, dynamic> json) {
    return TeacherFeedbackItem(
      id: _toInt(json['id']),
      title: _readString(json['title']),
      body: _readString(json['body']),
      status: _readString(json['status']),
      statusLabel: _readString(json['status_label']).isNotEmpty ? _readString(json['status_label']) : _deriveStatusLabel(_readString(json['status'])),
      feedback: _nullableString(json['feedback']),
      isAcknowledged: json['is_acknowledged'] == true,
      createdAt: _readString(json['created_at']),
      updatedAt: _readString(json['updated_at']),
    );
  }

  TeacherFeedbackItem copyWith({
    int? id,
    String? title,
    String? body,
    String? status,
    String? statusLabel,
    String? feedback,
    bool? isAcknowledged,
    String? createdAt,
    String? updatedAt,
  }) {
    return TeacherFeedbackItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      feedback: feedback ?? this.feedback,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get shortBody {
    if (body.length <= 110) {
      return body;
    }
    return '${body.substring(0, 107)}...';
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isResolved {
    final normalized = status.toLowerCase();
    return normalized == 'resolved' || normalized == 'approved' || normalized == 'replied';
  }

  String get statusLabelArabic {
    final normalized = status.toLowerCase();
    if (normalized == 'pending') return 'قيد المراجعة';
    if (normalized == 'resolved' || normalized == 'approved' || normalized == 'replied') return 'تم الرد';
    if (normalized == 'rejected') return 'مرفوض';
    return statusLabel.isNotEmpty ? statusLabel : status;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static String _readString(dynamic value) {
    return '${value ?? ''}'.trim();
  }

  static String? _nullableString(dynamic value) {
    final text = _readString(value);
    return text.isEmpty ? null : text;
  }

  static String _deriveStatusLabel(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'pending') return 'Pending';
    if (normalized == 'resolved' || normalized == 'approved' || normalized == 'replied') return 'Resolved';
    if (normalized == 'rejected') return 'Rejected';
    return status;
  }
}
