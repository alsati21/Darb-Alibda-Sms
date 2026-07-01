import '../../data/models/absence_justification_request.dart';

class AbsenceRequestsState {
  const AbsenceRequestsState({
    required this.isLoading,
    required this.errorMessage,
    required this.requests,
    required this.selectedFilter,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<AbsenceJustificationRequest> requests;
  final String selectedFilter;

  factory AbsenceRequestsState.initial() {
    return const AbsenceRequestsState(
      isLoading: false,
      errorMessage: null,
      requests: <AbsenceJustificationRequest>[],
      selectedFilter: 'الكل',
    );
  }

  AbsenceRequestsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<AbsenceJustificationRequest>? requests,
    String? selectedFilter,
  }) {
    return AbsenceRequestsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      requests: requests ?? this.requests,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<AbsenceJustificationRequest> get filteredRequests {
    if (selectedFilter == 'الكل') return requests;
    return requests.where((request) {
      final label = request.status == 'approved'
          ? 'مقبول'
          : request.status == 'rejected'
              ? 'مرفوض'
              : 'قيد الانتظار';
      return label == selectedFilter;
    }).toList();
  }

  int get pendingCount => requests.where((request) => request.status == 'pending').length;
  int get approvedCount => requests.where((request) => request.status == 'approved').length;
  int get rejectedCount => requests.where((request) => request.status == 'rejected').length;
}
