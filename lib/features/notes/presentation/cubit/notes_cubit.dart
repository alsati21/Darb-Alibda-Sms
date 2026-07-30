import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/parent_note.dart';
import '../../data/models/teacher_section.dart';
import '../../data/repositories/parent_notes_repository.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository, this._authCubit) : super(NotesState.initial());

  final ParentNotesRepository _repository;
  final AuthCubit _authCubit;

  Future<void> loadNotes() async {
    final token = _authCubit.sessionToken;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final notes = await _repository.fetchNotes(token);
      final sections = await _repository.fetchSectionsWithStudents(token);
      emit(state.copyWith(isLoading: false, notes: notes, sections: sections));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _readMessage(error)));
    }
  }

  void toggleCompose() {
    final nextOpen = !state.composeOpen;
    emit(state.copyWith(composeOpen: nextOpen, clearEditingNote: nextOpen ? false : true));
    if (!nextOpen) {
      resetDraft();
    }
  }

  void openCreateCompose() {
    emit(state.copyWith(
      composeOpen: true,
      clearEditingNote: true,
      selectedTitle: '',
      selectedContent: '',
      selectedSectionIds: const [],
      selectedStudentIds: const [],
      selectedStudentNames: const [],
      attachmentPaths: const [],
    ));
  }

  void startEdit(ParentNote note) {
    emit(state.copyWith(
      composeOpen: true,
      editingNote: note,
      selectedTitle: note.title,
      selectedContent: note.content,
      selectedStudentIds: [note.studentId],
      selectedSectionIds: [note.studentId],
      selectedStudentNames: [note.recipientLabel],
      attachmentPaths: const [],
    ));
  }

  void updateTitle(String value) => emit(state.copyWith(selectedTitle: value));

  void updateContent(String value) => emit(state.copyWith(selectedContent: value));

  void toggleSection(TeacherSection section) {
    final updated = [...state.selectedSectionIds];
    if (updated.contains(section.sectionId)) {
      updated.remove(section.sectionId);
    } else {
      updated.add(section.sectionId);
    }
    emit(state.copyWith(selectedSectionIds: updated));
  }

  void toggleStudent(int studentId, String studentName) {
    final updatedIds = [...state.selectedStudentIds];
    final updatedNames = [...state.selectedStudentNames];
    if (updatedIds.contains(studentId)) {
      final index = updatedIds.indexOf(studentId);
      updatedIds.removeAt(index);
      updatedNames.removeAt(index);
    } else {
      updatedIds.add(studentId);
      updatedNames.add(studentName);
    }
    emit(state.copyWith(selectedStudentIds: updatedIds, selectedStudentNames: updatedNames));
  }

  void addAttachmentPath(String path) {
    emit(state.copyWith(attachmentPaths: [...state.attachmentPaths, path]));
  }

  void removeAttachmentPath(String path) {
    final paths = [...state.attachmentPaths]..remove(path);
    emit(state.copyWith(attachmentPaths: paths));
  }

  Future<void> submitCurrentNote() async {
    final token = _authCubit.sessionToken;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    final title = state.selectedTitle.trim();
    final content = state.selectedContent.trim();
    if (title.isEmpty || content.isEmpty) {
      emit(state.copyWith(errorMessage: 'العنوان والمحتوى مطلوبان'));
      return;
    }

    if (state.selectedSectionIds.isEmpty && state.selectedStudentIds.isEmpty) {
      emit(state.copyWith(errorMessage: 'اختر شعبة أو طالبًا واحدًا على الأقل'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      if (state.editingNote != null) {
        final updated = await _repository.updateNote(
          token: token,
          id: state.editingNote!.id,
          title: title,
          content: content,
        );
        final updatedNotes = state.notes.map((note) => note.id == updated.id ? updated : note).toList();
        emit(state.copyWith(
          isSubmitting: false,
          notes: updatedNotes,
          selectedTitle: '',
          selectedContent: '',
          composeOpen: false,
          successMessage: 'تم تعديل الملاحظة بنجاح',
          clearEditingNote: true,
          attachmentPaths: const [],
          selectedSectionIds: const [],
          selectedStudentIds: const [],
          selectedStudentNames: const [],
        ));
        return;
      }

      final created = await _repository.createNote(
        token: token,
        title: title,
        content: content,
        studentIds: state.selectedStudentIds,
        sectionIds: state.selectedSectionIds,
        attachmentPaths: state.attachmentPaths,
      );

      emit(state.copyWith(
        isSubmitting: false,
        notes: [created, ...state.notes],
        selectedTitle: '',
        selectedContent: '',
        composeOpen: false,
        successMessage: 'تم إرسال الملاحظة إلى أولياء الأمور بنجاح',
        clearEditingNote: true,
        attachmentPaths: const [],
        selectedSectionIds: const [],
        selectedStudentIds: const [],
        selectedStudentNames: const [],
      ));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _readMessage(error)));
    }
  }

  Future<void> deleteNote(int noteId) async {
    final token = _authCubit.sessionToken;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(errorMessage: 'لم يتم العثور على جلسة نشطة'));
      return;
    }

    try {
      await _repository.deleteNote(token: token, id: noteId);
      emit(state.copyWith(notes: state.notes.where((note) => note.id != noteId).toList(), successMessage: 'تم حذف الملاحظة بنجاح'));
    } catch (error) {
      emit(state.copyWith(errorMessage: _readMessage(error)));
    }
  }

  void resetMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  void resetDraft() {
    emit(state.copyWith(
      selectedTitle: '',
      selectedContent: '',
      selectedSectionIds: const [],
      selectedStudentIds: const [],
      selectedStudentNames: const [],
      attachmentPaths: const [],
      clearEditingNote: true,
    ));
  }

  String _readMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
