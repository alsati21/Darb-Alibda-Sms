import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/grades_cubit.dart';
import '../cubit/grades_state.dart';
import '../models/grade_item.dart';
import '../models/subject_component.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoaded = false;
  String? _previousErrorMessage;
  String? _previousSuccessMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoaded) {
      return;
    }

    _isLoaded = true;
    final token = context.read<AuthCubit>().sessionToken;
    if (token != null && token.isNotEmpty) {
      context.read<GradesCubit>().loadGrades(token);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openMarkEditor({
    GradeItem? existingMark,
    required GradesState state,
    String? forcedType,
    int? defaultStudentId,
    int? defaultSubjectId,
  }) async {
    final cubit = context.read<GradesCubit>();

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _MarkEditorBottomSheet(
        availableItems: state.visibleGrades,
        cubit: cubit,
        existingMark: existingMark,
        forcedType: forcedType,
        defaultStudentId: defaultStudentId,
        defaultSubjectId: defaultSubjectId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GradesCubit, GradesState>(
      listener: (context, state) {
        if (state.successMessage != null &&
            state.successMessage!.isNotEmpty &&
            state.successMessage != _previousSuccessMessage) {
          _previousSuccessMessage = state.successMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              backgroundColor: AppColors.primary,
            ),
          );
          context.read<GradesCubit>().clearMessages();
        }

        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty &&
            state.errorMessage != _previousErrorMessage) {
          _previousErrorMessage = state.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          context.read<GradesCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final students = _StudentMarksAggregate.build(state.visibleGrades);
        final query = _searchController.text.trim().toLowerCase();
        final filteredStudents = query.isEmpty
            ? students
            : students
            .where(
              (item) => item.studentName.toLowerCase().contains(query),
        )
            .toList();

        final marks = state.visibleGrades
            .where((e) => e.subjectId > 0)
            .map((e) => e.mark)
            .toList();
        final average = marks.isEmpty
            ? 0.0
            : marks.reduce((a, b) => a + b) / marks.length;

        return AppScaffold(
          title: 'قسم العلامات',
          currentIndex: 1,
          actions: const [],
          body: Container(
            decoration: const BoxDecoration(color: Color(0xFFF7F7F5)),
            child: RefreshIndicator(
              onRefresh: () async {
                final token = context.read<AuthCubit>().sessionToken;
                if (token != null && token.isNotEmpty) {
                  await context.read<GradesCubit>().loadGrades(token);
                }
              },
              color: AppColors.primary,
              backgroundColor: Colors.white,
              strokeWidth: 3,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _SummaryHeader(
                      average: average,
                      marksCount: marks.length,
                      studentsCount: students.length,
                      subjectsCount: _subjectsCount(students),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _GradeSectionFilters(
                      state: state,
                      onGradeChanged: (value) =>
                          context.read<GradesCubit>().selectGrade(value),
                      onSectionChanged: (value) =>
                          context.read<GradesCubit>().selectSection(value),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: _SearchBar(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  if (state.isLoading && students.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: _LoadingIndicator()),
                    )
                  else if (filteredStudents.isEmpty)
                    const SliverFillRemaining(
                      child: _EmptyGradesView(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.lg,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final student = filteredStudents[index];
                            return _StudentMarksCard(
                              key: ValueKey(student.studentId),
                              student: student,
                              onEditMark: (studentId, subjectId, mark, type) {
                                _openMarkEditor(
                                  state: state,
                                  defaultStudentId: studentId,
                                  defaultSubjectId: subjectId,
                                  existingMark: mark,
                                  forcedType: type,
                                );
                              },
                              onDeleteMark: (mark) async {
                                // deleteGrade() already removes this item
                                // from state.gradeItems locally on
                                // success — no need to re-fetch the whole
                                // list from the server right after.
                                await context.read<GradesCubit>().deleteGrade(mark.id);
                              },
                            );
                          },
                          childCount: filteredStudents.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _subjectsCount(List<_StudentMarksAggregate> students) {
    final ids = <int>{};
    for (final student in students) {
      for (final subject in student.subjects) {
        ids.add(subject.subjectId);
      }
    }
    return ids.length;
  }
}

/// Simple, cheap add button (no per-widget AnimationController).
class _AddMarkButton extends StatelessWidget {
  const _AddMarkButton({required this.isEnabled, required this.onPressed});

  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: isEnabled ? Colors.white : Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'إضافة',
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'جاري تحميل البيانات...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.average,
    required this.marksCount,
    required this.studentsCount,
    required this.subjectsCount,
  });

  final double average;
  final int marksCount;
  final int studentsCount;
  final int subjectsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'لوحة العلامات الدراسية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Row(
          //   children: [
          //     _StatTile(label: 'المعدل', value: average.toStringAsFixed(1)),
          //     _StatTile(label: 'العلامات', value: '$marksCount'),
          //     _StatTile(label: 'الطلاب', value: '$studentsCount'),
          //     _StatTile(label: 'المواد', value: '$subjectsCount'),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeSectionFilters extends StatelessWidget {
  const _GradeSectionFilters({
    required this.state,
    required this.onGradeChanged,
    required this.onSectionChanged,
  });

  final GradesState state;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final gradeSectionMap = <String, List<String>>{};
    for (final item in state.gradeItems) {
      final sections = gradeSectionMap.putIfAbsent(item.grade, () => <String>[]);
      if (!sections.contains(item.section)) {
        sections.add(item.section);
      }
    }

    final grades = gradeSectionMap.keys.toList();
    final selectedGrade = grades.contains(state.selectedGrade)
        ? state.selectedGrade
        : (grades.isNotEmpty ? grades.first : '');
    final sections = gradeSectionMap[selectedGrade] ?? const <String>[];
    final selectedSection = sections.contains(state.selectedSection)
        ? state.selectedSection
        : (sections.isNotEmpty ? sections.first : '');

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterField(
              label: 'الصف',
              value: selectedGrade.isEmpty ? null : selectedGrade,
              items: grades,
              icon: Icons.school_rounded,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  onGradeChanged(value);
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _FilterField(
              label: 'الشعبة',
              value: selectedSection.isEmpty ? null : selectedSection,
              items: sections,
              icon: Icons.groups_rounded,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  onSectionChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary.withOpacity(0.6)),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(14),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'ابحث باسم الطالب',
          hintStyle: TextStyle(
            color: AppColors.onSurface.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
            onPressed: () {
              controller.clear();
              onChanged('');
            },
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.onSurface.withOpacity(0.5),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _StudentMarksCard extends StatelessWidget {
  const _StudentMarksCard({
    super.key,
    required this.student,
    required this.onEditMark,
    required this.onDeleteMark,
  });

  final _StudentMarksAggregate student;
  final void Function(int studentId, int subjectId, GradeItem? existingMark, String type) onEditMark;
  final Future<void> Function(GradeItem mark) onDeleteMark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.primary.withOpacity(0.6),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                student.studentName.isNotEmpty
                    ? student.studentName.characters.first
                    : '—',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          title: Text(
            student.studentName,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _TinyTag(text: student.grade),
                _TinyTag(text: student.section),
                _TinyTag(text: '${student.subjects.length} مواد'),
              ],
            ),
          ),
          children: [
            if (student.subjects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('لا توجد علامات لهذا الطالب بعد'),
              )
            else
              _SubjectsTable(
                studentId: student.studentId,
                subjects: student.subjects,
                onEditMark: onEditMark,
                onDeleteMark: onDeleteMark,
              ),
          ],
        ),
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// A real, horizontally-scrollable data table.
/// This structurally prevents the RenderFlex overflow that the old
/// manual Row/Expanded layout could hit on narrow screens: if the
/// content is wider than the screen, it scrolls instead of overflowing.
class _SubjectsTable extends StatelessWidget {
  const _SubjectsTable({
    required this.studentId,
    required this.subjects,
    required this.onEditMark,
    required this.onDeleteMark,
  });

  final int studentId;
  final List<_SubjectMarksAggregate> subjects;
  final void Function(int studentId, int subjectId, GradeItem? existingMark, String type) onEditMark;
  final Future<void> Function(GradeItem mark) onDeleteMark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
          MaterialStateProperty.all(AppColors.primary.withOpacity(0.06)),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontSize: 12,
          ),
          dataTextStyle: const TextStyle(fontSize: 13),
          columnSpacing: 14,
          horizontalMargin: 12,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 64,
          columns: const [
            DataColumn(label: Text('المادة')),
            DataColumn(label: Text('written')),
            DataColumn(label: Text('oral')),
            DataColumn(label: Text('practical')),
            DataColumn(label: Text('المجموع')),
          ],
          rows: subjects.map((subject) {
            return DataRow(
              cells: [
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      subject.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                DataCell(
                  _ScoreChip(
                    item: subject.written,
                    onEdit: () => onEditMark(studentId, subject.subjectId, subject.written, 'written'),
                    onDelete: subject.written == null
                        ? null
                        : () => onDeleteMark(subject.written!),
                  ),
                ),
                DataCell(
                  _ScoreChip(
                    item: subject.oral,
                    onEdit: () => onEditMark(studentId, subject.subjectId, subject.oral, 'oral'),
                    onDelete: subject.oral == null
                        ? null
                        : () => onDeleteMark(subject.oral!),
                  ),
                ),
                DataCell(
                  _ScoreChip(
                    item: subject.practical,
                    onEdit: () => onEditMark(studentId, subject.subjectId, subject.practical, 'practical'),
                    onDelete: subject.practical == null
                        ? null
                        : () => onDeleteMark(subject.practical!),
                  ),
                ),
                DataCell(
                  Text(
                    '${subject.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// A compact, reliably-tappable score cell.
/// Edit and delete are SIBLING widgets (not nested InkWells), each with a
/// real tap target, so taps land correctly on real devices. Delete asks
/// for confirmation first so a stray tap can't wipe a mark.
class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.item, required this.onEdit, this.onDelete});

  final GradeItem? item;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasValue = item != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: hasValue
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onEdit,
            child: Container(
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasValue
                      ? AppColors.primary.withOpacity(0.25)
                      : AppColors.border.withOpacity(0.4),
                ),
              ),
              child: Text(
                hasValue ? '${item!.mark}' : '-',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: hasValue
                      ? AppColors.onSurface
                      : AppColors.onSurface.withOpacity(0.35),
                ),
              ),
            ),
          ),
        ),
        if (onDelete != null)
          SizedBox(
            width: 34,
            height: 34,
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 18,
              tooltip: 'حذف العلامة',
              onPressed: () => _confirmDelete(context),
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AppColors.error.withOpacity(0.75),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العلامة'),
        content: const Text('هل أنت متأكد من حذف هذه العلامة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Give the dialog's exit transition time to fully finish before
      // the list below starts rebuilding. Firing both animations at
      // the exact same instant is a known crash trigger on some
      // MediaTek/Mali GPU devices.
      await Future.delayed(const Duration(milliseconds: 200));
      onDelete?.call();
    }
  }
}

class _MarkEditorBottomSheet extends StatefulWidget {
  const _MarkEditorBottomSheet({
    required this.availableItems,
    required this.cubit,
    this.existingMark,
    this.forcedType,
    this.defaultStudentId,
    this.defaultSubjectId,
  });

  final List<GradeItem> availableItems;
  final GradesCubit cubit;
  final GradeItem? existingMark;
  final String? forcedType;
  final int? defaultStudentId;
  final int? defaultSubjectId;

  @override
  State<_MarkEditorBottomSheet> createState() => _MarkEditorBottomSheetState();
}

class _MarkEditorBottomSheetState extends State<_MarkEditorBottomSheet> {
  late final TextEditingController _scoreController;
  String? _previousErrorMessage;

  late List<_StudentOption> _students;
  late List<_SubjectOption> _subjects;

  late _StudentOption _selectedStudent;
  late _SubjectOption _selectedSubject;
  late String _selectedType;
  List<SubjectComponent> _components = const [];
  bool _isLoadingComponents = false;
  bool _isSaving = false;

  static const List<String> _types = <String>['written', 'oral', 'practical'];

  @override
  void initState() {
    super.initState();

    _scoreController = TextEditingController(
      text: widget.existingMark != null ? '${widget.existingMark!.mark}' : '',
    );

    _students = _buildStudentOptions(widget.availableItems);
    _subjects = _buildSubjectOptions(widget.availableItems);

    final existing = widget.existingMark;
    _selectedStudent = _findStudent(widget.defaultStudentId ?? existing?.studentId) ?? _students.first;
    _selectedSubject = _findSubject(widget.defaultSubjectId ?? existing?.subjectId) ?? _subjects.first;
    _selectedType = _types.contains(widget.forcedType)
        ? widget.forcedType!
        : (existing != null && _types.contains(existing.type)
        ? existing.type
        : _types.first);

    _loadComponents();
  }

  _StudentOption? _findStudent(int? studentId) {
    if (studentId == null) return null;
    for (final student in _students) {
      if (student.id == studentId) return student;
    }
    return null;
  }

  _SubjectOption? _findSubject(int? subjectId) {
    if (subjectId == null) return null;
    for (final subject in _subjects) {
      if (subject.id == subjectId) return subject;
    }
    return null;
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadComponents() async {
    setState(() {
      _isLoadingComponents = true;
    });

    developer.log(
      'Loading components for subject: ${_selectedSubject.id}',
      name: 'MarkEditor',
    );

    final comps = await widget.cubit.fetchSubjectComponents(_selectedSubject.id);

    developer.log(
      'Loaded ${comps.length} components: ${comps.map((c) => '${c.id}:${c.name}').join(", ")}',
      name: 'MarkEditor',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _components = comps;
      _isLoadingComponents = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.existingMark == null
                        ? Icons.add_chart_rounded
                        : Icons.edit_note_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.existingMark == null ? 'إضافة علامة' : 'تعديل علامة',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.existingMark == null
                            ? 'أدخل بيانات العلامة الجديدة'
                            : 'قم بتعديل بيانات العلامة المحددة',
                        style: TextStyle(
                          color: AppColors.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProfessionalDropdown<_StudentOption>(
              label: 'الطالب',
              value: _selectedStudent,
              items: _students,
              itemToString: (s) => s.name,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedStudent = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _ProfessionalDropdown<_SubjectOption>(
              label: 'المادة',
              value: _selectedSubject,
              items: _subjects,
              itemToString: (s) => s.name,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedSubject = value;
                });
                _loadComponents();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _ProfessionalDropdown<String>(
              label: 'القسم',
              value: _selectedType,
              items: _types,
              itemToString: (s) => s,
              onChanged: (value) {
                if (value == null || value.isEmpty) return;
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _scoreController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'العلامة',
                hintText: 'مثال: 60',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
              ),
            ),
            if (_isLoadingComponents) ...[
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(999),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                    _isSaving ? null : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      widget.existingMark == null ? 'إضافة' : 'حفظ',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    // Close the keyboard first and let it fully dismiss before we later
    // pop this sheet. Popping a route while the IME is still tearing
    // down is a known source of native crashes on some Android devices.
    FocusScope.of(context).unfocus();

    final score = int.tryParse(_scoreController.text.trim());
    if (score == null || score < 0) {
      _showError('الرجاء إدخال علامة صحيحة');
      return;
    }

    // Resolve component ID (required for adding/editing marks)
    final componentId = _resolveComponentId();
    if (componentId == null || componentId <= 0) {
      _showError(
        'تعذر تحديد مكون المادة لنوع $_selectedType. تأكد من وجود بيانات من قبل للنوع المطلوب أو حاول لاحقاً.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final matching = _findExistingMark();
    final termId = matching?.termId ?? _selectedStudent.termId;

    bool ok;
    if (matching != null) {
      ok = await widget.cubit.updateGradeScore(matching.id, score, type: _selectedType);
    } else {
      ok = await widget.cubit.addMark(
        studentId: _selectedStudent.id,
        sectionId: _selectedStudent.sectionId,
        subjectId: _selectedSubject.id,
        subjectComponentId: componentId,
        termId: termId > 0 ? termId : 1,
        mark: score,
        type: _selectedType,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (ok) {
      // Small safety margin in case the request resolved very fast and
      // the keyboard-close animation triggered by unfocus() above is
      // still finishing.
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    }
  }

  GradeItem? _findExistingMark() {
    for (final item in widget.availableItems) {
      if (item.studentId == _selectedStudent.id &&
          item.subjectId == _selectedSubject.id &&
          _normalizeType(item.type) == _selectedType) {
        return item;
      }
    }
    return null;
  }

  int? _resolveComponentId() {
    developer.log(
      'Resolving component for type: $_selectedType, subject: ${_selectedSubject.id}',
      name: 'MarkEditor',
    );

    // 1. Use existing mark's component ID if it matches the selected type
    if (widget.existingMark != null &&
        widget.existingMark!.subjectId == _selectedSubject.id &&
        _normalizeType(widget.existingMark!.type) == _selectedType) {
      developer.log(
        'Using existing mark component: ${widget.existingMark!.subjectComponentId}',
        name: 'MarkEditor',
      );
      return widget.existingMark!.subjectComponentId;
    }

    // 2. Find component ID from existing items with same subject and type
    for (final item in widget.availableItems) {
      if (item.subjectId == _selectedSubject.id &&
          _normalizeType(item.type) == _selectedType &&
          item.subjectComponentId > 0) {
        developer.log(
          'Found in availableItems: ${item.subjectComponentId} for type $_selectedType',
          name: 'MarkEditor',
        );
        return item.subjectComponentId;
      }
    }

    // 3. Find component by matching normalized type name in loaded components
    developer.log(
      'Searching in _components (${_components.length}): ${_components.map((c) => '${c.id}:${c.name}').join(", ")}',
      name: 'MarkEditor',
    );
    for (final component in _components) {
      final normalized = _normalizeType(component.name);
      developer.log(
        'Checking component ${component.id}: name="${component.name}" → normalized="$normalized" vs target="$_selectedType"',
        name: 'MarkEditor',
      );
      if (normalized == _selectedType && component.id > 0) {
        developer.log(
          'Match found: component ${component.id} for type $_selectedType',
          name: 'MarkEditor',
        );
        return component.id;
      }
    }

    // 4. No matching component found — return null to signal error
    developer.log(
      'No matching component found for type $_selectedType',
      name: 'MarkEditor',
    );
    return null;
  }

  String _normalizeType(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.contains('written') ||
        normalized.contains('كت') ||
        normalized.contains('تحر') ||
        normalized.contains('كتابي') ||
        normalized.contains('كتابة')) {
      return 'written';
    }

    if (normalized.contains('oral') ||
        normalized.contains('شف') ||
        normalized.contains('شهي') ||
        normalized.contains('مشاف')) {
      return 'oral';
    }

    if (normalized.contains('practical') ||
        normalized.contains('pracitical') ||
        normalized.contains('practcal') ||
        normalized.contains('عم') ||
        normalized.contains('تطبيق') ||
        normalized.contains('مختبر')) {
      return 'practical';
    }

    return normalized;
  }

  List<_StudentOption> _buildStudentOptions(List<GradeItem> items) {
    final map = <int, _StudentOption>{};
    for (final item in items) {
      map.putIfAbsent(
        item.studentId,
            () => _StudentOption(
          id: item.studentId,
          name: item.studentName,
          sectionId: item.sectionId,
          termId: item.termId,
        ),
      );
    }
    final values = map.values.toList();
    values.sort((a, b) => a.name.compareTo(b.name));
    return values;
  }

  List<_SubjectOption> _buildSubjectOptions(List<GradeItem> items) {
    final map = <int, _SubjectOption>{};
    for (final item in items) {
      if (item.subjectId <= 0 || item.subjectName.trim().isEmpty) {
        continue;
      }
      map.putIfAbsent(
        item.subjectId,
            () => _SubjectOption(id: item.subjectId, name: item.subjectName),
      );
    }
    final values = map.values.toList();
    values.sort((a, b) => a.name.compareTo(b.name));
    return values;
  }

  void _showError(String message) {
    if (_previousErrorMessage == message) {
      return;
    }
    _previousErrorMessage = message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _ProfessionalDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemToString;
  final ValueChanged<T?> onChanged;

  const _ProfessionalDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary.withOpacity(0.6)),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemToString(item),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _EmptyGradesView extends StatelessWidget {
  const _EmptyGradesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.grading_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'لا توجد بيانات علامات لعرضها',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف أول علامة من الزر العلوي أو حدّث التصفية الحالية.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withOpacity(0.55),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentOption {
  const _StudentOption({
    required this.id,
    required this.name,
    required this.sectionId,
    required this.termId,
  });

  final int id;
  final String name;
  final int sectionId;
  final int termId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _StudentOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class _SubjectOption {
  const _SubjectOption({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _SubjectOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class _StudentMarksAggregate {
  const _StudentMarksAggregate({
    required this.studentId,
    required this.studentName,
    required this.grade,
    required this.section,
    required this.subjects,
  });

  final int studentId;
  final String studentName;
  final String grade;
  final String section;
  final List<_SubjectMarksAggregate> subjects;

  static List<_StudentMarksAggregate> build(List<GradeItem> items) {
    final studentMap = <String, _StudentBuffer>{};

    for (final item in items) {
      final studentKey = '${item.studentId}-${item.studentName}';
      final studentBuffer = studentMap.putIfAbsent(
        studentKey,
            () => _StudentBuffer(
          studentId: item.studentId,
          studentName: item.studentName,
          grade: item.grade,
          section: item.section,
        ),
      );

      if (item.subjectId <= 0 || item.subjectName.trim().isEmpty) {
        continue;
      }

      final subjectBuffer = studentBuffer.subjects.putIfAbsent(
        item.subjectId,
            () => _SubjectBuffer(
          subjectId: item.subjectId,
          subjectName: item.subjectName,
        ),
      );

      final type = item.type.trim().toLowerCase();
      if (type == 'written') {
        subjectBuffer.written = item;
      } else if (type == 'oral') {
        subjectBuffer.oral = item;
      } else if (type == 'practical') {
        subjectBuffer.practical = item;
      }
    }

    final allSubjects = <int, String>{};
    for (final item in items) {
      if (item.subjectId > 0 && item.subjectName.trim().isNotEmpty) {
        allSubjects.putIfAbsent(item.subjectId, () => item.subjectName.trim());
      }
    }

    final result = <_StudentMarksAggregate>[];
    for (final student in studentMap.values) {
      for (final entry in allSubjects.entries) {
        student.subjects.putIfAbsent(
          entry.key,
              () => _SubjectBuffer(
            subjectId: entry.key,
            subjectName: entry.value,
          ),
        );
      }

      final subjects = student.subjects.values
          .map(
            (subject) => _SubjectMarksAggregate(
          subjectId: subject.subjectId,
          subjectName: subject.subjectName,
          written: subject.written,
          oral: subject.oral,
          practical: subject.practical,
        ),
      )
          .toList();

      subjects.sort((a, b) => a.subjectName.compareTo(b.subjectName));

      result.add(
        _StudentMarksAggregate(
          studentId: student.studentId,
          studentName: student.studentName,
          grade: student.grade,
          section: student.section,
          subjects: subjects,
        ),
      );
    }

    result.sort((a, b) => a.studentName.compareTo(b.studentName));
    return result;
  }
}

class _SubjectMarksAggregate {
  const _SubjectMarksAggregate({
    required this.subjectId,
    required this.subjectName,
    required this.written,
    required this.oral,
    required this.practical,
  });

  final int subjectId;
  final String subjectName;
  final GradeItem? written;
  final GradeItem? oral;
  final GradeItem? practical;

  int get total =>
      (written?.mark ?? 0) + (oral?.mark ?? 0) + (practical?.mark ?? 0);
}

class _StudentBuffer {
  _StudentBuffer({
    required this.studentId,
    required this.studentName,
    required this.grade,
    required this.section,
  });

  final int studentId;
  final String studentName;
  final String grade;
  final String section;
  final Map<int, _SubjectBuffer> subjects = <int, _SubjectBuffer>{};
}

class _SubjectBuffer {
  _SubjectBuffer({required this.subjectId, required this.subjectName});

  final int subjectId;
  final String subjectName;
  GradeItem? written;
  GradeItem? oral;
  GradeItem? practical;
}