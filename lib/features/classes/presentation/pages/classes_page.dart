import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/empty_state_card.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _classes = [
    {
      'title': 'الصف الثالث - الرياضيات',
      'subtitle': '24 طالبًا • شعبة A',
      'status': 'نشط',
      'statusColor': AppColors.primary,
      'icon': Icons.calculate,
      'color': AppColors.primary,
      'students': 24,
      'grade': 'الثالث',
      'subject': 'الرياضيات',
    },
    {
      'title': 'الصف الثاني - العلوم',
      'subtitle': '20 طالبًا • شعبة B',
      'status': 'مكتمل',
      'statusColor': AppColors.success,
      'icon': Icons.science,
      'color': AppColors.success,
      'students': 20,
      'grade': 'الثاني',
      'subject': 'العلوم',
    },
    {
      'title': 'الصف الرابع - اللغة العربية',
      'subtitle': '18 طالبًا • شعبة A',
      'status': 'مفتوح',
      'statusColor': AppColors.info,
      'icon': Icons.language,
      'color': AppColors.info,
      'students': 18,
      'grade': 'الرابع',
      'subject': 'اللغة العربية',
    },
    {
      'title': 'الصف الأول - الإنجليزية',
      'subtitle': '22 طالبًا • شعبة C',
      'status': 'نشط',
      'statusColor': AppColors.primary,
      'icon': Icons.translate,
      'color': AppColors.primary,
      'students': 22,
      'grade': 'الأول',
      'subject': 'الإنجليزية',
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredClasses {
    return _classes.where((classItem) {
      final matchesSearch = classItem['title'].toString().toLowerCase().contains(
        _searchController.text.toLowerCase(),
      ) || classItem['subject'].toString().toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );

      final matchesFilter = _selectedFilter == 'الكل' || classItem['status'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الصفوف والشعب',
      currentIndex: 1,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
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
                  const SectionHeader(
                    title: 'ابحث عن الصف أو الشعبة',
                    subtitle: 'استخدم الفلتر لإظهار النتائج الأسرع',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'بحث باسم المادة أو الشعبة',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('الكل'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('نشط'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('مكتمل'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('مفتوح'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Classes List
            Expanded(
              child: _filteredClasses.isEmpty
                ? const EmptyStateCard(
                    icon: Icons.class_,
                    title: 'لا توجد صفوف',
                    subtitle: 'لم يتم العثور على صفوف تطابق معايير البحث',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _filteredClasses.length,
                    itemBuilder: (context, index) {
                      final classItem = _filteredClasses[index];
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
                              child: _buildClassCard(classItem),
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'الكل';
        });
      },
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classItem) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              classItem['color'].withOpacity(0.1),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to class details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فتح تفاصيل ${classItem['title']}'),
                backgroundColor: classItem['color'],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Class Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: classItem['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    classItem['icon'],
                    color: classItem['color'],
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Class Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classItem['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        classItem['subtitle'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: AppColors.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${classItem['students']} طالب',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                StatusBadge(
                  label: classItem['status'],
                  color: classItem['statusColor'],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
