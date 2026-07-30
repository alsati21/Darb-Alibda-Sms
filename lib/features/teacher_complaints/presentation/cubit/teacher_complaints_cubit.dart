import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/teacher_complaint_item.dart';
import '../../data/repositories/teacher_complaints_repository.dart';
import 'teacher_complaints_state.dart';

class TeacherComplaintsCubit extends Cubit<TeacherComplaintsState> {
  TeacherComplaintsCubit(this._repository) : super(TeacherComplaintsState.initial());

  final TeacherComplaintsRepository _repository;
  String? _token;

  Future<void> loadComplaints(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final items = await _repository.fetchComplaints(token);
      emit(state.copyWith(isLoading: false, complaints: items, clearErrorMessage: true));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _readError(error)));
    }
  }

  Future<void> submitComplaint({required String title, required String body}) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      final item = await _repository.submitComplaint(token: token, title: title, body: body);
      final updated = <TeacherComplaintItem>[item, ...state.complaints.where((c) => c.id != item.id)];
      emit(state.copyWith(isSubmitting: false, complaints: updated, selectedComplaint: item, successMessage: 'تم إرسال الشكوى بنجاح.', clearErrorMessage: true));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _readError(error)));
    }
  }

  Future<void> loadComplaintDetails(int id) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    emit(state.copyWith(isDetailLoading: true, errorMessage: null, clearSelectedComplaint: true));

    try {
      final item = await _repository.fetchComplaint(token, id);
      emit(state.copyWith(isDetailLoading: false, selectedComplaint: item, clearErrorMessage: true));
    } catch (error) {
      emit(state.copyWith(isDetailLoading: false, errorMessage: _readError(error)));
    }
  }

  void clearTransientMessages() {
    emit(state.copyWith(clearErrorMessage: true, clearSuccessMessage: true));
  }

  String _readError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) return message.replaceFirst('Exception: ', '');
    return message;
  }
}
