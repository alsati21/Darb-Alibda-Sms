import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/route_names.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/dashboard_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/teacher_dashboard_summary.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TeacherDashboardSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    _loadDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
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
      final repository = RepositoryProvider.of<DashboardRepository>(context);
      final response = await repository.fetchTeacherDashboard(token);
      if (!mounted) return;
      setState(() {
        _summary = response.data;
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

  String _getTeacherDisplayName(AuthState state) {
    if (state is AuthSuccess) {
      final payload = state.payload;
      final userMap = _extractUserMap(payload);
      final name = _extractDisplayName(userMap);
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }
    return 'المعلم';
  }

  Map<String, dynamic>? _extractUserMap(dynamic source) {
    if (source is Map) {
      final map = Map<String, dynamic>.from(source);
      final user = map['user'];
      if (user is Map) {
        return Map<String, dynamic>.from(user);
      }
      final data = map['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return map;
    }
    return null;
  }

  String? _extractDisplayName(Map<String, dynamic>? source) {
    if (source == null) {
      return null;
    }

    String? read(String key) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      return null;
    }

    return read('name') ??
        read('full_name') ??
        read('teacher_name') ??
        read('display_name') ??
        (() {
          final firstName = read('first_name');
          final lastName = read('last_name');
          if (firstName != null || lastName != null) {
            return '${firstName ?? ''} ${lastName ?? ''}'.trim();
          }
          return null;
        })();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final teacherName = _getTeacherDisplayName(authState);

    return AppScaffold(
      title: 'الرئيسية',
      currentIndex: 0,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'teacher-avatar',
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.onPrimary.withValues(alpha: 0.18),
                              child: const Icon(Icons.person, color: AppColors.onPrimary, size: 34),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أهلاً بك يا $teacherName',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: AppColors.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'لوحة تحكم المعلم الرسمية لمتابعة الصفوف والمهام.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.onPrimary.withValues(alpha: 0.85),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _MiniStatusChip(
                            icon: Icons.group,
                            label: _summary != null ? '${_summary!.presentStudentsCount} طالباً' : 'جارٍ التحميل...',
                            color: AppColors.primary,
                          ),
                          _MiniStatusChip(
                            icon: Icons.check_circle,
                            label: _summary != null ? '${_summary!.attendancePercentage.toStringAsFixed(0)}% حضور' : 'جارٍ التحميل...',
                            color: AppColors.success,
                          ),
                          _MiniStatusChip(
                            icon: Icons.pending_actions,
                            label: _summary != null ? '${_summary!.pendingTasksCount} مهام' : 'جارٍ التحميل...',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'ملخص الأداء',
                  subtitle: 'أهم المقاييس الحالية من الخادم',
                ),
                if (_isLoading)
                  const _DashboardSkeleton()
                else if (_errorMessage != null)
                  _DashboardErrorState(
                    message: _errorMessage!,
                    onRetry: _loadDashboard,
                  )
                else if (_summary != null)
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.05,
                    children: [
                      DashboardCard(
                        title: 'الطلاب الحاضرون اليوم',
                        value: _summary!.presentStudentsCount.toString(),
                        label: 'عدد الحضور الحالي',
                        color: AppColors.primary,
                        icon: Icons.group,
                      ),
                      DashboardCard(
                        title: 'الطلاب النشطون',
                        value: _summary!.activeStudentsCount.toString(),
                        label: 'الطلاب النشطون حالياً',
                        color: AppColors.info,
                        icon: Icons.verified_user,
                      ),
                      _AttendanceProgressCard(
                        title: 'نسبة الحضور',
                        value: '${_summary!.attendancePercentage.toStringAsFixed(0)}%',
                        label: 'النسبة الحالية',
                        color: AppColors.success,
                        icon: Icons.percent,
                        percentage: _summary!.attendancePercentage,
                      ),
                      DashboardCard(
                        title: 'طلبات تبرير الغياب',
                        value: _summary!.pendingAbsenceJustificationRequestsCount.toString(),
                        label: 'طلب معلّق',
                        color: AppColors.warning,
                        icon: Icons.assignment_late,
                      ),
                      DashboardCard(
                        title: 'المهام المعلقة',
                        value: _summary!.pendingTasksCount.toString(),
                        label: 'مهام تحتاج متابعة',
                        color: AppColors.secondary,
                        icon: Icons.task_alt,
                      ),
                      DashboardCard(
                        title: 'الملاحظات غير المقروءة',
                        value: _summary!.unreadNotesCount.toString(),
                        label: 'ملاحظات جديدة',
                        color: AppColors.primaryContainer,
                        icon: Icons.mark_chat_unread,
                      ),
                      DashboardCard(
                        title: 'إعلانات اليوم',
                        value: _summary!.todayAnnouncementsCount.toString(),
                        label: 'إعلانات جديدة',
                        color: AppColors.secondaryContainer,
                        icon: Icons.campaign,
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'اختصارات سريعة'),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ActionTile(
                      icon: Icons.how_to_reg,
                      label: 'تسجيل الحضور',
                      onTap: () => Navigator.pushNamed(context, RouteNames.attendance),
                      color: AppColors.primaryContainer,
                    ),
                    ActionTile(
                      icon: Icons.edit_note,
                      label: 'إدارة العلامات',
                      onTap: () => Navigator.pushNamed(context, RouteNames.grades),
                      color: AppColors.secondaryContainer,
                    ),
                    ActionTile(
                      icon: Icons.assignment,
                      label: 'طلبات الغياب',
                      onTap: () => Navigator.pushNamed(context, RouteNames.absenceRequests),
                      color: AppColors.surfaceVariant,
                    ),
                    ActionTile(
                      icon: Icons.campaign,
                      label: 'الأخبار',
                      onTap: () => Navigator.pushNamed(context, RouteNames.news),
                      color: AppColors.secondaryContainer,
                    ),
                    ActionTile(
                      icon: Icons.person,
                      label: 'الملف الشخصي',
                      onTap: () => Navigator.pushNamed(context, RouteNames.profile),
                      color: AppColors.primaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: List.generate(6, (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: AppSpacing.sm),
            Container(height: 14, width: 90, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Container(height: 18, width: 70, color: AppColors.border),
            const SizedBox(height: AppSpacing.xs),
            Container(height: 12, width: 100, color: AppColors.border),
          ],
        ),
      )),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 36, color: AppColors.warning),
            const SizedBox(height: AppSpacing.sm),
            Text('تعذر تحميل البيانات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceProgressCard extends StatelessWidget {
  const _AttendanceProgressCard({
    required this.title,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    required this.percentage,
  });

  final String title;
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final normalized = (percentage.clamp(0.0, 100.0) / 100.0).toDouble();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.16),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MiniStatusChip extends StatelessWidget {
  const _MiniStatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
