import '../../data/models/teacher_complaint_item.dart';

class TeacherComplaintsState {
  const TeacherComplaintsState({
    required this.isLoading,
    required this.isSubmitting,
    required this.isDetailLoading,
    required this.complaints,
    required this.selectedComplaint,
    required this.errorMessage,
    required this.successMessage,
  });

  factory TeacherComplaintsState.initial() {
    return const TeacherComplaintsState(
      isLoading: false,
      isSubmitting: false,
      isDetailLoading: false,
      complaints: <TeacherComplaintItem>[],
      selectedComplaint: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  final bool isLoading;
  final bool isSubmitting;
  final bool isDetailLoading;
  final List<TeacherComplaintItem> complaints;
  final TeacherComplaintItem? selectedComplaint;
  final String? errorMessage;
  final String? successMessage;

  TeacherComplaintsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isDetailLoading,
    List<TeacherComplaintItem>? complaints,
    TeacherComplaintItem? selectedComplaint,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedComplaint = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return TeacherComplaintsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      complaints: complaints ?? this.complaints,
      selectedComplaint: clearSelectedComplaint ? null : (selectedComplaint ?? this.selectedComplaint),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
