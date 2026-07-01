import '../../data/models/class_item.dart';

class ClassesState {
  const ClassesState({
    required this.searchQuery,
    required this.selectedFilter,
    required this.classes,
    required this.isLoading,
    required this.errorMessage,
  });

  final String searchQuery;
  final String selectedFilter;
  final List<ClassItem> classes;
  final bool isLoading;
  final String? errorMessage;

  factory ClassesState.initial() {
    return ClassesState(
      searchQuery: '',
      selectedFilter: 'الكل',
      classes: const [],
      isLoading: false,
      errorMessage: null,
    );
  }

  ClassesState copyWith({
    String? searchQuery,
    String? selectedFilter,
    List<ClassItem>? classes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClassesState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<ClassItem> get filteredClasses {
    return classes.where((classItem) {
      final query = searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          classItem.title.toLowerCase().contains(query) ||
          classItem.subject.toLowerCase().contains(query);
      final matchesFilter = selectedFilter == 'الكل' || classItem.status == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }
}
