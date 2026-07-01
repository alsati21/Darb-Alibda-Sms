import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../models/note_item.dart';
import 'notes_state.dart';
import '../../../../shared/theme/app_colors.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesState.initial()) {
    _loadInitialNotes();
  }

  void _loadInitialNotes() {
    final notes = const [
      NoteItem(
        id: '1',
        content: 'يرجى مراجعة واجب الرياضيات المرسل عبر التطبيق قبل يوم الخميس.',
        recipient: 'شعبة كاملة',
        date: '15 مايو 2024',
        status: 'مرسل',
        color: AppColors.success,
        icon: Icons.send,
        readCount: 18,
        totalCount: 20,
        grade: 'الصف الثالث',
        section: 'A',
      ),
      NoteItem(
        id: '2',
        content: 'تم تأجيل اختبار العلوم إلى الأسبوع المقبل بسبب الظروف الجوية.',
        recipient: 'الصف كامل',
        date: '12 مايو 2024',
        status: 'مرسل',
        color: AppColors.success,
        icon: Icons.send,
        readCount: 22,
        totalCount: 24,
        grade: 'الصف الثالث',
        section: 'A',
      ),
      NoteItem(
        id: '3',
        content: 'يرجى إحضار الكتب المدرسية المطلوبة لدرس اليوم.',
        recipient: 'طالب واحد',
        date: '10 مايو 2024',
        status: 'مقروء',
        color: AppColors.info,
        icon: Icons.done_all,
        readCount: 1,
        totalCount: 1,
        grade: 'الصف الأول',
        section: 'B',
      ),
    ];
    emit(state.copyWith(notes: notes));
  }

  void toggleCompose() {
    emit(state.copyWith(showCompose: !state.showCompose));
  }

  void updateGrade(String grade) {
    final sections = state.notes.where((note) => note.grade == grade).map((note) => note.section).toSet().toList();
    final section = sections.isNotEmpty ? sections.first : 'A';
    emit(state.copyWith(selectedGrade: grade, selectedSection: section));
  }

  void updateSection(String section) {
    emit(state.copyWith(selectedSection: section));
  }

  void updateRecipient(String recipient) {
    emit(state.copyWith(recipient: recipient));
  }

  void updateScheduled(bool scheduled) {
    emit(state.copyWith(scheduled: scheduled));
  }

  void updateNoteText(String noteText) {
    emit(state.copyWith(noteText: noteText));
  }

  void sendNote() {
    if (state.noteText.trim().isEmpty) return;

    final newNote = NoteItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: state.noteText.trim(),
      recipient: state.recipient,
      date: 'الآن',
      status: 'مرسل',
      color: AppColors.success,
      icon: Icons.send,
      readCount: 0,
      totalCount: state.recipient == 'طالب واحد' ? 1 : state.recipient == 'شعبة كاملة' ? 20 : 24,
      grade: state.selectedGrade,
      section: state.selectedSection,
    );

    final updatedNotes = [newNote, ...state.notes];
    emit(state.copyWith(notes: updatedNotes, noteText: '', showCompose: false));
  }
}
