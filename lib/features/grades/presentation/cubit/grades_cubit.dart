import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/grade_item.dart';
import 'grades_state.dart';
import '../../../../shared/theme/app_colors.dart';

class GradesCubit extends Cubit<GradesState> {
  GradesCubit() : super(GradesState.initial()) {
    _loadInitialGrades();
  }

  void _loadInitialGrades() {
    final items = const [
      GradeItem(
        id: '1',
        studentName: 'قيس حمدان',
        score: 91,
        status: 'ممتاز',
        color: AppColors.success,
        date: '15/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'الامتحانات',
      ),
      GradeItem(
        id: '2',
        studentName: 'هدى منصور',
        score: 87,
        status: 'جيد جداً',
        color: AppColors.primary,
        date: '15/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'الامتحانات',
      ),
      GradeItem(
        id: '3',
        studentName: 'ريان النجار',
        score: 78,
        status: 'جيد',
        color: AppColors.warning,
        date: '15/5/2024',
        grade: 'الصف الثالث',
        section: 'B',
        type: 'الامتحانات',
      ),
      GradeItem(
        id: '4',
        studentName: 'سارة أحمد',
        score: 95,
        status: 'ممتاز',
        color: AppColors.success,
        date: '15/5/2024',
        grade: 'الصف الأول',
        section: 'A',
        type: 'الامتحانات',
      ),
      GradeItem(
        id: '5',
        studentName: 'محمد علي',
        score: 82,
        status: 'جيد جداً',
        color: AppColors.primary,
        date: '15/5/2024',
        grade: 'الصف الثاني',
        section: 'B',
        type: 'الامتحانات',
      ),
      GradeItem(
        id: '6',
        studentName: 'قيس حمدان',
        score: 88,
        status: 'جيد جداً',
        color: AppColors.primary,
        date: '12/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'الواجبات',
      ),
      GradeItem(
        id: '7',
        studentName: 'هدى منصور',
        score: 92,
        status: 'ممتاز',
        color: AppColors.success,
        date: '12/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'الواجبات',
      ),
      GradeItem(
        id: '8',
        studentName: 'ريان النجار',
        score: 75,
        status: 'جيد',
        color: AppColors.warning,
        date: '12/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'الواجبات',
      ),
      GradeItem(
        id: '9',
        studentName: 'قيس حمدان',
        score: 85,
        status: 'جيد جداً',
        color: AppColors.primary,
        date: '10/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'النشاطات',
      ),
      GradeItem(
        id: '10',
        studentName: 'هدى منصور',
        score: 90,
        status: 'ممتاز',
        color: AppColors.success,
        date: '10/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'النشاطات',
      ),
      GradeItem(
        id: '11',
        studentName: 'ريان النجار',
        score: 80,
        status: 'جيد جداً',
        color: AppColors.primary,
        date: '10/5/2024',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'النشاطات',
      ),
    ];
    emit(state.copyWith(gradeItems: items));
  }

  void selectTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void selectGrade(String grade) {
    emit(state.copyWith(selectedGrade: grade, selectedSection: _defaultSectionForGrade(grade)));
  }

  void selectSection(String section) {
    emit(state.copyWith(selectedSection: section));
  }

  void updateGradeScore(String id, int newScore) {
    final updatedItems = state.gradeItems.map((item) {
      if (item.id != id) return item;
      return item.copyWith(
        score: newScore,
        status: _getGradeStatus(newScore),
        color: _getGradeColor(newScore),
      );
    }).toList();
    emit(state.copyWith(gradeItems: updatedItems));
  }

  String _defaultSectionForGrade(String grade) {
    final sections = state.gradeItems
        .where((item) => item.grade == grade)
        .map((item) => item.section)
        .toSet()
        .toList();
    return sections.isNotEmpty ? sections.first : 'A';
  }

  String _getGradeStatus(int score) {
    if (score >= 90) return 'ممتاز';
    if (score >= 80) return 'جيد جداً';
    if (score >= 70) return 'جيد';
    if (score >= 60) return 'مقبول';
    return 'ضعيف';
  }

  Color _getGradeColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.primary;
    if (score >= 70) return AppColors.warning;
    if (score >= 60) return AppColors.info;
    return AppColors.error;
  }
}
