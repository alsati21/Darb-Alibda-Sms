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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(_errorMessage!, textAlign: TextAlign.center),
                  ),
                )
              else
                _buildTodaySchedule(),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'جدول الأسبوع',
                subtitle: 'راجع الحصص المتاحة خلال الأيام القادمة',
              ),
              if (!_isLoading && _errorMessage == null)
                _buildWeekSchedule(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    if (_todayItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.event_available, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('لا توجد حصص مقررة اليوم', style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _todayItems.map((item) {
        final startTime = _formatTime(item.timeSlot.startTime);
        final endTime = _formatTime(item.timeSlot.endTime);
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surfaceVariant],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 10,
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
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.subject, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.section, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withOpacity(0.75))),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${item.timeSlot.name} • ${item.term.isNotEmpty ? item.term : 'الحصة'}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface.withOpacity(0.65))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$startTime - $endTime', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekSchedule() {
    if (_weekItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text('لا توجد حصص لهذا الأسبوع', style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    final days = _weekItems.keys.toList();
    return Column(
      children: days.map((day) {
        final items = _weekItems[day] ?? const <TeacherWeekScheduleItem>[];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.calendar_view_day, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(_displayDayName(day), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (items.isEmpty)
                Text('لا توجد حصص لهذا اليوم', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withOpacity(0.7)))
              else
                ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: AppColors.primary.withOpacity(0.35), width: 3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.play_circle_outline, color: AppColors.secondary, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.subject, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${item.timeSlot.name} • ${item.section}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface.withOpacity(0.7))),
                          ],
                        ),
                      ),
                      Text(_formatTime(item.timeSlot.startTime), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            ],
          ),
        );
      }).toList(),
    );
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
