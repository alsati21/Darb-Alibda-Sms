import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/teacher_schedule.dart';
import '../../data/repositories/schedule_repository.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<TeacherTodayScheduleItem> _todayItems = const <TeacherTodayScheduleItem>[];
  final Map<String, List<TeacherWeekScheduleItem>> _weekItems = <String, List<TeacherWeekScheduleItem>>{};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final token = context.read<AuthCubit>().sessionToken;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'لم يتم العثور على جلسة نشطة';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = RepositoryProvider.of<ScheduleRepository>(context, listen: false);
      final today = await repository.fetchTodaySchedule(token);
      final week = await repository.fetchWeekSchedule(token);
      if (!mounted) return;
      setState(() {
        _todayItems = today;
        _weekItems.clear();
        _weekItems.addAll(week);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الجدول والمهمات',
      currentIndex: 2,
      body: RefreshIndicator(
        onRefresh: _loadSchedule,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: 'جدول اليوم',
                subtitle: 'حصصك المقررة اليوم من الخادم',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                _ErrorCard(message: _errorMessage!)
              else
                _buildTodaySchedule(),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(
                title: 'جدول الأسبوع',
                subtitle: 'راجع الحصص المتاحة خلال الأيام القادمة',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!_isLoading && _errorMessage == null) _buildWeekSchedule(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Today's schedule — a clean vertical list of period cards.
  // ---------------------------------------------------------------------
  Widget _buildTodaySchedule() {
    if (_todayItems.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.event_available_rounded,
        message: 'لا توجد حصص مقررة اليوم',
      );
    }

    return Column(
      children: _todayItems.map((item) {
        final startTime = _formatTime(item.timeSlot.startTime);
        final endTime = _formatTime(item.timeSlot.endTime);
        final color = _colorForSubject(item.subject);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border(left: BorderSide(color: color, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.schedule_rounded, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.section,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.timeSlot.name} • ${item.term.isNotEmpty ? item.term : 'الحصة'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface.withOpacity(0.55)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$startTime - $endTime',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------
  // Week schedule — a real timetable grid: periods as rows, days as
  // columns, horizontally scrollable so it never overflows on a phone.
  // ---------------------------------------------------------------------
  Widget _buildWeekSchedule() {
    final hasAnyLesson = _weekItems.values.any((items) => items.isNotEmpty);
    if (_weekItems.isEmpty || !hasAnyLesson) {
      return const _EmptyStateCard(
        icon: Icons.calendar_view_week_rounded,
        message: 'لا توجد حصص لهذا الأسبوع',
      );
    }

    // Canonical Sun→Sat order for display; unknown day labels sort last.
    const dayOrder = <String>[
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    final days = _weekItems.keys.toList()
      ..sort((a, b) {
        final aRank = dayOrder.indexOf(a);
        final bRank = dayOrder.indexOf(b);
        final aSafe = aRank == -1 ? dayOrder.length : aRank;
        final bSafe = bRank == -1 ? dayOrder.length : bRank;
        return aSafe.compareTo(bSafe);
      });

    // Collect every distinct period across the week (keyed by period
    // name), keeping one representative item per key for its time label.
    final periodByKey = <String, TeacherWeekScheduleItem>{};
    for (final items in _weekItems.values) {
      for (final item in items) {
        final key = item.timeSlot.name.isNotEmpty
            ? item.timeSlot.name
            : _formatTime(item.timeSlot.startTime);
        periodByKey.putIfAbsent(key, () => item);
      }
    }

    final periodKeys = periodByKey.keys.toList()
      ..sort((a, b) {
        final aTime = _formatTime(periodByKey[a]!.timeSlot.startTime);
        final bTime = _formatTime(periodByKey[b]!.timeSlot.startTime);
        return aTime.compareTo(bTime);
      });

    if (periodKeys.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.calendar_view_week_rounded,
        message: 'لا توجد حصص لهذا الأسبوع',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: const FixedColumnWidth(88),
            for (var i = 0; i < days.length; i++) i + 1: const FixedColumnWidth(128),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.25)),
            verticalInside: BorderSide(color: AppColors.border.withOpacity(0.25)),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
              children: [
                const _GridHeaderCell(text: 'الوقت'),
                ...days.map((day) => _GridHeaderCell(text: _displayDayName(day))),
              ],
            ),
            for (var i = 0; i < periodKeys.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: i.isEven ? Colors.white : const Color(0xFFFAFAFA),
                ),
                children: [
                  _GridTimeCell(item: periodByKey[periodKeys[i]]!, formatTime: _formatTime),
                  ...days.map((day) {
                    final key = periodKeys[i];
                    final dayItems = _weekItems[day] ?? const <TeacherWeekScheduleItem>[];
                    TeacherWeekScheduleItem? match;
                    for (final candidate in dayItems) {
                      final candidateKey = candidate.timeSlot.name.isNotEmpty
                          ? candidate.timeSlot.name
                          : _formatTime(candidate.timeSlot.startTime);
                      if (candidateKey == key) {
                        match = candidate;
                        break;
                      }
                    }
                    if (match == null) {
                      return const _GridEmptyCell();
                    }
                    return _GridLessonCell(item: match, color: _colorForSubject(match.subject));
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _colorForSubject(String subject) {
    const palette = <Color>[
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
      Color(0xFF84CC16),
    ];
    if (subject.isEmpty) return AppColors.primary;
    final index = subject.hashCode.abs() % palette.length;
    return palette[index];
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    final parts = raw.split('T');
    if (parts.length < 2) return raw;
    final timePart = parts[1];
    return timePart.substring(0, timePart.length > 5 ? 5 : timePart.length);
  }

  String _displayDayName(String day) {
    switch (day) {
      case 'الإثنين':
        return 'الإثنين';
      case 'الثلاثاء':
        return 'الثلاثاء';
      case 'الأربعاء':
        return 'الأربعاء';
      case 'الخميس':
        return 'الخميس';
      case 'الجمعة':
        return 'الجمعة';
      case 'السبت':
        return 'السبت';
      case 'الأحد':
        return 'الأحد';
      default:
        return day;
    }
  }
}

class _GridHeaderCell extends StatelessWidget {
  const _GridHeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _GridTimeCell extends StatelessWidget {
  const _GridTimeCell({required this.item, required this.formatTime});

  final TeacherWeekScheduleItem item;
  final String Function(String) formatTime;

  @override
  Widget build(BuildContext context) {
    final start = formatTime(item.timeSlot.startTime);
    final end = formatTime(item.timeSlot.endTime);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.timeSlot.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: AppColors.onSurface.withOpacity(0.8),
            ),
          ),
          if (start.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              end.isNotEmpty ? '$start–$end' : start,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GridLessonCell extends StatelessWidget {
  const _GridLessonCell({required this.item, required this.color});

  final TeacherWeekScheduleItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.section,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridEmptyCell extends StatelessWidget {
  const _GridEmptyCell();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          '—',
          style: TextStyle(
            color: AppColors.onSurface.withOpacity(0.2),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
