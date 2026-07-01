import '../../data/models/teacher_attendance_section.dart';

class AttendanceState {
  const AttendanceState({
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
    required this.sections,
    required this.selectedSectionId,
    required this.selectedScheduleId,
    required this.selectedDate,
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final List<TeacherAttendanceSection> sections;
  final int selectedSectionId;
  final int selectedScheduleId;
  final String selectedDate;

  factory AttendanceState.initial() {
    return const AttendanceState(
      isLoading: false,
      isSaving: false,
      errorMessage: null,
      sections: <TeacherAttendanceSection>[],
      selectedSectionId: 0,
      selectedScheduleId: 0,
      selectedDate: '',
    );
  }

  AttendanceState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    List<TeacherAttendanceSection>? sections,
    int? selectedSectionId,
    int? selectedScheduleId,
    String? selectedDate,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      sections: sections ?? this.sections,
      selectedSectionId: selectedSectionId ?? this.selectedSectionId,
      selectedScheduleId: selectedScheduleId ?? this.selectedScheduleId,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  TeacherAttendanceSection? get selectedSection {
    if (selectedSectionId == 0 || sections.isEmpty) return null;
    return sections.firstWhere(
      (item) => item.sectionId == selectedSectionId,
      orElse: () => sections.first,
    );
  }

  List<TeacherAttendanceStudent> get filteredStudents {
    return selectedSection?.students ?? <TeacherAttendanceStudent>[];
  }

  int get presentCount => filteredStudents.where((item) => item.attendanceStatus == 'present').length;

  int get lateCount => filteredStudents.where((item) => item.attendanceStatus == 'late').length;

  int get absentCount => filteredStudents.where((item) => item.attendanceStatus == 'absent').length;

  double get attendancePercentage {
    final count = filteredStudents.length;
    if (count == 0) return 0;
    return (presentCount + lateCount) / count * 100;
  }
}
