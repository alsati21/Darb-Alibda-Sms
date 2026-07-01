import '../models/note_item.dart';

class NotesState {
  const NotesState({
    required this.selectedGrade,
    required this.selectedSection,
    required this.showCompose,
    required this.recipient,
    required this.scheduled,
    required this.noteText,
    required this.notes,
  });

  final String selectedGrade;
  final String selectedSection;
  final bool showCompose;
  final String recipient;
  final bool scheduled;
  final String noteText;
  final List<NoteItem> notes;

  factory NotesState.initial() {
    return const NotesState(
      selectedGrade: 'الصف الثالث',
      selectedSection: 'A',
      showCompose: false,
      recipient: 'طالب واحد',
      scheduled: false,
      noteText: '',
      notes: <NoteItem>[],
    );
  }

  NotesState copyWith({
    String? selectedGrade,
    String? selectedSection,
    bool? showCompose,
    String? recipient,
    bool? scheduled,
    String? noteText,
    List<NoteItem>? notes,
  }) {
    return NotesState(
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedSection: selectedSection ?? this.selectedSection,
      showCompose: showCompose ?? this.showCompose,
      recipient: recipient ?? this.recipient,
      scheduled: scheduled ?? this.scheduled,
      noteText: noteText ?? this.noteText,
      notes: notes ?? this.notes,
    );
  }

  List<NoteItem> get visibleNotes {
    return notes.where((note) => note.grade == selectedGrade && note.section == selectedSection).toList();
  }
}
