import '../models/grade_item.dart';

/// Sentinel used to distinguish "caller didn't pass this argument" from
/// "caller explicitly passed null" in copyWith. Needed because
/// `value ?? this.value` can never actually clear a nullable field to
/// null — it always falls back to the old value instead.
class _Unset {
  const _Unset();
}

const Object _unset = _Unset();

class GradesState {
  const GradesState({
    required this.selectedGrade,
    required this.selectedSection,
    required this.gradeItems,
    required this.isLoading,
    required this.errorMessage,
    required this.successMessage,
  });

  final String selectedGrade;
  final String selectedSection;
  final List<GradeItem> gradeItems;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  factory GradesState.initial() {
    return GradesState(
      selectedGrade: 'الصف الثالث',
      selectedSection: 'A',
      gradeItems: const [],
      isLoading: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  GradesState copyWith({
    String? selectedGrade,
    String? selectedSection,
    List<GradeItem>? gradeItems,
    bool? isLoading,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return GradesState(
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedSection: selectedSection ?? this.selectedSection,
      gradeItems: gradeItems ?? this.gradeItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  List<GradeItem> get visibleGrades {
    return gradeItems
        .where((grade) =>
    grade.grade == selectedGrade &&
        grade.section == selectedSection)
        .toList();
  }

  double get averageGrade {
    final grades = visibleGrades;
    if (grades.isEmpty) return 0;
    final sum = grades.map((e) => e.mark).reduce((a, b) => a + b);
    return sum / grades.length;
  }

  int get excellentCount => visibleGrades.where((grade) => grade.mark >= 90).length;
  int get goodCount => visibleGrades.where((grade) => grade.mark >= 80 && grade.mark < 90).length;
  int get fairCount => visibleGrades.where((grade) => grade.mark >= 70 && grade.mark < 80).length;
}