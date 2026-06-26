import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/primary_button.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, List<String>> _classSections = {
    'الصف الأول': ['A', 'B'],
    'الصف الثاني': ['A', 'B'],
    'الصف الثالث': ['A', 'B'],
    'الصف الرابع': ['A'],
  };

  String _selectedGrade = 'الصف الثالث';
  String _selectedSection = 'A';

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'محمد علي',
      'status': 'حاضر',
      'color': AppColors.success,
      'id': '1',
      'grade': 'الصف الثالث',
      'section': 'A',
    },
    {
      'name': 'سارة خالد',
      'status': 'متأخر',
      'color': AppColors.warning,
      'id': '2',
      'grade': 'الصف الثالث',
      'section': 'A',
    },
    {
      'name': 'أحمد يوسف',
      'status': 'غائب',
      'color': AppColors.error,
      'id': '3',
      'grade': 'الصف الثالث',
      'section': 'B',
    },
    {
      'name': 'فاطمة سالم',
      'status': 'حاضر',
      'color': AppColors.success,
      'id': '4',
      'grade': 'الصف الأول',
      'section': 'A',
    },
    {
      'name': 'علي حسن',
      'status': 'حاضر',
      'color': AppColors.success,
      'id': '5',
      'grade': 'الصف الثاني',
      'section': 'B',
    },
    {
      'name': 'مريم أحمد',
      'status': 'متأخر',
      'color': AppColors.warning,
      'id': '6',
      'grade': 'الصف الثاني',
      'section': 'A',
    },
    {
      'name': 'خالد محمد',
      'status': 'غائب',
      'color': AppColors.error,
      'id': '7',
      'grade': 'الصف الرابع',
      'section': 'A',
    },
    {
      'name': 'نورة سعيد',
      'status': 'حاضر',
      'color': AppColors.success,
      'id': '8',
      'grade': 'الصف الأول',
      'section': 'B',
    },
  ];

  List<Map<String, dynamic>> get _filteredStudents => _students
      .where((s) => s['grade'] == _selectedGrade && s['section'] == _selectedSection)
      .toList();

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAttendance(String studentId, String newStatus, Color newColor) {
    setState(() {
      final student = _students.firstWhere((s) => s['id'] == studentId);
      student['status'] = newStatus;
      student['color'] = newColor;
    });
  }

  int get _presentCount => _filteredStudents.where((s) => s['status'] == 'حاضر').length;
  int get _lateCount => _filteredStudents.where((s) => s['status'] == 'متأخر').length;
  int get _absentCount => _filteredStudents.where((s) => s['status'] == 'غائب').length;
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
            // Stats Header
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
                      _buildStatCard('الحاضرون', _presentCount.toString(), AppColors.success),
                      _buildStatCard('المتأخرون', _lateCount.toString(), AppColors.warning),
                      _buildStatCard('الغائبون', _absentCount.toString(), AppColors.error),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          _attendancePercentage >= 80 ? Icons.check_circle : Icons.warning,
                          color: AppColors.onPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Attendance List
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
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
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
                          position: Tween<Offset>(
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
            // Save Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.3)),
                ),
              ),
              child: PrimaryButton(
                label: 'حفظ الحضور',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حفظ سجل الحضور بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: Icons.save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSectionSelectors() {
    final sections = _classSections[_selectedGrade] ?? ['A'];
    final defaultSection = sections.contains(_selectedSection) ? _selectedSection : sections.first;
    if (_selectedSection != defaultSection) {
      _selectedSection = defaultSection;
    }

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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: InputDecoration(
                    labelText: 'الصف',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                  items: _classSections.keys
                      .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedGrade = value;
                      _selectedSection = _classSections[value]!.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSection,
                  decoration: InputDecoration(
                    labelText: 'الشعبة',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                  items: sections
                      .map((section) => DropdownMenuItem(value: section, child: Text(section)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedSection = value);
                  },
                ),
              ),
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
  const _AttendanceCard({
    required this.student,
    required this.onStatusChanged,
  });

  final Map<String, dynamic> student;
  final Function(String, String, Color) onStatusChanged;

  @override
  Widget build(BuildContext context) {
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
              tag: 'student-${student['id']}',
              child: CircleAvatar(
                radius: 24,
                backgroundColor: student['color'].withOpacity(0.1),
                child: Text(
                  (student['name'] as String).isNotEmpty ? (student['name'] as String).substring(0, 1) : '',
                  style: TextStyle(
                    color: student['color'],
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
                    student['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'رقم الطالب: ${student['id']}',
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
                  label: student['status'],
                  color: student['color'],
                ),
                const SizedBox(width: AppSpacing.sm),
                PopupMenuButton<String>(
                  onSelected: (status) {
                    Color color;
                    switch (status) {
                      case 'حاضر':
                        color = AppColors.success;
                        break;
                      case 'متأخر':
                        color = AppColors.warning;
                        break;
                      case 'غائب':
                        color = AppColors.error;
                        break;
                      default:
                        color = AppColors.primary;
                    }
                    onStatusChanged(student['id'], status, color);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'حاضر',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('حاضر'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'متأخر',
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('متأخر'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'غائب',
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
