import '../../data/models/teacher_feedback_item.dart';

class TeacherFeedbackState {
  const TeacherFeedbackState({
    required this.isLoading,
    required this.isSubmitting,
    required this.isDetailLoading,
    required this.suggestions,
    required this.selectedSuggestion,
    required this.errorMessage,
    required this.successMessage,
  });

  factory TeacherFeedbackState.initial() {
    return const TeacherFeedbackState(
      isLoading: false,
      isSubmitting: false,
      isDetailLoading: false,
      suggestions: <TeacherFeedbackItem>[],
      selectedSuggestion: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  final bool isLoading;
  final bool isSubmitting;
  final bool isDetailLoading;
  final List<TeacherFeedbackItem> suggestions;
  final TeacherFeedbackItem? selectedSuggestion;
  final String? errorMessage;
  final String? successMessage;

  TeacherFeedbackState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isDetailLoading,
    List<TeacherFeedbackItem>? suggestions,
    TeacherFeedbackItem? selectedSuggestion,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedSuggestion = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return TeacherFeedbackState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      suggestions: suggestions ?? this.suggestions,
      selectedSuggestion: clearSelectedSuggestion ? null : (selectedSuggestion ?? this.selectedSuggestion),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
