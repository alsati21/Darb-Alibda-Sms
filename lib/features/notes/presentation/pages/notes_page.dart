import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/parent_note.dart';
import '../../data/models/parent_note_attachment.dart';
import '../../data/models/teacher_section.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _previousErrorMessage;
  String? _previousSuccessMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesCubit>().loadNotes();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _syncDraft(NotesState state) {
    if (state.editingNote != null) {
      if (_titleController.text != state.selectedTitle) {
        _titleController.text = state.selectedTitle;
      }
      if (_contentController.text != state.selectedContent) {
        _contentController.text = state.selectedContent;
      }
      return;
    }

    if (!state.composeOpen) {
      if (_titleController.text.isNotEmpty) _titleController.clear();
      if (_contentController.text.isNotEmpty) _contentController.clear();
    }
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      type: FileType.any,
    );
    if (result == null) return;

    final cubit = context.read<NotesCubit>();
    for (final file in result.files) {
      final path = file.path;
      if (path != null && path.isNotEmpty) {
        cubit.addAttachmentPath(path);
      }
    }
  }

  Future<void> _confirmDelete(ParentNote note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الملاحظة'),
          content: Text('هل تريد حذف الملاحظة "${note.title}" نهائيًا؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      context.read<NotesCubit>().deleteNote(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظات الأهل',
      currentIndex: 0,
      body: BlocConsumer<NotesCubit, NotesState>(
        listener: (context, state) {
          _syncDraft(state);

          if (state.errorMessage != null &&
              state.errorMessage != _previousErrorMessage) {
            _previousErrorMessage = state.errorMessage;
            showAppFeedback(
              context,
              message: state.errorMessage!,
              isError: true,
            );
            context.read<NotesCubit>().resetMessages();
          }

          if (state.successMessage != null &&
              state.successMessage != _previousSuccessMessage) {
            _previousSuccessMessage = state.successMessage;
            showAppFeedback(
              context,
              message: state.successMessage!,
              isError: false,
            );
            context.read<NotesCubit>().resetMessages();
          }
        },
        builder: (context, state) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    _buildHeader(context, state),

                    Expanded(
                      child: state.composeOpen
                          ? _buildComposePanel(context, state)
                          : _buildBody(context, state),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotesState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'ملاحظات الأهل',
            subtitle: 'إرسال ومتابعة التواصل مع أولياء الأمور',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'غير مقروءة',
                  value: state.unreadCount.toString(),
                  icon: Icons.mark_chat_unread,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'المرفقات',
                  value: state.attachmentsCount.toString(),
                  icon: Icons.attach_file,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'إجمالي',
                  value: state.notes.length.toString(),
                  icon: Icons.note_alt,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: state.composeOpen ? 'إغلاق الإنشاء' : 'إنشاء ملاحظة جديدة',
              icon: state.composeOpen ? Icons.close : Icons.add,
              onPressed: () {
                if (state.composeOpen) {
                  context.read<NotesCubit>().toggleCompose();
                  return;
                }
                context.read<NotesCubit>().openCreateCompose();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.onPrimary),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposePanel(BuildContext context, NotesState state) {
    final selectedSections = state.sections
        .where(
          (section) => state.selectedSectionIds.contains(section.sectionId),
        )
        .toList();
    final selectedStudents = _selectedStudents(state, selectedSections);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      state.editingNote == null
                          ? 'إنشاء ملاحظة جديدة'
                          : 'تعديل الملاحظة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (state.editingNote != null)
                    TextButton.icon(
                      onPressed: () => context.read<NotesCubit>().resetDraft(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('تفريغ'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _titleController,
                onChanged: (value) =>
                    context.read<NotesCubit>().updateTitle(value),
                decoration: const InputDecoration(
                  labelText: 'عنوان الملاحظة',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _contentController,
                onChanged: (value) =>
                    context.read<NotesCubit>().updateContent(value),
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'محتوى الملاحظة',
                  prefixIcon: Icon(Icons.subject),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'اختر الشعب',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.sections.isEmpty)
                const Text('لا توجد شعب متاحة حاليًا')
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: state.sections.map((section) {
                    final selected = state.selectedSectionIds.contains(
                      section.sectionId,
                    );
                    return FilterChip(
                      label: Text(section.displayLabel),
                      selected: selected,
                      onSelected: (_) =>
                          context.read<NotesCubit>().toggleSection(section),
                    );
                  }).toList(),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'اختر الطلاب',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (selectedStudents.isEmpty)
                const Text('اختر شعبة أولًا لعرض الطلاب')
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                    //  color: AppColors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.sm,
                    ),
                    itemCount: selectedStudents.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = selectedStudents[index];
                      final selected = state.selectedStudentIds.contains(
                        student.id,
                      );

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        value: selected,
                        onChanged: (_) => context
                            .read<NotesCubit>()
                            .toggleStudent(student.id, student.fullName),
                        title: Text(
                          student.displayLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        secondary: const Icon(Icons.person_outline),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickAttachments,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('إرفاق ملفات'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: state.isSubmitting
                          ? 'جاري الإرسال...'
                          : (state.editingNote == null
                                ? 'إرسال الملاحظة'
                                : 'حفظ التعديل'),
                      icon: state.editingNote == null ? Icons.send : Icons.save,
                      onPressed: state.isSubmitting
                          ? () {}
                          : () =>
                                context.read<NotesCubit>().submitCurrentNote(),
                    ),
                  ),
                ],
              ),
              if (state.attachmentPaths.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'الملفات المرفقة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: state.attachmentPaths.map((path) {
                    final name = path.split(RegExp(r'[\\/]')).last;
                    return InputChip(
                      label: Text(name, overflow: TextOverflow.ellipsis),
                      onDeleted: () =>
                          context.read<NotesCubit>().removeAttachmentPath(path),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<TeacherSectionStudentView> _selectedStudents(
    NotesState state,
    List<TeacherSection> selectedSections,
  ) {
    final seen = <int>{};
    final students = <TeacherSectionStudentView>[];
    for (final section
        in selectedSections.isEmpty ? state.sections : selectedSections) {
      for (final student in section.students) {
        if (seen.add(student.id)) {
          students.add(
            TeacherSectionStudentView(
              id: student.id,
              fullName: student.fullName,
              parentName: student.parentName,
            ),
          );
        }
      }
    }
    return students;
  }

  Widget _buildBody(BuildContext context, NotesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.notes.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.mark_chat_unread_outlined,
        title: 'لا توجد ملاحظات بعد',
        subtitle: 'أنشئ أول ملاحظة لإرسالها إلى أولياء الأمور',
      );
    }

    final notes = state.filteredNotes.isEmpty
        ? state.notes
        : state.filteredNotes;

    return RefreshIndicator(
      onRefresh: () => context.read<NotesCubit>().loadNotes(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final note = notes[index];
          return _ParentNoteCard(
            note: note,
            onEdit: () => context.read<NotesCubit>().startEdit(note),
            onDelete: () => _confirmDelete(note),
          );
        },
      ),
    );
  }
}

class TeacherSectionStudentView {
  const TeacherSectionStudentView({
    required this.id,
    required this.fullName,
    required this.parentName,
  });

  final int id;
  final String fullName;
  final String parentName;

  String get displayLabel =>
      parentName.isNotEmpty ? '$fullName • $parentName' : fullName;
}

class _ParentNoteCard extends StatelessWidget {
  const _ParentNoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final ParentNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Uri? _attachmentUri(ParentNoteAttachment attachment) {
    final raw = attachment.url.trim();
    if (raw.isNotEmpty) {
      final uri = Uri.tryParse(raw);
      if (uri != null) return uri;
    }

    final path = attachment.path.trim();
    if (path.isEmpty) return null;

    final normalized = path.startsWith('/') ? path : '/$path';
    final url = '${ApiClient().baseUrl}/storage$normalized';
    return Uri.tryParse(url);
  }

  Future<void> _openAttachment(
    BuildContext context,
    ParentNoteAttachment attachment,
  ) async {
    final uri = _attachmentUri(attachment);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رابط صالح لهذا المرفق')),
      );
      return;
    }

    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح المرفق: ${attachment.fileName}')),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: note.isRead
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  child: Icon(
                    note.isRead ? Icons.done_all : Icons.mark_chat_unread,
                    color: note.isRead ? AppColors.success : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إلى: ${note.recipientLabel}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'بواسطة: ${note.teacherName.isNotEmpty ? note.teacherName : 'المعلم'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(note.content, style: Theme.of(context).textTheme.bodyMedium),
            if (note.hasAttachments) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: note.attachments.map((attachment) {
                  final name = attachment.fileName.isNotEmpty
                      ? attachment.fileName
                      : 'مرفق';
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _openAttachment(context, attachment),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: StatusBadge(
                        label: name,
                        color: AppColors.secondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                StatusBadge(
                  label: note.isRead ? 'مقروءة' : 'غير مقروءة',
                  color: note.isRead ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  note.formattedCreatedAt,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
