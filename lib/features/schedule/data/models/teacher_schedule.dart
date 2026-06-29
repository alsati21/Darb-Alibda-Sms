class TeacherTodayScheduleItem {
  TeacherTodayScheduleItem({
    required this.id,
    required this.subject,
    required this.section,
    required this.className,
    required this.day,
    required this.timeSlot,
    required this.term,
  });

  final int id;
  final String subject;
  final String section;
  final String className;
  final String day;
  final TeacherTimeSlot timeSlot;
  final String term;

  factory TeacherTodayScheduleItem.fromJson(Map<String, dynamic> json) {
    return TeacherTodayScheduleItem(
      id: _toInt(json['id']),
      subject: '${json['subject'] ?? ''}'.trim(),
      section: '${json['section'] ?? ''}'.trim(),
      className: '${json['class'] ?? ''}'.trim(),
      day: '${json['day'] ?? ''}'.trim(),
      timeSlot: TeacherTimeSlot.fromJson(
        json['time_slot'] is Map ? Map<String, dynamic>.from(json['time_slot']) : <String, dynamic>{},
      ),
      term: '${json['term'] ?? ''}'.trim(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class TeacherWeekScheduleItem {
  TeacherWeekScheduleItem({
    required this.id,
    required this.subject,
    required this.section,
    required this.day,
    required this.timeSlot,
  });

  final int id;
  final String subject;
  final String section;
  final String day;
  final TeacherTimeSlot timeSlot;

  factory TeacherWeekScheduleItem.fromJson(Map<String, dynamic> json) {
    return TeacherWeekScheduleItem(
      id: TeacherTodayScheduleItem._toInt(json['id']),
      subject: '${json['subject'] ?? ''}'.trim(),
      section: '${json['section'] ?? ''}'.trim(),
      day: '${json['day'] ?? ''}'.trim(),
      timeSlot: TeacherTimeSlot.fromJson(
        json['time_slot'] is Map ? Map<String, dynamic>.from(json['time_slot']) : <String, dynamic>{},
      ),
    );
  }
}

class TeacherTimeSlot {
  TeacherTimeSlot({
    required this.id,
    required this.periodNumber,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  final int id;
  final int periodNumber;
  final String name;
  final String startTime;
  final String endTime;

  factory TeacherTimeSlot.fromJson(Map<String, dynamic> json) {
    return TeacherTimeSlot(
      id: TeacherTodayScheduleItem._toInt(json['id']),
      periodNumber: TeacherTodayScheduleItem._toInt(json['period_number']),
      name: '${json['name'] ?? ''}'.trim(),
      startTime: '${json['start_time'] ?? ''}'.trim(),
      endTime: '${json['end_time'] ?? ''}'.trim(),
    );
  }
}
