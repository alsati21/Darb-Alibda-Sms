import '../../data/models/teacher_schedule.dart';

class ScheduleState {
  const ScheduleState({
    required this.isLoading,
    required this.errorMessage,
    required this.todayItems,
    required this.weekItems,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<TeacherTodayScheduleItem> todayItems;
  final Map<String, List<TeacherWeekScheduleItem>> weekItems;

  factory ScheduleState.initial() {
    return const ScheduleState(
      isLoading: false,
      errorMessage: null,
      todayItems: <TeacherTodayScheduleItem>[],
      weekItems: <String, List<TeacherWeekScheduleItem>>{},
    );
  }

  ScheduleState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TeacherTodayScheduleItem>? todayItems,
    Map<String, List<TeacherWeekScheduleItem>>? weekItems,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      todayItems: todayItems ?? this.todayItems,
      weekItems: weekItems ?? this.weekItems,
    );
  }
}
