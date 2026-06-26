import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  String _recipient = 'طالب واحد';
  bool _scheduled = false;
  bool _showCompose = false;
  late AnimationController _animationController;

  final Map<String, List<String>> _classSections = {
    'الصف الأول': ['A', 'B'],
    'الصف الثاني': ['A', 'B'],
    'الصف الثالث': ['A', 'B'],
    'الصف الرابع': ['A'],
  };

  String _selectedGrade = 'الصف الثالث';
  String _selectedSection = 'A';

  List<Map<String, dynamic>> get _visibleNotes => _sentNotes
      .where((note) =>
          note['grade'] == _selectedGrade && note['section'] == _selectedSection)
      .toList();
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _sentNotes = [
    {
      'content': 'يرجى مراجعة واجب الرياضيات المرسل عبر التطبيق قبل يوم الخميس.',
      'recipient': 'شعبة كاملة',
      'date': '15 مايو 2024',
      'status': 'مرسل',
      'color': AppColors.success,
      'icon': Icons.send,
      'readCount': 18,
      'totalCount': 20,
    },
    {
      'content': 'تم تأجيل اختبار العلوم إلى الأسبوع المقبل بسبب الظروف الجوية.',
      'recipient': 'الصف كامل',
      'date': '12 مايو 2024',
      'status': 'مرسل',
      'color': AppColors.success,
      'icon': Icons.send,
      'readCount': 22,
      'totalCount': 24,
    },
    {
      'content': 'يرجى إحضار الكتب المدرسية المطلوبة لدرس اليوم.',
      'recipient': 'طالب واحد',
      'date': '10 مايو 2024',
      'status': 'مقروء',
      'color': AppColors.info,
      'icon': Icons.done_all,
      'readCount': 1,
      'totalCount': 1,
      'grade': 'الصف الأول',
      'section': 'B',
    },
  ];

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendNote() {
    if (_noteController.text.isEmpty) return;

    final newNote = {
      'content': _noteController.text,
      'recipient': _recipient,
      'date': 'الآن',
      'status': 'مرسل',
      'color': AppColors.success,
      'icon': Icons.send,
      'readCount': 0,
      'totalCount': _recipient == 'طالب واحد' ? 1 : _recipient == 'شعبة كاملة' ? 20 : 24,
      'grade': _selectedGrade,
      'section': _selectedSection,
    };

    setState(() {
      _sentNotes.insert(0, newNote);
      _noteController.clear();
      _showCompose = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال الملاحظة بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظات للأهل',
      currentIndex: 0,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildClassSectionSelectors(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader(
                              title: 'ملاحظات للأهل',
                              subtitle: 'تواصل فعال مع أولياء الأمور',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.onPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.message,
                                    color: AppColors.onPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_visibleNotes.length} مرسلة',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Quick Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('هذا الأسبوع', '8', AppColors.success),
                            _buildStatCard('معدل القراءة', '85%', AppColors.primary),
                            _buildStatCard('ردود', '12', AppColors.info),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Compose Button
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: PrimaryButton(
                      label: _showCompose ? 'إلغاء' : 'كتابة ملاحظة جديدة',
                      onPressed: () => setState(() => _showCompose = !_showCompose),
                      icon: _showCompose ? Icons.close : Icons.add,
                    ),
                  ),
                  if (_showCompose)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.onSurface.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إنشاء ملاحظة جديدة',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Recipients
                              Wrap(
                                spacing: AppSpacing.sm,
                                children: [
                                  _RecipientChip(
                                    label: 'طالب واحد',
                                    selected: _recipient == 'طالب واحد',
                                    onTap: () => setState(() => _recipient = 'طالب واحد'),
                                  ),
                                  _RecipientChip(
                                    label: 'شعبة كاملة',
                                    selected: _recipient == 'شعبة كاملة',
                                    onTap: () => setState(() => _recipient = 'شعبة كاملة'),
                                  ),
                                  _RecipientChip(
                                    label: 'الصف كامل',
                                    selected: _recipient == 'الصف كامل',
                                    onTap: () => setState(() => _recipient = 'الصف كامل'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Message
                              TextField(
                                controller: _noteController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: 'نص الملاحظة',
                                  hintText: 'اكتب هنا ملاحظة قصيرة أو تعليمات للأهل',
                                  alignLabelWithHint: true,
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Options
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.attach_file),
                                      label: const Text('إرفاق ملف'),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  IconButton(
                                    onPressed: () => setState(() => _scheduled = !_scheduled),
                                    icon: Icon(
                                      _scheduled ? Icons.schedule : Icons.schedule_outlined,
                                      color: _scheduled ? AppColors.primary : AppColors.onSurface.withOpacity(0.6),
                                    ),
                                    tooltip: 'جدولة الإرسال',
                                  ),
                                ],
                              ),
                              if (_scheduled) ...[
                                const SizedBox(height: AppSpacing.sm),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'وقت الإرسال',
                                    hintText: 'اختر التاريخ والوقت',
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    // TODO: Implement date picker
                                  },
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              PrimaryButton(
                                label: 'إرسال الملاحظة',
                                onPressed: _sendNote,
                                icon: Icons.send,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = _visibleNotes[index];
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
                            child: _NoteCard(note: note),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _visibleNotes.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.md),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSectionSelectors() {
    final sections = _classSections[_selectedGrade] ?? ['A'];
    final currentSection = sections.contains(_selectedSection) ? _selectedSection : sections.first;
    if (_selectedSection != currentSection) {
      _selectedSection = currentSection;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Map<String, dynamic> note;

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
              note['color'].withOpacity(0.1),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: note['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      note['icon'],
                      color: note['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إلى: ${note['recipient']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          note['date'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: note['status'],
                    color: note['color'],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                note['content'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: AppColors.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${note['readCount']}/${note['totalCount']} مقروءة',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.onSurface.withOpacity(0.6),
                    ),
                    tooltip: 'خيارات إضافية',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipientChip extends StatelessWidget {
  const _RecipientChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
