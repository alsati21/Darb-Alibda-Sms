import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darb_alibda_sms/features/grades/data/repositories/grades_repository.dart';
import 'package:darb_alibda_sms/features/grades/presentation/cubit/grades_cubit.dart';
import 'package:darb_alibda_sms/features/grades/presentation/models/grade_item.dart';

class FakeGradesRepository extends GradesRepository {
  @override
  Future<List<GradeItem>> fetchMarks(String token) async {
    return [
      GradeItem(
        id: '1',
        studentId: 10,
        studentName: 'أحمد',
        enrollmentId: 1,
        sectionId: 2,
        sectionName: 'A',
        className: 'الصف الثالث',
        subjectId: 3,
        subjectName: 'رياضيات',
        subjectComponentId: 4,
        subjectComponentName: 'امتحان',
        termId: 5,
        termName: 'الأول',
        mark: 80,
        status: 'جيد جداً',
        color: Colors.blue,
        date: '2024-01-01',
        grade: 'الصف الثالث',
        section: 'A',
        type: 'written',
      ),
    ];
  }

  @override
  Future<GradeItem> addMark({
    required String token,
    required int studentId,
    required int sectionId,
    required int subjectId,
    required int subjectComponentId,
    required int termId,
    required int mark,
  }) async {
    return GradeItem(
      id: '2',
      studentId: studentId,
      studentName: 'سارة',
      enrollmentId: 2,
      sectionId: sectionId,
      sectionName: 'A',
      className: 'الصف الثالث',
      subjectId: subjectId,
      subjectName: 'رياضيات',
      subjectComponentId: subjectComponentId,
      subjectComponentName: 'امتحان',
      termId: termId,
      termName: 'الأول',
      mark: mark,
      status: 'ممتاز',
      color: Colors.green,
      date: '2024-01-02',
      grade: 'الصف الثالث',
      section: 'A',
      type: 'written',
    );
  }

  @override
  Future<GradeItem> updateMark({
    required String token,
    required int markId,
    required int mark,
  }) async {
    return GradeItem(
      id: '$markId',
      studentId: 10,
      studentName: 'أحمد',
      enrollmentId: 1,
      sectionId: 2,
      sectionName: 'A',
      className: 'الصف الثالث',
      subjectId: 3,
      subjectName: 'رياضيات',
      subjectComponentId: 4,
      subjectComponentName: 'امتحان',
      termId: 5,
      termName: 'الأول',
      mark: mark,
      status: 'ممتاز',
      color: Colors.green,
      date: '2024-01-01',
      grade: 'الصف الثالث',
      section: 'A',
      type: 'written',
    );
  }

  @override
  Future<void> deleteMark({required String token, required int markId}) async {}
}

class FakeGradesRepositoryWithDifferentSelection extends FakeGradesRepository {
  @override
  Future<GradeItem> addMark({
    required String token,
    required int studentId,
    required int sectionId,
    required int subjectId,
    required int subjectComponentId,
    required int termId,
    required int mark,
  }) async {
    return GradeItem(
      id: '2',
      studentId: studentId,
      studentName: 'سارة',
      enrollmentId: 2,
      sectionId: sectionId,
      sectionName: 'الصف الثاني - ب',
      className: 'الصف الثاني',
      subjectId: subjectId,
      subjectName: 'رياضيات',
      subjectComponentId: subjectComponentId,
      subjectComponentName: 'امتحان',
      termId: termId,
      termName: 'الأول',
      mark: mark,
      status: 'ممتاز',
      color: Colors.green,
      date: '2024-01-02',
      grade: 'الصف الثاني',
      section: 'الصف الثاني - ب',
      type: 'oral',
    );
  }
}

void main() {
  test('addMark appends a new grade item to the state', () async {
    final cubit = GradesCubit(FakeGradesRepository());

    await cubit.loadGrades('token');
    final success = await cubit.addMark(
      studentId: 10,
      sectionId: 2,
      subjectId: 3,
      subjectComponentId: 4,
      termId: 5,
      mark: 95,
    );

    expect(success, isTrue);
    expect(cubit.state.gradeItems, hasLength(2));
    expect(cubit.state.gradeItems.last.mark, 95);
    expect(cubit.state.isLoading, isFalse);
  });

  test('loadGrades selects the first available grade and section from the API response', () async {
    final cubit = GradesCubit(FakeGradesRepository());

    await cubit.loadGrades('token');

    expect(cubit.state.selectedGrade, 'الصف الثالث');
    expect(cubit.state.selectedSection, 'A');
  });

  test('addMark updates the selected grade and section to the created item', () async {
    final cubit = GradesCubit(FakeGradesRepositoryWithDifferentSelection());

    await cubit.loadGrades('token');
    await cubit.addMark(
      studentId: 10,
      sectionId: 2,
      subjectId: 3,
      subjectComponentId: 4,
      termId: 5,
      mark: 95,
    );

    expect(cubit.state.selectedGrade, 'الصف الثاني');
    expect(cubit.state.selectedSection, 'الصف الثاني - ب');
  });

  test('addOrUpdateMark updates an existing grade instead of creating a duplicate', () async {
    final cubit = GradesCubit(FakeGradesRepository());

    await cubit.loadGrades('token');
    final success = await cubit.addOrUpdateMark(
      studentId: 10,
      sectionId: 2,
      subjectId: 3,
      subjectComponentId: 4,
      termId: 5,
      mark: 97,
      type: 'written',
      studentName: 'أحمد',
      subjectName: 'رياضيات',
      termName: 'الأول',
    );

    expect(success, isTrue);
    expect(cubit.state.gradeItems, hasLength(1));
    expect(cubit.state.gradeItems.first.mark, 97);
  });

  test('deleteGrade removes the item from the state', () async {
    final cubit = GradesCubit(FakeGradesRepository());

    await cubit.loadGrades('token');
    final success = await cubit.deleteGrade('1');

    expect(success, isTrue);
    expect(cubit.state.gradeItems, isEmpty);
  });
}
