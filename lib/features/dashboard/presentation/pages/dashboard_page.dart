import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/route_names.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
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
                        color: AppColors.primary.withValues(alpha: 0.18),
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
                              backgroundColor: AppColors.onPrimary.withValues(
                                alpha: 0.18,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.onPrimary,
                                size: 34,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أهلاً بك يا $teacherName',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'لوحة تحكم المعلم الرسمية لمتابعة الصفوف والمهام.',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.onPrimary.withValues(
                                          alpha: 0.85,
                                        ),
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
                            icon: Icons.auto_awesome,
                            label: 'جاهز للدرس',
                            color: AppColors.primary,
                          ),
                          _MiniStatusChip(
                            icon: Icons.check_circle_outline,
                            label: 'منظم',
                            color: AppColors.success,
                          ),
                          _MiniStatusChip(
                            icon: Icons.lightbulb_outline_rounded,
                            label: 'متحفز',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'ملخص اليوم',
                  subtitle: 'نظرة سريعة قبل أن تبدأ',
                ),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.check_circle_rounded,
                                title: 'ترتيب اليوم',
                                subtitle: 'مراجعة الصفوف والمهام',
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.school_rounded,
                                title: 'الجهوزية',
                                subtitle: 'درس منظم ومهام جاهزة',
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.favorite_rounded,
                                title: 'التواصل',
                                subtitle: 'ملاحظات أولياء الأمور',
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.format_quote_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'النجاح يبدأ من التنظيم، ومن يوم صغير تبدأ مدرسة عظيمة.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onSurface.withValues(
                                          alpha: 0.78,
                                        ),
                                        height: 1.7,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'اختصارات سريعة'),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    // ActionTile(
                    //   icon: Icons.assignment_late_outlined,
                    //   label: 'طلبات تبرير الغياب',
                    //   onTap: () =>
                    //       Navigator.pushNamed(context, RouteNames.absenceRequests),
                    //   color: AppColors.primaryContainer,
                    // ),
                    ActionTile(
                      icon: Icons.edit_note,
                      label: 'إدارة العلامات',
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.grades),
                      color: AppColors.secondaryContainer,
                    ),
                    ActionTile(
                      icon: Icons.feedback_outlined,
                      label: 'الاقتراحات',
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.feedback),
                      color: AppColors.surfaceVariant,
                    ),
                    ActionTile(
                      icon: Icons.report_gmailerrorred_outlined,
                      label: 'الشكاوى',
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.complaints),
                      color: AppColors.surfaceVariant,
                    ),
                    ActionTile(
                      icon: Icons.mark_chat_unread,
                      label: 'ملاحظات الأهل',
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.notes),
                      color: AppColors.primaryContainer,
                    ),
                    ActionTile(
                      icon: Icons.person,
                      label: 'الملف الشخصي',
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.profile),
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

class _DecorativeFilterChip extends StatelessWidget {
  const _DecorativeFilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.border.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected
              ? AppColors.onPrimary
              : AppColors.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
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
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
