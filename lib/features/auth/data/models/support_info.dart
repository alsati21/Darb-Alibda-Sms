class SupportInfo {
  SupportInfo({
    required this.title,
    required this.body,
    required this.phone,
    required this.email,
    required this.workingHours,
    required this.additionalInfo,
  });

  final String title;
  final String body;
  final String phone;
  final String email;
  final String workingHours;
  final String additionalInfo;

  factory SupportInfo.fromJson(Map<String, dynamic> json) {
    final support = json['support'] as Map<String, dynamic>? ?? {};
    final contact = support['contact'] as Map<String, dynamic>? ?? {};
    final instructions = support['instructions'] as Map<String, dynamic>? ?? {};

    return SupportInfo(
      title: _readString(support['title']),
      body: _readString(support['body']),
      phone: _readString(contact['phone']),
      email: _readString(contact['email']),
      workingHours: _readString(instructions['أوقات التواصل']),
      additionalInfo: _readString(instructions['معلومات إضافية']),
    );
  }

  static String _readString(dynamic value) => '${value ?? ''}'.trim();
}
