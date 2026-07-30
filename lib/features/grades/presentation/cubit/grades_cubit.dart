import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/grades_repository.dart';
import '../models/grade_item.dart';
import 'grades_state.dart';
import '../models/subject_component.dart';

class GradesCubit extends Cubit<GradesState> {
  GradesCubit(this._repository) : super(GradesState.initial());

  final GradesRepository _repository;
  String? _token;

  static const int _maxMarkWritten = 50;
  static const int _maxMarkOral = 30;
  static const int _maxMarkPractical = 20;

  int _maxMarkForType(String type) {
    final normalized = type.trim().toLowerCase();
    if (normalized == 'written') return _maxMarkWritten;
    if (normalized == 'oral') return _maxMarkOral;
    if (normalized == 'practical') return _maxMarkPractical;
    return _maxMarkOral;
  }

  /// يفحص isClosed قبل emit — يمنع كراش StateError ("Cannot emit new
  /// states after calling close") اللي بيصير لو المستخدم غادر الصفحة
  /// (فانغلق الـ Cubit) بينما طلب الشبكة لسا شغّال، فيوصل الرد بعدين
  /// ويحاول يعمل emit على Cubit مقفول. هاد الاستثناء كان يطلع من جوا
  /// catch block بدون أي حماية، يعني يهرب كـ unhandled async exception
  /// ويقدر يوقف التطبيق بالكامل (تجمّد ثم كراش).
  void _safeEmit(GradesState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> loadGrades(String? token) async {
    if (token == null || token.isEmpty) {
      _safeEmit(state.copyWith(errorMessage: 'تأكد من تسجيل الدخول أولاً'));
      return;
    }

    _token = token;
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final items = await _repository.fetchMarks(token);
      final selectedGrade = items.isNotEmpty ? items.first.grade : state.selectedGrade;
      final selectedSection = items.isNotEmpty ? items.first.section : state.selectedSection;

      _safeEmit(
        state.copyWith(
          gradeItems: items,
          selectedGrade: selectedGrade,
          selectedSection: selectedSection,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (e, stackTrace) {
      developer.log('loadGrades error', error: e, stackTrace: stackTrace);
      _safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void selectGrade(String grade) {
    final defaultSection = _defaultSectionForGrade(grade);
    _safeEmit(state.copyWith(
      selectedGrade: grade,
      selectedSection: defaultSection,
      errorMessage: null,
    ));
  }

  void selectSection(String section) {
    _safeEmit(state.copyWith(selectedSection: section, errorMessage: null));
  }

  void clearMessages() {
    _safeEmit(state.copyWith(errorMessage: null, successMessage: null));
  }

  Future<bool> updateGradeScore(String id, int newScore, {String? type}) async {
    if (_token == null || _token!.isEmpty) {
      _safeEmit(state.copyWith(errorMessage: 'تأكد من تسجيل الدخول أولاً'));
      return false;
    }

    final resolvedType = (type ?? _findTypeById(id)).trim().toLowerCase();
    final maxMark = _maxMarkForType(resolvedType);
    if (newScore < 0 || newScore > maxMark) {
      _safeEmit(state.copyWith(errorMessage: 'العلامة يجب أن تكون بين 0 و $maxMark لنوع $resolvedType'));
      return false;
    }

    _safeEmit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final updated = await _repository.updateMark(
        token: _token!,
        markId: int.tryParse(id) ?? 0,
        mark: newScore,
        type: resolvedType,
      );

      final updatedItems = state.gradeItems.map((item) {
        if (item.id != updated.id) return item;
        return updated.copyWith(
          grade: item.grade,
          section: item.section,
          type: item.type,
        );
      }).toList();

      _safeEmit(state.copyWith(
        gradeItems: updatedItems,
        isLoading: false,
        successMessage: 'تم تعديل العلامة بنجاح',
      ));
      return true;
    } catch (e, stackTrace) {
      developer.log('updateGradeScore error', error: e, stackTrace: stackTrace);
      _safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> deleteGrade(String id) async {
    if (_token == null || _token!.isEmpty) {
      _safeEmit(state.copyWith(errorMessage: 'تأكد من تسجيل الدخول أولاً'));
      return false;
    }

    // ✅ لا isLoading هنا — الحذف سريع ويمنع وميض الـ UI
    _safeEmit(state.copyWith(errorMessage: null, successMessage: null));

    try {
      final markId = int.tryParse(id) ?? 0;
      if (markId <= 0) {
        _safeEmit(state.copyWith(errorMessage: 'معرف العلامة غير صالح'));
        return false;
      }

      await _repository.deleteMark(token: _token!, markId: markId);

      final remainingItems = state.gradeItems.where((item) => item.id != id).toList();
      _safeEmit(state.copyWith(
        gradeItems: remainingItems,
        successMessage: 'تم حذف العلامة بنجاح',
      ));
      return true;
    } catch (e, stackTrace) {
      developer.log('deleteGrade error', error: e, stackTrace: stackTrace);
      _safeEmit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> addMark({
    required int studentId,
    required int sectionId,
    required int subjectId,
    required int subjectComponentId,
    required int termId,
    required int mark,
    required String type,
  }) async {
    if (_token == null || _token!.isEmpty) {
      _safeEmit(state.copyWith(errorMessage: 'تأكد من تسجيل الدخول أولاً'));
      return false;
    }

    final normalizedType = type.trim().toLowerCase();
    final maxMark = _maxMarkForType(normalizedType);
    if (mark < 0 || mark > maxMark) {
      _safeEmit(state.copyWith(errorMessage: 'العلامة يجب أن تكون بين 0 و $maxMark لنوع $normalizedType'));
      return false;
    }

    if (studentId <= 0 || subjectId <= 0 || subjectComponentId <= 0) {
      _safeEmit(state.copyWith(errorMessage: 'بيانات الطالب أو المادة غير مكتملة (معرف المكون غير صحيح)'));
      return false;
    }

    _safeEmit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final resolvedTermId = termId > 0 ? termId : 1;
      final created = await _repository.addMark(
        token: _token!,
        studentId: studentId,
        sectionId: sectionId,
        subjectId: subjectId,
        subjectComponentId: subjectComponentId,
        termId: resolvedTermId,
        mark: mark,
        type: normalizedType,
      );

      final updatedItems = [...state.gradeItems, created];
      _safeEmit(state.copyWith(
        gradeItems: updatedItems,
        selectedGrade: created.grade.isNotEmpty ? created.grade : state.selectedGrade,
        selectedSection: created.section.isNotEmpty ? created.section : state.selectedSection,
        isLoading: false,
        successMessage: 'تم إضافة العلامة بنجاح',
      ));
      return true;
    } catch (e, stackTrace) {
      developer.log('addMark error', error: e, stackTrace: stackTrace);
      _safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<List<SubjectComponent>> fetchSubjectComponents(int subjectId) async {
    if (_token == null || _token!.isEmpty) return const [];

    // نجمع من المصدرين معًا بدل ما نوقف عند أول مصدر يرجّع نتيجة غير
    // فاضية. لو الـ backend رجّع رد ناقص (مثلاً مكوّن واحد بس من
    // ثلاثة)، وقفنا هون قبل، فضلّت المكوّنات الناقصة غير معروفة حتى
    // لو كانت موجودة أصلاً بعلامات الطالب المحمّلة عندنا.
    final merged = <int, SubjectComponent>{};

    try {
      final components = await _repository.fetchSubjectComponents(_token!, subjectId);
      for (final component in components) {
        merged[component.id] = component;
      }
    } catch (e) {
      developer.log('Failed to fetch components from backend', error: e);
    }

    // نكمّل أي مكوّن ناقص من العلامات الموجودة فعليًا لنفس المادة —
    // حتى لو الـ backend رجّع نتيجة (جزئية)، منكمّلها مش نتجاهلها.
    for (final item in state.gradeItems) {
      if (item.subjectId != subjectId) continue;
      if (item.subjectComponentId <= 0) continue;
      if (merged.containsKey(item.subjectComponentId)) continue;

      final type = _normalizeType(item.type);
      if (type.isNotEmpty) {
        merged[item.subjectComponentId] = SubjectComponent(
          id: item.subjectComponentId,
          name: type,
        );
      }
    }

    return merged.values.toList();
  }

  Future<bool> addOrUpdateMark({
    required int studentId,
    required int sectionId,
    required int subjectId,
    required int subjectComponentId,
    required int termId,
    required int mark,
    required String type,
    String? studentName,
    String? subjectName,
    String? termName,
  }) async {
    final normalizedStudentName = studentName?.trim().toLowerCase();
    final normalizedSubjectName = subjectName?.trim().toLowerCase();
    final normalizedTermName = termName?.trim().toLowerCase();

    GradeItem? existingItem;
    for (final item in state.gradeItems) {
      final sameStudent = item.studentId == studentId ||
          (normalizedStudentName != null &&
              item.studentName.trim().toLowerCase() == normalizedStudentName);
      final sameSubject = item.subjectId == subjectId ||
          (normalizedSubjectName != null &&
              item.subjectName.trim().toLowerCase() == normalizedSubjectName);
      final sameSection = item.sectionId == sectionId;
      final sameComponent = item.subjectComponentId == subjectComponentId;
      final sameTerm = item.termId == termId ||
          (normalizedTermName != null && item.termName.trim().toLowerCase() == normalizedTermName);
      final sameType = item.type == type;

      if (sameStudent && sameSubject && sameSection && sameComponent && sameTerm && sameType) {
        existingItem = item;
        break;
      }
    }

    if (existingItem != null) {
      return updateGradeScore(existingItem.id, mark);
    }

    return addMark(
      studentId: studentId,
      sectionId: sectionId,
      subjectId: subjectId,
      subjectComponentId: subjectComponentId,
      termId: termId,
      mark: mark,
      type: type,
    );
  }

  String _findTypeById(String id) {
    for (final item in state.gradeItems) {
      if (item.id == id) {
        return item.type;
      }
    }
    return 'written';
  }

  String _normalizeType(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.contains('written') ||
        normalized.contains('كت') ||
        normalized.contains('تحر') ||
        normalized.contains('كتابي') ||
        normalized.contains('كتابة')) {
      return 'written';
    }

    if (normalized.contains('oral') ||
        normalized.contains('شف') ||
        normalized.contains('شهي') ||
        normalized.contains('مشاف')) {
      return 'oral';
    }

    if (normalized.contains('practical') ||
        normalized.contains('pracitical') ||
        normalized.contains('practcal') ||
        normalized.contains('عم') ||
        normalized.contains('تطبيق') ||
        normalized.contains('مختبر')) {
      return 'practical';
    }

    return normalized;
  }

  String _defaultSectionForGrade(String grade) {
    final sections = state.gradeItems
        .where((item) => item.grade == grade)
        .map((item) => item.section)
        .toSet()
        .toList();
    return sections.isNotEmpty ? sections.first : 'A';
  }
}