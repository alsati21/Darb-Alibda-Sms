import '../models/grade_item.dart';

class GradesState {
  const GradesState({
    required this.selectedTabIndex,
    required this.selectedGrade,
    required this.selectedSection,
    required this.gradeItems,
    required this.isLoading,
  });

  final int selectedTabIndex;
  final String selectedGrade;
  final String selectedSection;
  final List<GradeItem> gradeItems;
  final bool isLoading;

  factory GradesState.initial() {
    return GradesState(
      selectedTabIndex: 0,
      selectedGrade: 'الصف الثالث',
      selectedSection: 'A',
      gradeItems: const [],
      isLoading: false,
    );
  }

  GradesState copyWith({
    int? selectedTabIndex,
    String? selectedGrade,
    String? selectedSection,
    List<GradeItem>? gradeItems,
    bool? isLoading,
  }) {
    return GradesState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedSection: selectedSection ?? this.selectedSection,
      gradeItems: gradeItems ?? this.gradeItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<GradeItem> get visibleGrades {
    return gradeItems
        .where((grade) => grade.grade == selectedGrade && grade.section == selectedSection)
        .toList();
  }

  double get averageGrade {
    final grades = visibleGrades;
    if (grades.isEmpty) return 0;
    final sum = grades.map((e) => e.score).reduce((a, b) => a + b);
    return sum / grades.length;
  }

  int get excellentCount => visibleGrades.where((grade) => grade.score >= 90).length;
  int get goodCount => visibleGrades.where((grade) => grade.score >= 80 && grade.score < 90).length;
  int get fairCount => visibleGrades.where((grade) => grade.score >= 70 && grade.score < 80).length;
}
