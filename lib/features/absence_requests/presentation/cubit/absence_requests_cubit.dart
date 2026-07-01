import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/absence_justification_request.dart';
import '../../data/repositories/absence_requests_repository.dart';
import 'absence_requests_state.dart';

class AbsenceRequestsCubit extends Cubit<AbsenceRequestsState> {
  AbsenceRequestsCubit(this._repository) : super(AbsenceRequestsState.initial());

  final AbsenceRequestsRepository _repository;
  String? _token;

  Future<void> loadRequests(String? token) async {
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    _token = token;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final requests = await _repository.fetchRequests(token);
      emit(state.copyWith(isLoading: false, requests: requests));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString().replaceFirst('Exception: ', '')));
    }
  }

  void selectFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  Future<void> updateRequestStatus(int requestId, String status) async {
    final token = _token;
    if (token == null || token.isEmpty) return;

    try {
      await _repository.updateRequest(token: token, requestId: requestId, status: status);
      final updatedRequests = state.requests.map((request) {
        if (request.id != requestId) return request;
        return request.copyWith(status: status);
      }).toList();
      emit(state.copyWith(requests: updatedRequests));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> deleteRequest(int requestId) async {
    final token = _token;
    if (token == null || token.isEmpty) return;

    try {
      await _repository.deleteRequest(token: token, requestId: requestId);
      final updatedRequests = state.requests.where((request) => request.id != requestId).toList();
      emit(state.copyWith(requests: updatedRequests));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
