import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/teacher_attendance_section.dart';
import '../../data/repositories/attendance_repository.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit(this._repository) : super(AttendanceState.initial());

  final AttendanceRepository _repository;
  String? _token;

  Future<void> loadAttendance(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final sections = await _repository.fetchSectionsWithStudents(token);
      final selectedSectionId = sections.isNotEmpty ? sections.first.sectionId : 0;
      final selectedScheduleId = sections.isNotEmpty && sections.first.schedules.isNotEmpty
          ? sections.first.schedules.first.scheduleId
          : 0;
      final selectedDate = sections.isNotEmpty ? sections.first.attendance.date : '';

      emit(state.copyWith(
        isLoading: false,
        sections: sections,
        selectedSectionId: selectedSectionId,
        selectedScheduleId: selectedScheduleId,
        selectedDate: selectedDate,
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString().replaceFirst('Exception: ', '')));
    }
  }

  void selectSection(int sectionId) {
    if (state.sections.isEmpty) return;

    final section = state.sections.firstWhere(
      (item) => item.sectionId == sectionId,
      orElse: () => state.sections.first,
    );

    final scheduleId = section.schedules.isNotEmpty ? section.schedules.first.scheduleId : 0;
    final date = section.attendance.date;

    emit(state.copyWith(
      selectedSectionId: sectionId,
      selectedScheduleId: scheduleId,
      selectedDate: date,
    ));
  }

  void selectSchedule(int scheduleId) {
    emit(state.copyWith(selectedScheduleId: scheduleId));
  }

  void updateAttendance(int studentId, String newStatus) {
    if (state.sections.isEmpty || state.selectedSectionId == 0) return;

    final sections = state.sections.map((section) {
      if (section.sectionId != state.selectedSectionId) return section;
      final students = section.students.map((student) {
        if (student.studentId != studentId) return student;
        return student.copyWith(attendanceStatus: newStatus);
      }).toList();
      return section.copyWith(students: students);
    }).toList();

    emit(state.copyWith(sections: sections));
  }

  Future<bool> saveAttendance() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return false;
    }
    final selectedSection = state.selectedSection;
    if (selectedSection == null) {
      emit(state.copyWith(errorMessage: 'لم يتم تحديد الشعبة'));
      return false;
    }

    emit(state.copyWith(isSaving: true, errorMessage: null));

    try {
      final payload = <Map<String, dynamic>>[];
      final seenStudentIds = <int>{};

      for (final student in state.filteredStudents) {
        if (seenStudentIds.contains(student.studentId)) continue;
        seenStudentIds.add(student.studentId);
        payload.add({
          'student_id': student.studentId,
          'status': _mapAttendanceStatus(student.attendanceStatus),
        });
      }

      await _repository.batchUpdateAttendance(
        token: token,
        sectionId: state.selectedSectionId,
        date: state.selectedDate.isEmpty
            ? DateTime.now().toIso8601String().split('T').first
            : state.selectedDate,
        scheduleId: state.selectedScheduleId,
        students: payload,
      );

      emit(state.copyWith(isSaving: false));
      return true;
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString().replaceFirst('Exception: ', '')));
      return false;
    }
  }

  String _mapAttendanceStatus(String status) {
    switch (status) {
      case 'present':
        return 'present';
      case 'late':
        return 'late';
      case 'absent':
        return 'absent';
      default:
        return 'present';
    }
  }
}
