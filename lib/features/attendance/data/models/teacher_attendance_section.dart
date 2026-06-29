class TeacherAttendanceSection {
  TeacherAttendanceSection({
    required this.sectionId,
    required this.sectionName,
    required this.sectionFullName,
    required this.classId,
    required this.className,
    required this.totalStudents,
    required this.attendance,
    required this.schedules,
    required this.students,
  });

  final int sectionId;
  final String sectionName;
  final String sectionFullName;
  final int classId;
  final String className;
  final int totalStudents;
  TeacherAttendanceSummary attendance;
  final List<TeacherAttendanceSchedule> schedules;
  final List<TeacherAttendanceStudent> students;

  factory TeacherAttendanceSection.fromJson(Map<String, dynamic> json) {
    final attendanceJson = json['attendance'];
    final schedulesJson = json['schedules'];
    final studentsJson = json['students'];

    return TeacherAttendanceSection(
      sectionId: _toInt(json['section_id']),
      sectionName: '${json['section_name'] ?? ''}'.trim(),
      sectionFullName: '${json['section_full_name'] ?? ''}'.trim(),
      classId: _toInt(json['class_id']),
      className: '${json['class_name'] ?? ''}'.trim(),
      totalStudents: _toInt(json['total_students']),
      attendance: TeacherAttendanceSummary.fromJson(
        attendanceJson is Map ? Map<String, dynamic>.from(attendanceJson) : <String, dynamic>{},
      ),
      schedules: (schedulesJson is List)
          ? schedulesJson
              .whereType<Map>()
              .map((item) => TeacherAttendanceSchedule.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : <TeacherAttendanceSchedule>[],
      students: _normalizeStudents(studentsJson),
    );
  }

  static List<TeacherAttendanceStudent> _normalizeStudents(dynamic studentsJson) {
    if (studentsJson is! List) {
      return <TeacherAttendanceStudent>[];
    }

    final students = <TeacherAttendanceStudent>[];
    final seenStudentIds = <int>{};

    for (final item in studentsJson.whereType<Map>()) {
      final student = TeacherAttendanceStudent.fromJson(Map<String, dynamic>.from(item));
      if (seenStudentIds.add(student.studentId)) {
        students.add(student);
        continue;
      }

      final index = students.indexWhere((entry) => entry.studentId == student.studentId);
      if (index >= 0) {
        students[index] = student;
      }
    }

    return students;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class TeacherAttendanceSummary {
  TeacherAttendanceSummary({
    required this.date,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.percentage,
  });

  final String date;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double percentage;

  factory TeacherAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceSummary(
      date: '${json['date'] ?? ''}'.trim(),
      present: TeacherAttendanceSection._toInt(json['present']),
      absent: TeacherAttendanceSection._toInt(json['absent']),
      late: TeacherAttendanceSection._toInt(json['late']),
      excused: TeacherAttendanceSection._toInt(json['excused']),
      percentage: double.tryParse('${json['percentage'] ?? 0}') ?? 0,
    );
  }
}

class TeacherAttendanceSchedule {
  TeacherAttendanceSchedule({
    required this.scheduleId,
    required this.subjectName,
    required this.day,
    required this.timeSlot,
    required this.termName,
  });

  final int scheduleId;
  final String subjectName;
  final String day;
  final TeacherTimeSlot timeSlot;
  final String termName;

  factory TeacherAttendanceSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceSchedule(
      scheduleId: TeacherAttendanceSection._toInt(json['schedule_id']),
      subjectName: '${json['subject_name'] ?? ''}'.trim(),
      day: '${json['day'] ?? ''}'.trim(),
      timeSlot: TeacherTimeSlot.fromJson(
        json['time_slot'] is Map ? Map<String, dynamic>.from(json['time_slot']) : <String, dynamic>{},
      ),
      termName: '${json['term_name'] ?? ''}'.trim(),
    );
  }
}

class TeacherTimeSlot {
  TeacherTimeSlot({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  final int id;
  final String name;
  final String startTime;
  final String endTime;

  factory TeacherTimeSlot.fromJson(Map<String, dynamic> json) {
    return TeacherTimeSlot(
      id: TeacherAttendanceSection._toInt(json['id']),
      name: '${json['name'] ?? ''}'.trim(),
      startTime: '${json['start_time'] ?? ''}'.trim(),
      endTime: '${json['end_time'] ?? ''}'.trim(),
    );
  }
}

class TeacherAttendanceStudent {
  TeacherAttendanceStudent({
    required this.studentId,
    required this.enrollmentId,
    required this.registryNumber,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.parent,
    required this.attendanceStatus,
  });

  final int studentId;
  final int enrollmentId;
  final String registryNumber;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String birthDate;
  final TeacherAttendanceParent parent;
  String attendanceStatus;

  factory TeacherAttendanceStudent.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceStudent(
      studentId: TeacherAttendanceSection._toInt(json['student_id']),
      enrollmentId: TeacherAttendanceSection._toInt(json['enrollment_id']),
      registryNumber: '${json['registry_number'] ?? ''}'.trim(),
      fullName: '${json['full_name'] ?? ''}'.trim(),
      firstName: '${json['first_name'] ?? ''}'.trim(),
      lastName: '${json['last_name'] ?? ''}'.trim(),
      email: '${json['email'] ?? ''}'.trim(),
      phone: '${json['phone'] ?? ''}'.trim(),
      gender: '${json['gender'] ?? ''}'.trim(),
      birthDate: '${json['birth_date'] ?? ''}'.trim(),
      parent: TeacherAttendanceParent.fromJson(
        json['parent'] is Map ? Map<String, dynamic>.from(json['parent']) : <String, dynamic>{},
      ),
      attendanceStatus: '${json['attendance_status'] ?? ''}'.trim(),
    );
  }
}

class TeacherAttendanceParent {
  TeacherAttendanceParent({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String phone;

  factory TeacherAttendanceParent.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceParent(
      id: TeacherAttendanceSection._toInt(json['id']),
      name: '${json['name'] ?? ''}'.trim(),
      email: '${json['email'] ?? ''}'.trim(),
      phone: '${json['phone'] ?? ''}'.trim(),
    );
  }
}

class AttendanceBatchUpdateResult {
  AttendanceBatchUpdateResult({
    required this.sectionId,
    required this.date,
    required this.present,
    required this.absent,
    required this.late,
    required this.attendanceRate,
  });

  final int sectionId;
  final String date;
  final int present;
  final int absent;
  final int late;
  final int attendanceRate;

  factory AttendanceBatchUpdateResult.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'];
    return AttendanceBatchUpdateResult(
      sectionId: TeacherAttendanceSection._toInt(json['section_id']),
      date: '${json['date'] ?? ''}'.trim(),
      present: TeacherAttendanceSection._toInt(counts is Map ? counts['present'] : null),
      absent: TeacherAttendanceSection._toInt(counts is Map ? counts['absent'] : null),
      late: TeacherAttendanceSection._toInt(counts is Map ? counts['late'] : null),
      attendanceRate: TeacherAttendanceSection._toInt(counts is Map ? counts['attendance_rate'] : null),
    );
  }
}
