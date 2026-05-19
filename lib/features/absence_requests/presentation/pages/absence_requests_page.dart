import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/primary_button.dart';

class AbsenceRequestsPage extends StatefulWidget {
  const AbsenceRequestsPage({super.key});

  @override
  State<AbsenceRequestsPage> createState() => _AbsenceRequestsPageState();
}

class _AbsenceRequestsPageState extends State<AbsenceRequestsPage> with TickerProviderStateMixin {
  String _selectedFilter = 'الكل';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _requests = [
    {
      'studentName': 'سلمان محمد',
      'className': 'الصف الثالث - شعبة A',
      'date': '12 مايو 2024',
      'reason': 'مرض مفاجئ، مع إرفاق تقرير طبي.',
      'statusLabel': 'قيد الانتظار',
      'statusColor': AppColors.warning,
      'icon': Icons.warning,
      'hasAttachment': true,
      'parentName': 'أ. محمد سالم',
      'parentPhone': '0912345678',
    },
    {
      'studentName': 'ندى العلي',
      'className': 'الصف الثاني - شعبة B',
      'date': '10 مايو 2024',
      'reason': 'زيارة عائلية مبررة.',
      'statusLabel': 'مقبول',
      'statusColor': AppColors.success,
      'icon': Icons.check_circle,
      'hasAttachment': false,
      'parentName': 'أ. علي العلي',
      'parentPhone': '0912345679',
    },
    {
      'studentName': 'ياسين خالد',
      'className': 'الصف الرابع - اللغة العربية',
      'date': '09 مايو 2024',
      'reason': 'أعراض إنفلونزا مع مستند طبي.',
      'statusLabel': 'مرفوض',
      'statusColor': AppColors.error,
      'icon': Icons.cancel,
      'hasAttachment': true,
      'parentName': 'أ. خالد ياسين',
      'parentPhone': '0912345680',
    },
    {
      'studentName': 'مريم أحمد',
      'className': 'الصف الأول - الإنجليزية',
      'date': '08 مايو 2024',
      'reason': 'موعد طبي ضروري.',
      'statusLabel': 'قيد الانتظار',
      'statusColor': AppColors.warning,
      'icon': Icons.warning,
      'hasAttachment': true,
      'parentName': 'أ. أحمد مريم',
      'parentPhone': '0912345681',
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

  List<Map<String, dynamic>> get _filteredRequests {
    if (_selectedFilter == 'الكل') return _requests;
    return _requests.where((r) => r['statusLabel'] == _selectedFilter).toList();
  }

  void _updateRequestStatus(int index, String newStatus, Color newColor, IconData newIcon) {
    setState(() {
      _filteredRequests[index]['statusLabel'] = newStatus;
      _filteredRequests[index]['statusColor'] = newColor;
      _filteredRequests[index]['icon'] = newIcon;
    });

    String message;
    switch (newStatus) {
      case 'مقبول':
        message = 'تم قبول طلب التبرير';
        break;
      case 'مرفوض':
        message = 'تم رفض طلب التبرير';
        break;
      default:
        message = 'تم تحديث حالة الطلب';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: newColor,
      ),
    );
  }

  int get _pendingCount => _requests.where((r) => r['statusLabel'] == 'قيد الانتظار').length;
  int get _approvedCount => _requests.where((r) => r['statusLabel'] == 'مقبول').length;
  int get _rejectedCount => _requests.where((r) => r['statusLabel'] == 'مرفوض').length;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'طلبات تبرير الغياب',
      currentIndex: 0,
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
                    title: 'طلبات تبرير الغياب',
                    subtitle: 'راجع الطلبات واتخذ القرار بسرعة',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('معلقة', _pendingCount.toString(), AppColors.warning),
                      _buildStatCard('مقبولة', _approvedCount.toString(), AppColors.success),
                      _buildStatCard('مرفوضة', _rejectedCount.toString(), AppColors.error),
                    ],
                  ),
                ],
              ),
            ),
            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('الكل'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('قيد الانتظار'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('مقبول'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('مرفوض'),
                  ],
                ),
              ),
            ),
            // Requests List
            Expanded(
              child: _filteredRequests.isEmpty
                ? const Center(
                    child: Text('لا توجد طلبات في هذه الفئة'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = _filteredRequests[index];
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
                              child: _RequestCard(
                                request: request,
                                onStatusChanged: (status, color, icon) =>
                                  _updateRequestStatus(index, status, color, icon),
                              ),
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

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.1),
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
              color: AppColors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
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
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({
    required this.request,
    required this.onStatusChanged,
  });

  final Map<String, dynamic> request;
  final Function(String, Color, IconData) onStatusChanged;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> with TickerProviderStateMixin {
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
    final isPending = widget.request['statusLabel'] == 'قيد الانتظار';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.request['statusColor'].withValues(alpha: 0.1),
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
                    // Student Avatar
                    Hero(
                      tag: 'student-${widget.request['studentName']}',
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: widget.request['statusColor'].withValues(alpha: 0.1),
                        child: Text(
                            (widget.request['studentName'] as String).isNotEmpty
                              ? (widget.request['studentName'] as String).substring(0, 1)
                              : '',
                          style: TextStyle(
                            color: widget.request['statusColor'],
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
                            widget.request['studentName'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.request['className'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(
                      label: widget.request['statusLabel'],
                      color: widget.request['statusColor'],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Date and Reason
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.request['date'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (widget.request['hasAttachment']) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.request['reason'],
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),
                // Expanded Details
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ولي الأمر: ${widget.request['parentName']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: AppColors.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.request['parentPhone'],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (isPending) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => widget.onStatusChanged(
                                  'مرفوض',
                                  AppColors.error,
                                  Icons.cancel,
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text('رفض'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: PrimaryButton(
                                label: 'قبول',
                                onPressed: () => widget.onStatusChanged(
                                  'مقبول',
                                  AppColors.success,
                                  Icons.check_circle,
                                ),
                                icon: Icons.check,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: AppColors.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'اضغط للتصغير',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
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
