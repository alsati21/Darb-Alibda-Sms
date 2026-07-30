class ParentNoteAttachment {
  const ParentNoteAttachment({
    required this.id,
    required this.fileName,
    required this.path,
    required this.mimeType,
    required this.size,
    required this.url,
  });

  final int id;
  final String fileName;
  final String path;
  final String mimeType;
  final int size;
  final String url;

  factory ParentNoteAttachment.fromJson(Map<String, dynamic> json) {
    return ParentNoteAttachment(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      fileName: '${json['file_name'] ?? ''}'.trim(),
      path: '${json['path'] ?? ''}'.trim(),
      mimeType: '${json['mime_type'] ?? ''}'.trim(),
      size: json['size'] is int ? json['size'] as int : int.tryParse('${json['size']}') ?? 0,
      url: '${json['url'] ?? ''}'.trim(),
    );
  }
}