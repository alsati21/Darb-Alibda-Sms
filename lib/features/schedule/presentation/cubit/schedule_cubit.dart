import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/teacher_schedule.dart';
import '../../data/repositories/schedule_repository.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._repository) : super(ScheduleState.initial());

  final ScheduleRepository _repository;
  String? _token;

  Future<void> loadSchedule(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final todayItems = await _repository.fetchTodaySchedule(token);
      final weekItems = await _repository.fetchWeekSchedule(token);
      emit(state.copyWith(isLoading: false, todayItems: todayItems, weekItems: weekItems));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
