import 'parent_note_attachment.dart';

class ParentNote {
  const ParentNote({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.title,
    required this.content,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.teacherName,
    required this.studentName,
    required this.studentUserName,
    required this.studentParentName,
    required this.attachments,
  });

  final int id;
  final int teacherId;
  final int studentId;
  final String title;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String teacherName;
  final String studentName;
  final String studentUserName;
  final String studentParentName;
  final List<ParentNoteAttachment> attachments;

  bool get hasAttachments => attachments.isNotEmpty;

  String get recipientLabel {
    if (studentParentName.isNotEmpty) {
      return studentParentName;
    }
    if (studentName.isNotEmpty) {
      return studentName;
    }
    return 'ولي الأمر';
  }

  String get formattedCreatedAt {
    final date = createdAt ?? DateTime.now();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  ParentNote copyWith({
    String? title,
    String? content,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ParentNoteAttachment>? attachments,
  }) {
    return ParentNote(
      id: id,
      teacherId: teacherId,
      studentId: studentId,
      title: title ?? this.title,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      teacherName: teacherName,
      studentName: studentName,
      studentUserName: studentUserName,
      studentParentName: studentParentName,
      attachments: attachments ?? this.attachments,
    );
  }

  factory ParentNote.fromJson(Map<String, dynamic> json) {
    final teacher = _readMap(json['teacher']);
    final student = _readMap(json['student']);
    final user = _readMap(student['user']);
    final parent = _readMap(student['parent']);

    final attachmentsValue = json['attachments'];
    final attachments = attachmentsValue is List
        ? attachmentsValue
            .whereType<Map>()
            .map((item) => ParentNoteAttachment.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <ParentNoteAttachment>[];

    return ParentNote(
      id: _readInt(json['id']),
      teacherId: _readInt(json['teacher_id']),
      studentId: _readInt(json['student_id']),
      title: _readString(json['title']),
      content: _readString(json['content']),
      isRead: json['is_read'] == true,
      readAt: _readDateTime(json['read_at']),
      createdAt: _readDateTime(json['created_at']),
      updatedAt: _readDateTime(json['updated_at']),
      teacherName: _readString(teacher['name']),
      studentName: _readString(student['full_name']),
      studentUserName: _readString(user['name']),
      studentParentName: _readString(parent['name']),
      attachments: attachments,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static String _readString(dynamic value) => value == null ? '' : '$value'.trim();

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse('$value');
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}