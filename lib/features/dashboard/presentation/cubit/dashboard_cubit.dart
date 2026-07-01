import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/teacher_dashboard_summary.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(DashboardState.initial());

  final DashboardRepository _repository;
  String? _token;

  Future<void> loadDashboard(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await _repository.fetchTeacherDashboard(token);
      emit(state.copyWith(isLoading: false, summary: response.data));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
