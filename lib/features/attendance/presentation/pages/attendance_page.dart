import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/teacher_attendance_section.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<TeacherAttendanceSection> _sections = <TeacherAttendanceSection>[];
  final List<TeacherAttendanceSection> _allSections =
      <TeacherAttendanceSection>[];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;

  int _selectedSectionId = 0;
  int _selectedScheduleId = 0;
  String _selectedDate = '';

  List<TeacherAttendanceStudent> get _filteredStudents {
    if (_selectedSectionId == 0) return const <TeacherAttendanceStudent>[];
    final section = _sections.firstWhere(
      (item) => item.sectionId == _selectedSectionId,
      orElse: () =>
          _allSections.firstOrNull ??
          TeacherAttendanceSection(
            sectionId: 0,
            sectionName: '',
            sectionFullName: '',
            classId: 0,
            className: '',
            totalStudents: 0,
            attendance: TeacherAttendanceSummary(
              date: '',
              present: 0,
              absent: 0,
              late: 0,
              excused: 0,
              percentage: 0,
            ),
            schedules: const <TeacherAttendanceSchedule>[],
            students: const <TeacherAttendanceStudent>[],
          ),
    );
    return section.students;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadSections();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSections() async {
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
      final repository = RepositoryProvider.of<AttendanceRepository>(
        context,
        listen: false,
      );
      final sections = await repository.fetchSectionsWithStudents(token);
      if (!mounted) return;
      setState(() {
        _allSections.clear();
        _allSections.addAll(sections);
        _sections.clear();
        _sections.addAll(sections);
        _selectedSectionId = sections.isNotEmpty ? sections.first.sectionId : 0;
        _selectedScheduleId =
            sections.isNotEmpty && sections.first.schedules.isNotEmpty
            ? sections.first.schedules.first.scheduleId
            : 0;
        _selectedDate = sections.isNotEmpty
            ? sections.first.attendance.date
            : '';
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

  void _updateAttendance(int studentId, String newStatus) {
    setState(() {
      final section = _sections.firstWhere(
        (item) => item.sectionId == _selectedSectionId,
        orElse: () => _allSections.firstWhere(
          (item) => item.sectionId == _selectedSectionId,
        ),
      );
      final student = section.students.firstWhere(
        (item) => item.studentId == studentId,
      );
      student.attendanceStatus = newStatus;
    });
  }

  Future<void> _saveAttendance() async {
    final token = context.read<AuthCubit>().sessionToken;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      showAppFeedback(
        context,
        message: 'لم يتم العثور على جلسة نشطة',
        isError: true,
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final repository = RepositoryProvider.of<AttendanceRepository>(
        context,
        listen: false,
      );
      final payload = <Map<String, dynamic>>[];
      final seenStudentIds = <int>{};
      for (final student in _filteredStudents) {
        if (seenStudentIds.contains(student.studentId)) {
          continue;
        }
        seenStudentIds.add(student.studentId);
        payload.add({
          'student_id': student.studentId,
          'status': _mapAttendanceStatus(student.attendanceStatus),
        });
      }

      final result = await repository.batchUpdateAttendance(
        token: token,
        sectionId: _selectedSectionId,
        date: _selectedDate.isEmpty
            ? DateTime.now().toIso8601String().split('T').first
            : _selectedDate,
        scheduleId: _selectedScheduleId,
        students: payload,
      );

      if (!mounted) return;
      showAppFeedback(
        context,
        message:
            'تم حفظ الحضور بنجاح • ${result.present} حاضر • ${result.late} متأخر',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      showAppFeedback(
        context,
        message: error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int get _presentCount =>
      _filteredStudents.where((s) => s.attendanceStatus == 'present').length;

  int get _lateCount =>
      _filteredStudents.where((s) => s.attendanceStatus == 'late').length;

  int get _absentCount =>
      _filteredStudents.where((s) => s.attendanceStatus == 'absent').length;

  double get _attendancePercentage => _filteredStudents.isEmpty
      ? 0
      : (_presentCount + _lateCount) / _filteredStudents.length * 100;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'سجل الحضور',
      currentIndex: 0,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildClassSectionSelectors(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 36,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: () => _loadSections(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'الحاضرون',
                          _presentCount.toString(),
                          AppColors.success,
                        ),
                        _buildStatCard(
                          'المتأخرون',
                          _lateCount.toString(),
                          AppColors.warning,
                        ),
                        _buildStatCard(
                          'الغائبون',
                          _absentCount.toString(),
                          AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'نسبة الحضور: ${_attendancePercentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            _attendancePercentage >= 80
                                ? Icons.check_circle
                                : Icons.warning,
                            color: AppColors.onPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (!_isLoading && _errorMessage == null)
              Expanded(
                child: _filteredStudents.isEmpty
                    ? const Center(
                        child: Text('لا توجد طلاب في هذا الصف أو الشعبة'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(
                                          index * 0.05,
                                          1.0,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                    ),
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(
                                            index * 0.05,
                                            1.0,
                                            curve: Curves.easeOut,
                                          ),
                                        ),
                                      ),
                                  child: _AttendanceCard(
                                    student: student,
                                    onStatusChanged: _updateAttendance,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            if (!_isLoading && _errorMessage == null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.border.withOpacity(0.3)),
                  ),
                ),
                child: PrimaryButton(
                  label: _isSaving ? 'جاري الحفظ...' : 'حفظ الحضور',
                  onPressed: _isSaving
                      ? () {}
                      : () {
                          unawaited(_saveAttendance());
                        },
                  icon: Icons.save,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _mapAttendanceStatus(String status) {
    switch (status) {
      case 'present':
        return 'present';
      case 'late':
        return 'late';
      case 'absent':
        return 'absent';
      default:
        return 'present';
    }
  }

  Widget _buildClassSectionSelectors() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الصف والشعبة',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(

            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: _selectedSectionId == 0 ? null : _selectedSectionId,
                  decoration: InputDecoration(
                    labelText: 'الصف و الشعبة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                  items: _sections
                      .map(
                        (section) => DropdownMenuItem<int>(
                          value: section.sectionId,
                          child: Text(
                            section.sectionFullName.isNotEmpty
                                ? section.sectionFullName
                                : section.sectionName,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final selected = _sections.firstWhere(
                      (item) => item.sectionId == value,
                    );
                    setState(() {
                      _selectedSectionId = value;
                      _selectedScheduleId = selected.schedules.isNotEmpty
                          ? selected.schedules.first.scheduleId
                          : 0;
                      _selectedDate = selected.attendance.date;
                    });
                  },
                ),
              ),
            //  const SizedBox(width: AppSpacing.sm),
             //  Expanded(
             //    child: DropdownButtonFormField<int>(
             //      isExpanded: true,
             //      value: _selectedScheduleId == 0 ? null : _selectedScheduleId,
             // // //     decoration: InputDecoration(
             // //        labelText: 'الحصة',
             // //        border: OutlineInputBorder(
             // //          borderRadius: BorderRadius.circular(12),
             // //        ),
             // //        filled: true,
             // //        fillColor: AppColors.surfaceVariant,
             // //      ),
             //      items: _sections
             //          .firstWhere(
             //            (item) => item.sectionId == _selectedSectionId,
             //            orElse: () => _sections.isNotEmpty
             //                ? _sections.first
             //                : TeacherAttendanceSection(
             //                    sectionId: 0,
             //                    sectionName: '',
             //                    sectionFullName: '',
             //                    classId: 0,
             //                    className: '',
             //                    totalStudents: 0,
             //                    attendance: TeacherAttendanceSummary(
             //                      date: '',
             //                      present: 0,
             //                      absent: 0,
             //                      late: 0,
             //                      excused: 0,
             //                      percentage: 0,
             //                    ),
             //                    schedules: const <TeacherAttendanceSchedule>[],
             //                    students: const <TeacherAttendanceStudent>[],
             //                  ),
             //          )
             //          .schedules
             //          .map(
             //            (schedule) => DropdownMenuItem<int>(
             //              value: schedule.scheduleId,
             //              child: Text(schedule.subjectName),
             //            ),
             //          )
             //          .toList(),
             //      onChanged: (value) {
             //        if (value == null) return;
             //        setState(() => _selectedScheduleId = value);
             //      },
             //    ),
             //  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.student, required this.onStatusChanged});

  final TeacherAttendanceStudent student;
  final Function(int, String) onStatusChanged;

  Color _colorForStatus(String status) {
    switch (status) {
      case 'present':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'absent':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _labelForStatus(String status) {
    switch (status) {
      case 'present':
        return 'حاضر';
      case 'late':
        return 'متأخر';
      case 'absent':
        return 'غائب';
      default:
        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(student.attendanceStatus);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Student Avatar
            Hero(
              tag: 'student-${student.studentId}',
              child: CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.1),
                child: Text(
                  student.fullName.isNotEmpty
                      ? student.fullName.substring(0, 1)
                      : '',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'رقم الطالب: ${student.studentId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Status and Actions
            Row(
              children: [
                StatusBadge(
                  label: _labelForStatus(student.attendanceStatus),
                  color: color,
                ),
                const SizedBox(width: AppSpacing.sm),
                PopupMenuButton<String>(
                  onSelected: (status) {
                    onStatusChanged(student.studentId, status);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'present',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('حاضر'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'late',
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('متأخر'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'absent',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('غائب'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.onSurface.withOpacity(0.6),
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
}
