import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/primary_button.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _tabs = ['الامتحانات', 'الواجبات', 'النشاطات'];

  final List<Map<String, dynamic>> _exams = [
    {'studentName': 'قيس حمدان', 'score': 91, 'status': 'ممتاز', 'color': AppColors.success, 'date': '15/5/2024'},
    {'studentName': 'هدى منصور', 'score': 87, 'status': 'جيد جداً', 'color': AppColors.primary, 'date': '15/5/2024'},
    {'studentName': 'ريان النجار', 'score': 78, 'status': 'جيد', 'color': AppColors.warning, 'date': '15/5/2024'},
    {'studentName': 'سارة أحمد', 'score': 95, 'status': 'ممتاز', 'color': AppColors.success, 'date': '15/5/2024'},
    {'studentName': 'محمد علي', 'score': 82, 'status': 'جيد جداً', 'color': AppColors.primary, 'date': '15/5/2024'},
  ];

  final List<Map<String, dynamic>> _homework = [
    {'studentName': 'قيس حمدان', 'score': 88, 'status': 'جيد جداً', 'color': AppColors.primary, 'date': '12/5/2024'},
    {'studentName': 'هدى منصور', 'score': 92, 'status': 'ممتاز', 'color': AppColors.success, 'date': '12/5/2024'},
    {'studentName': 'ريان النجار', 'score': 75, 'status': 'جيد', 'color': AppColors.warning, 'date': '12/5/2024'},
  ];

  final List<Map<String, dynamic>> _activities = [
    {'studentName': 'قيس حمدان', 'score': 85, 'status': 'جيد جداً', 'color': AppColors.primary, 'date': '10/5/2024'},
    {'studentName': 'هدى منصور', 'score': 90, 'status': 'ممتاز', 'color': AppColors.success, 'date': '10/5/2024'},
    {'studentName': 'ريان النجار', 'score': 80, 'status': 'جيد جداً', 'color': AppColors.primary, 'date': '10/5/2024'},
  ];

  List<Map<String, dynamic>> get _currentGrades {
    switch (_selectedIndex) {
      case 0:
        return _exams;
      case 1:
        return _homework;
      case 2:
        return _activities;
      default:
        return _exams;
    }
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _editGrade(int index) {
    final grade = _currentGrades[index];
    showDialog(
      context: context,
      builder: (context) => _EditGradeDialog(
        grade: grade,
        onSave: (newScore) {
          setState(() {
            grade['score'] = newScore;
            grade['status'] = _getGradeStatus(newScore);
            grade['color'] = _getGradeColor(newScore);
          });
        },
      ),
    );
  }

  String _getGradeStatus(int score) {
    if (score >= 90) return 'ممتاز';
    if (score >= 80) return 'جيد جداً';
    if (score >= 70) return 'جيد';
    if (score >= 60) return 'مقبول';
    return 'ضعيف';
  }

  Color _getGradeColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.primary;
    if (score >= 70) return AppColors.warning;
    if (score >= 60) return AppColors.info;
    return AppColors.error;
  }

  double get _averageGrade {
    if (_currentGrades.isEmpty) return 0;
    final sum = _currentGrades.map((g) => g['score'] as int).reduce((a, b) => a + b);
    return sum / _currentGrades.length;
  }

  int get _excellentCount => _currentGrades.where((g) => g['score'] >= 90).length;
  int get _goodCount => _currentGrades.where((g) => g['score'] >= 80 && g['score'] < 90).length;
  int get _fairCount => _currentGrades.where((g) => g['score'] >= 70 && g['score'] < 80).length;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'إدارة العلامات',
      currentIndex: 1,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header with Stats
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
                  const SectionHeader(
                    title: 'سجل العلامات',
                    subtitle: 'تحكم في إدخال وتعديل العلامات مع سبب التغيير',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Grade Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('الممتاز', _excellentCount.toString(), AppColors.success),
                      _buildStatCard('الجيد جداً', _goodCount.toString(), AppColors.primary),
                      _buildStatCard('الجيد', _fairCount.toString(), AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Average Grade
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
                          'المعدل: ${_averageGrade.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          _averageGrade >= 85 ? Icons.star : Icons.grade,
                          color: AppColors.onPrimary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Text(_tabs[index]),
                        selected: _selectedIndex == index,
                        onSelected: (_) {
                          setState(() => _selectedIndex = index);
                          _animationController.reset();
                          _animationController.forward();
                        },
                        backgroundColor: AppColors.surfaceVariant,
                        selectedColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: _selectedIndex == index ? AppColors.primary : AppColors.onSurface,
                          fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Grades List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _currentGrades.length,
                itemBuilder: (context, index) {
                  final grade = _currentGrades[index];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              index * 0.1,
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
                                index * 0.1,
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: _GradeCard(
                            grade: grade,
                            onEdit: () => _editGrade(index),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Add Grade Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.3)),
                ),
              ),
              child: PrimaryButton(
                label: 'إضافة علامة جديدة',
                onPressed: () {
                  // TODO: Implement add grade functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ميزة إضافة العلامات ستكون متاحة قريباً'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                icon: Icons.add,
              ),
            ),
          ],
        ),
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

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.grade,
    required this.onEdit,
  });

  final Map<String, dynamic> grade;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              grade['color'].withOpacity(0.1),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Student Avatar
              Hero(
                tag: 'grade-${grade['studentName']}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: grade['color'].withOpacity(0.1),
                  child: Text(
                    (grade['studentName'] as String).isNotEmpty ? (grade['studentName'] as String).substring(0, 1) : '',
                    style: TextStyle(
                      color: grade['color'],
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Grade Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade['studentName'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'التاريخ: ${grade['date']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Score and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${grade['score']}/100',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: grade['color'],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  StatusBadge(
                    label: grade['status'],
                    color: grade['color'],
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              // Edit Button
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
                tooltip: 'تعديل العلامة',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditGradeDialog extends StatefulWidget {
  const _EditGradeDialog({
    required this.grade,
    required this.onSave,
  });

  final Map<String, dynamic> grade;
  final Function(int) onSave;

  @override
  State<_EditGradeDialog> createState() => _EditGradeDialogState();
}

class _EditGradeDialogState extends State<_EditGradeDialog> {
  late TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(text: widget.grade['score'].toString());
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تعديل علامة ${widget.grade['studentName']}'),
      content: TextField(
        controller: _scoreController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'العلامة (0-100)',
          border: OutlineInputBorder(),
        ),
        maxLength: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final score = int.tryParse(_scoreController.text);
            if (score != null && score >= 0 && score <= 100) {
              widget.onSave(score);
              Navigator.of(context).pop();
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
