import '../../data/models/teacher_dashboard_summary.dart';

class DashboardState {
  const DashboardState({
    required this.isLoading,
    required this.errorMessage,
    required this.summary,
  });

  final bool isLoading;
  final String? errorMessage;
  final TeacherDashboardSummary? summary;

  factory DashboardState.initial() {
    return const DashboardState(
      isLoading: false,
      errorMessage: null,
      summary: null,
    );
  }

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    TeacherDashboardSummary? summary,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      summary: summary ?? this.summary,
    );
  }
}
