import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/primary_button.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  String _selectedFilter = 'الكل';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _news = [
    {
      'title': 'اجتماع أولياء الأمور يوم الخميس',
      'date': '13 مايو 2024',
      'content': 'تم تحديد موعد اجتماع أولياء الأمور لمناقشة نتائج الفصل الحالي وخطة العام الدراسي المقبل. سيتم مناقشة التحديات والإنجازات وكيفية دعم الطلاب في رحلتهم التعليمية.',
      'badgeLabel': 'هام',
      'badgeColor': AppColors.error,
      'icon': Icons.people,
      'isRead': false,
      'category': 'اجتماعات',
    },
    {
      'title': 'بدء اختبار الرياضيات الأسبوع المقبل',
      'date': '11 مايو 2024',
      'content': 'يرجى تحضير خطة مراجعة شاملة للطلاب وتوزيع الأسئلة التدريبية. سيتم التركيز على المواضيع الأساسية والتطبيقات العملية لضمان فهم الطلاب الكامل.',
      'badgeLabel': 'تنبيه',
      'badgeColor': AppColors.warning,
      'icon': Icons.calculate,
      'isRead': true,
      'category': 'امتحانات',
    },
    {
      'title': 'تحديث النظام التعليمي',
      'date': '09 مايو 2024',
      'content': 'أضيف قسم جديد لطلبات تبرير الغياب وتحسين واجهة المستخدم. كما تم تحسين أداء التطبيق وإضافة ميزات جديدة لتسهيل عمل المعلمين.',
      'badgeLabel': 'معلومات',
      'badgeColor': AppColors.info,
      'icon': Icons.system_update,
      'isRead': true,
      'category': 'تحديثات',
    },
    {
      'title': 'فعالية رياضية نهاية الأسبوع',
      'date': '08 مايو 2024',
      'content': 'دعوة للمشاركة في الفعالية الرياضية الأسبوعية. سيتم تنظيم مسابقات في كرة القدم والسلة وألعاب القوى لتشجيع النشاط البدني بين الطلاب.',
      'badgeLabel': 'فعالية',
      'badgeColor': AppColors.success,
      'icon': Icons.sports_soccer,
      'isRead': false,
      'category': 'أنشطة',
    },
    {
      'title': 'ورشة عمل تطوير مهارات التدريس',
      'date': '05 مايو 2024',
      'content': 'سيتم عقد ورشة عمل لتطوير مهارات التدريس الحديثة. ستشمل الورشة استخدام التكنولوجيا في التعليم واستراتيجيات تفاعلية جديدة.',
      'badgeLabel': 'تدريب',
      'badgeColor': AppColors.primary,
      'icon': Icons.school,
      'isRead': true,
      'category': 'تدريب',
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
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNews {
    if (_selectedFilter == 'الكل') return _news;
    if (_selectedFilter == 'غير مقروءة') return _news.where((n) => !n['isRead']).toList();
    return _news.where((n) => n['badgeLabel'] == _selectedFilter).toList();
  }

  void _markAsRead(int index) {
    setState(() {
      _filteredNews[index]['isRead'] = true;
    });
  }

  int get _unreadCount => _news.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الأخبار والإعلانات',
      currentIndex: 0,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionHeader(
                        title: 'آخر الأخبار',
                        subtitle: 'الإشعارات الرسمية والتنبيهات المهمة',

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
                              Icons.notifications_none,
                              color: AppColors.onPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_unreadCount غير مقروءة',
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
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('الكل'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('غير مقروءة'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('هام'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('تنبيه'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('معلومات'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // News List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _filteredNews.length,
                itemBuilder: (context, index) {
                  final newsItem = _filteredNews[index];
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
                          child: _NewsCard(
                            news: newsItem,
                            onMarkAsRead: () => _markAsRead(index),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Mark All as Read Button
            if (_unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.border.withOpacity(0.3)),
                  ),
                ),
                child: PrimaryButton(
                  label: 'تحديد الكل كمقروء',
                  onPressed: () {
                    setState(() {
                      for (var news in _news) {
                        news['isRead'] = true;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديد جميع الأخبار كمقروءة'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: Icons.done_all,
                ),
              ),
          ],
        ),
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
        _animationController.reset();
        _animationController.forward();
      },
      backgroundColor: AppColors.onPrimary.withOpacity(0.1),
      selectedColor: AppColors.onPrimary.withOpacity(0.3),
      checkmarkColor: AppColors.onPrimary,
      labelStyle: TextStyle(
        color: AppColors.onPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _NewsCard extends StatefulWidget {
  const _NewsCard({
    required this.news,
    required this.onMarkAsRead,
  });

  final Map<String, dynamic> news;
  final VoidCallback onMarkAsRead;

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRead = widget.news['isRead'] as bool;
    return Card(
      elevation: isRead ? 1 : 4,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isRead ? AppColors.surface : widget.news['badgeColor'].withOpacity(0.1),
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
            setState(() {
              _isExpanded = !_isExpanded;
              if (_isExpanded) {
                _expandController.forward();
                if (!isRead) {
                  widget.onMarkAsRead();
                }
              } else {
                _expandController.reverse();
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.news['badgeColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.news['icon'],
                        color: widget.news['badgeColor'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Title and Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.news['title'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isRead ? AppColors.onSurface.withOpacity(0.7) : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Text(
                                widget.news['date'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isRead ? Colors.transparent : widget.news['badgeColor'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(
                      label: widget.news['badgeLabel'],
                      color: widget.news['badgeColor'],
                    ),
                  ],
                ),
                // Expanded Content
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.news['content'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'التصنيف: ${widget.news['category']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.onSurface.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ],
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
