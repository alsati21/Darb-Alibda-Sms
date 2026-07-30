class TeacherComplaintItem {
  TeacherComplaintItem({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    required this.statusLabel,
    required this.response,
    required this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String body;
  final String status;
  final String statusLabel;
  final String? response;
  final String? resolvedAt;
  final String createdAt;
  final String updatedAt;

  factory TeacherComplaintItem.fromJson(Map<String, dynamic> json) {
    return TeacherComplaintItem(
      id: _toInt(json['id']),
      title: _readString(json['title']),
      body: _readString(json['body']),
      status: _readString(json['status']),
      statusLabel: _readString(json['status_label']).isNotEmpty ? _readString(json['status_label']) : _deriveStatusLabel(_readString(json['status'])),
      response: _nullableString(json['response']),
      resolvedAt: _nullableString(json['resolved_at']),
      createdAt: _readString(json['created_at']),
      updatedAt: _readString(json['updated_at']),
    );
  }

  String get shortBody {
    if (body.length <= 110) return body;
    return '${body.substring(0, 107)}...';
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isResolved {
    final normalized = status.toLowerCase();
    return normalized == 'resolved' || normalized == 'approved' || normalized == 'replied';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static String _readString(dynamic value) => '${value ?? ''}'.trim();

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
