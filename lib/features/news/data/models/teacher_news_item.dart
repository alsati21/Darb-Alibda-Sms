class TeacherNewsItem {
  const TeacherNewsItem({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.isRead,
    required this.creatorName,
    required this.creatorEmail,
    required this.attachmentCount,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String audience;
  final bool isRead;
  final String creatorName;
  final String creatorEmail;
  final int attachmentCount;
  final DateTime createdAt;

  bool get hasAttachments => attachmentCount > 0;

  String get formattedCreatedAt {
    final date = createdAt.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  TeacherNewsItem copyWith({bool? isRead}) {
    return TeacherNewsItem(
      id: id,
      title: title,
      body: body,
      audience: audience,
      isRead: isRead ?? this.isRead,
      creatorName: creatorName,
      creatorEmail: creatorEmail,
      attachmentCount: attachmentCount,
      createdAt: createdAt,
    );
  }

  factory TeacherNewsItem.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'];
    final creatorMap = creator is Map<String, dynamic>
        ? creator
        : (creator is Map ? Map<String, dynamic>.from(creator) : <String, dynamic>{});

    final attachments = json['attachments'];
    final attachmentsList = attachments is List ? attachments : const [];

    return TeacherNewsItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: '${json['title'] ?? ''}'.trim(),
      body: '${json['body'] ?? ''}'.trim(),
      audience: '${json['audience'] ?? ''}'.trim(),
      isRead: json['is_read'] == true,
      creatorName: '${creatorMap['name'] ?? ''}'.trim(),
      creatorEmail: '${creatorMap['email'] ?? ''}'.trim(),
      attachmentCount: attachmentsList.length,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
    );
  }
}

class TeacherUnreadCount {
  const TeacherUnreadCount({required this.unreadCount});

  final int unreadCount;

  factory TeacherUnreadCount.fromJson(Map<String, dynamic> json) {
    return TeacherUnreadCount(
      unreadCount: json['unread_count'] is int
          ? json['unread_count'] as int
          : int.tryParse('${json['unread_count']}') ?? 0,
    );
  }
}
