import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/teacher_feedback_item.dart';
import '../../data/repositories/teacher_feedback_repository.dart';
import 'teacher_feedback_state.dart';

class TeacherFeedbackCubit extends Cubit<TeacherFeedbackState> {
  TeacherFeedbackCubit(this._repository) : super(TeacherFeedbackState.initial());

  final TeacherFeedbackRepository _repository;
  String? _token;

  Future<void> loadSuggestions(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final suggestions = await _repository.fetchSuggestions(token);
      emit(state.copyWith(isLoading: false, suggestions: suggestions, clearErrorMessage: true));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _readErrorMessage(error)));
    }
  }

  Future<void> submitSuggestion({required String title, required String body}) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      final result = await _repository.submitSuggestion(token: token, title: title, body: body);
      final updatedSuggestions = <TeacherFeedbackItem>[result.item, ...state.suggestions.where((item) => item.id != result.item.id)];
      emit(state.copyWith(
        isSubmitting: false,
        suggestions: updatedSuggestions,
        selectedSuggestion: result.item,
        successMessage: result.message,
        clearErrorMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _readErrorMessage(error)));
    }
  }

  Future<void> loadSuggestionDetails(int suggestionId) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    emit(state.copyWith(isDetailLoading: true, errorMessage: null, clearSelectedSuggestion: true));

    try {
      final suggestion = await _repository.fetchSuggestion(token, suggestionId);
      emit(state.copyWith(isDetailLoading: false, selectedSuggestion: suggestion, clearErrorMessage: true));
    } catch (error) {
      emit(state.copyWith(isDetailLoading: false, errorMessage: _readErrorMessage(error)));
    }
  }

  void clearTransientMessages() {
    emit(state.copyWith(clearErrorMessage: true, clearSuccessMessage: true));
  }

  String _readErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
