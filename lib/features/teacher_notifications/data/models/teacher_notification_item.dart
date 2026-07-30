class TeacherNotificationItem {
  TeacherNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.group,
    required this.groupLabel,
    required this.studentName,
    required this.teacherName,
    required this.type,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String group;
  final String groupLabel;
  final String? studentName;
  final String? teacherName;
  final String? type;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  factory TeacherNotificationItem.fromJson(Map<String, dynamic> json) {
    return TeacherNotificationItem(
      id: _readString(json['id']),
      title: _readString(json['title']),
      body: _readString(json['body']),
      group: _readString(json['group']),
      groupLabel: _readString(json['group_label']).isNotEmpty ? _readString(json['group_label']) : _deriveGroupLabel(_readString(json['group'])),
      studentName: _nullableString(json['student_name']),
      teacherName: _nullableString(json['teacher_name']),
      type: _nullableString(json['type']),
      isRead: json['is_read'] == true,
      readAt: _nullableString(json['read_at']),
      createdAt: _readString(json['created_at']),
    );
  }

  TeacherNotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? group,
    String? groupLabel,
    String? studentName,
    String? teacherName,
    String? type,
    bool? isRead,
    String? readAt,
    String? createdAt,
  }) {
    return TeacherNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      group: group ?? this.group,
      groupLabel: groupLabel ?? this.groupLabel,
      studentName: studentName ?? this.studentName,
      teacherName: teacherName ?? this.teacherName,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get shortBody {
    if (body.length <= 105) return body;
    return '${body.substring(0, 102)}...';
  }

  String get audienceLabel {
    if (groupLabel.isNotEmpty) return groupLabel;
    return _deriveGroupLabel(group);
  }

  static String _readString(dynamic value) => '${value ?? ''}'.trim();

  static String? _nullableString(dynamic value) {
    final text = _readString(value);
    return text.isEmpty ? null : text;
  }

  static String _deriveGroupLabel(String group) {
    switch (group.toLowerCase()) {
      case 'admin':
        return 'الإدارة';
      case 'parent':
        return 'ولي أمر';
      case 'teacher':
        return 'معلم';
      default:
        return group.isEmpty ? 'الإشعار' : group;
    }
  }
}
