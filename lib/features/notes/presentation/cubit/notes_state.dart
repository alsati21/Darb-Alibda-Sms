import '../../data/models/parent_note.dart';
import '../../data/models/teacher_section.dart';

class NotesState {
  const NotesState({
    required this.isLoading,
    required this.isSubmitting,
    required this.errorMessage,
    required this.successMessage,
    required this.notes,
    required this.sections,
    required this.selectedSectionIds,
    required this.selectedStudentIds,
    required this.selectedStudentNames,
    required this.selectedTitle,
    required this.selectedContent,
    required this.composeOpen,
    required this.editingNote,
    required this.attachmentPaths,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final List<ParentNote> notes;
  final List<TeacherSection> sections;
  final List<int> selectedSectionIds;
  final List<int> selectedStudentIds;
  final List<String> selectedStudentNames;
  final String selectedTitle;
  final String selectedContent;
  final bool composeOpen;
  final ParentNote? editingNote;
  final List<String> attachmentPaths;

  factory NotesState.initial() {
    return const NotesState(
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
      successMessage: null,
      notes: <ParentNote>[],
      sections: <TeacherSection>[],
      selectedSectionIds: <int>[],
      selectedStudentIds: <int>[],
      selectedStudentNames: <String>[],
      selectedTitle: '',
      selectedContent: '',
      composeOpen: false,
      editingNote: null,
      attachmentPaths: <String>[],
    );
  }

  NotesState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    List<ParentNote>? notes,
    List<TeacherSection>? sections,
    List<int>? selectedSectionIds,
    List<int>? selectedStudentIds,
    List<String>? selectedStudentNames,
    String? selectedTitle,
    String? selectedContent,
    bool? composeOpen,
    ParentNote? editingNote,
    List<String>? attachmentPaths,
    bool clearEditingNote = false,
  }) {
    return NotesState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      notes: notes ?? this.notes,
      sections: sections ?? this.sections,
      selectedSectionIds: selectedSectionIds ?? this.selectedSectionIds,
      selectedStudentIds: selectedStudentIds ?? this.selectedStudentIds,
      selectedStudentNames: selectedStudentNames ?? this.selectedStudentNames,
      selectedTitle: selectedTitle ?? this.selectedTitle,
      selectedContent: selectedContent ?? this.selectedContent,
      composeOpen: composeOpen ?? this.composeOpen,
      editingNote: clearEditingNote ? null : (editingNote ?? this.editingNote),
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
    );
  }

  List<ParentNote> get filteredNotes {
    return notes;
  }

  int get unreadCount => notes.where((note) => !note.isRead).length;
  int get attachmentsCount => notes.where((note) => note.hasAttachments).length;
}
