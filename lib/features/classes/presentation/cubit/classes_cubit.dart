import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/classes_repository.dart';
import '../../data/models/class_item.dart';
import 'classes_state.dart';

class ClassesCubit extends Cubit<ClassesState> {
  ClassesCubit(this._repository) : super(ClassesState.initial());

  final ClassesRepository _repository;

  Future<void> loadClasses({String? token}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final items = await _repository.fetchClasses(token: token);
      emit(state.copyWith(classes: items, isLoading: false, errorMessage: null));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void selectFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }
}
