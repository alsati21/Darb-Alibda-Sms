import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/absence_justification_request.dart';
import '../../data/repositories/absence_requests_repository.dart';

class AbsenceRequestsPage extends StatefulWidget {
  const AbsenceRequestsPage({super.key});

  @override
  State<AbsenceRequestsPage> createState() => _AbsenceRequestsPageState();
}

class _AbsenceRequestsPageState extends State<AbsenceRequestsPage> with TickerProviderStateMixin {
  String _selectedFilter = 'الكل';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<AbsenceJustificationRequest> _requests = <AbsenceJustificationRequest>[];
  bool _isLoading = true;
  String? _errorMessage;

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
    _loadRequests();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد الانتظار';
    }
  }

  List<AbsenceJustificationRequest> get _filteredRequests {
    if (_selectedFilter == 'الكل') return _requests;
    return _requests.where((request) => _statusLabel(request.status) == _selectedFilter).toList();
  }

  Future<void> _loadRequests() async {
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
      final repository = RepositoryProvider.of<AbsenceRequestsRepository>(context, listen: false);
      final requests = await repository.fetchRequests(token);
      if (!mounted) return;
      setState(() {
        _requests = requests;
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

  Future<void> _updateRequestStatus(AbsenceJustificationRequest request, String newStatus) async {
    final token = context.read<AuthCubit>().sessionToken;
    if (token == null || token.isEmpty) {
      showAppFeedback(context, message: 'لم يتم العثور على جلسة نشطة', isError: true);
      return;
    }

    try {
      final repository = RepositoryProvider.of<AbsenceRequestsRepository>(context, listen: false);
      await repository.updateRequest(token: token, requestId: request.id, status: newStatus);
      if (!mounted) return;
      setState(() {
        final index = _requests.indexWhere((item) => item.id == request.id);
        if (index >= 0) {
          _requests[index] = AbsenceJustificationRequest(
            id: request.id,
            studentName: request.studentName,
            className: request.className,
            absenceDate: request.absenceDate,
            reason: request.reason,
            status: newStatus,
            reviewNote: request.reviewNote,
            parentName: request.parentName,
            parentPhone: request.parentPhone,
            hasAttachment: request.hasAttachment,
            createdAt: request.createdAt,
          );
        }
      });
      showAppFeedback(
        context,
        message: newStatus == 'approved' ? 'تم قبول طلب التبرير' : 'تم رفض طلب التبرير',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      showAppFeedback(context, message: error.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _deleteRequest(AbsenceJustificationRequest request) async {
    final token = context.read<AuthCubit>().sessionToken;
    if (token == null || token.isEmpty) {
      showAppFeedback(context, message: 'لم يتم العثور على جلسة نشطة', isError: true);
      return;
    }

    try {
      final repository = RepositoryProvider.of<AbsenceRequestsRepository>(context, listen: false);
      await repository.deleteRequest(token: token, requestId: request.id);
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((item) => item.id == request.id);
      });
      showAppFeedback(context, message: 'تم حذف طلب التبرير', isError: false);
    } catch (error) {
      if (!mounted) return;
      showAppFeedback(context, message: error.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  int get _pendingCount => _requests.where((request) => request.status == 'pending').length;
  int get _approvedCount => _requests.where((request) => request.status == 'approved').length;
  int get _rejectedCount => _requests.where((request) => request.status == 'rejected').length;

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 36, color: AppColors.warning),
                                const SizedBox(height: AppSpacing.sm),
                                Text(_errorMessage!, textAlign: TextAlign.center),
                                const SizedBox(height: AppSpacing.sm),
                                ElevatedButton.icon(
                                  onPressed: _loadRequests,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _filteredRequests.isEmpty
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
                                          onStatusChanged: (status) => _updateRequestStatus(request, status),
                                          onDelete: () => _deleteRequest(request),
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
    required this.onDelete,
  });

  final AbsenceJustificationRequest request;
  final Function(String) onStatusChanged;
  final VoidCallback onDelete;

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

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد الانتظار';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.request.status == 'pending';
    final statusColor = _statusColor(widget.request.status);
    final statusLabel = _statusLabel(widget.request.status);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withValues(alpha: 0.1),
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
                      tag: 'student-${widget.request.id}',
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        child: Text(
                          widget.request.studentName.isNotEmpty ? widget.request.studentName.substring(0, 1) : '',
                          style: TextStyle(
                            color: statusColor,
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
                            widget.request.studentName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.request.className,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(
                      label: statusLabel,
                      color: statusColor,
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
                      widget.request.absenceDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (widget.request.hasAttachment) ...[
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
                  widget.request.reason,
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
                            'ولي الأمر: ${widget.request.parentName}',
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
                            widget.request.parentPhone,
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
                                onPressed: () => widget.onStatusChanged('rejected'),
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
                                onPressed: () => widget.onStatusChanged('approved'),
                                icon: Icons.check,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onDelete,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('حذف'),
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
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                    if (_isExpanded) {
                                      _expandController.forward();
                                    } else {
                                      _expandController.reverse();
                                    }
                                  });
                                },
                                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                                label: Text(_isExpanded ? 'تصغير' : 'التفاصيل'),
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
