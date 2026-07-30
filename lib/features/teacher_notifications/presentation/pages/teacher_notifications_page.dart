import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/teacher_notification_item.dart';
import '../cubit/teacher_notifications_cubit.dart';
import '../cubit/teacher_notifications_state.dart';

class TeacherNotificationsPage extends StatefulWidget {
  const TeacherNotificationsPage({super.key});

  @override
  State<TeacherNotificationsPage> createState() =>
      _TeacherNotificationsPageState();
}

class _TeacherNotificationsPageState extends State<TeacherNotificationsPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthCubit>().sessionToken;
      context.read<TeacherNotificationsCubit>().loadNotifications(token);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherNotificationsCubit, TeacherNotificationsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          showAppFeedback(context, message: state.errorMessage!, isError: true);
          context.read<TeacherNotificationsCubit>().clearTransientMessages();
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          showAppFeedback(
            context,
            message: state.successMessage!,
            isError: false,
          );
          context.read<TeacherNotificationsCubit>().clearTransientMessages();
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'الإشعارات',
          currentIndex: 4,
          unreadNotificationsCount: state.unreadCount,
          actions: [
            IconButton(
              onPressed: state.isLoading
                  ? null
                  : () => context
                        .read<TeacherNotificationsCubit>()
                        .loadNotifications(
                          context.read<AuthCubit>().sessionToken,
                        ),
              icon: const Icon(Icons.refresh),
            ),
          ],
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.onPrimary.withValues(
                                alpha: 0.16,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.onPrimary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ' إشعاراتك ',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppColors.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'تابع التنبيهات الواردة من الإدارة أو أولياء الأمور.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onPrimary.withValues(
                                          alpha: 0.9,
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
                          _MiniMetric(
                            icon: Icons.mark_email_unread_outlined,
                            label: 'غير مقروء',
                            value: state.unreadCount.toString(),
                          ),
                          _MiniMetric(
                            icon: Icons.mark_email_read_outlined,
                            label: 'مقروء',
                            value: state.readCount.toString(),
                          ),
                          _MiniMetric(
                            icon: Icons.delete_outline,
                            label: 'الإجمالي',
                            value: state.notifications.length.toString(),
                          ),
                        ],
                      ),
                      if (state.unreadCount > 0) ...[
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: state.isMarkingAllRead
                                ? 'جارٍ التحديث...'
                                : 'تعليم الكل كمقروء',
                            icon: Icons.done_all,
                            onPressed: state.isMarkingAllRead
                                ? () {}
                                : () => context
                                      .read<TeacherNotificationsCubit>()
                                      .markAllAsRead(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) => context
                        .read<TeacherNotificationsCubit>()
                        .setSelectedTab(index),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.onPrimary,
                    unselectedLabelColor: AppColors.onSurface.withValues(
                      alpha: 0.7,
                    ),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    tabs: [
                      Tab(
                        icon: Badge(
                          label: Text('${state.unreadCount}'),
                          child: const Icon(Icons.mark_email_unread_outlined),
                        ),
                        text: 'غير مقروءة',
                      ),
                      Tab(
                        icon: Badge(
                          label: Text('${state.readCount}'),
                          child: const Icon(Icons.mark_email_read_outlined),
                        ),
                        text: 'مقروءة',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _NotificationsList(
                        isLoading: state.isLoading,
                        notifications: state.unreadNotifications,
                        emptyTitle: 'لا توجد إشعارات غير مقروءة',
                        emptySubtitle: 'كل شيء يبدو تحت السيطرة الآن.',
                        onRefresh: () => context
                            .read<TeacherNotificationsCubit>()
                            .loadNotifications(
                              context.read<AuthCubit>().sessionToken,
                            ),
                        onMarkRead: (item) => context
                            .read<TeacherNotificationsCubit>()
                            .markAsRead(item.id),
                        onDelete: (item) => context
                            .read<TeacherNotificationsCubit>()
                            .deleteNotification(item.id),
                        isUnreadTab: true,
                      ),
                      _NotificationsList(
                        isLoading: state.isLoading,
                        notifications: state.readNotifications,
                        emptyTitle: 'لا توجد إشعارات مقروءة',
                        emptySubtitle: 'ستظهر هنا الإشعارات التي تمت مراجعتها.',
                        onRefresh: () => context
                            .read<TeacherNotificationsCubit>()
                            .loadNotifications(
                              context.read<AuthCubit>().sessionToken,
                            ),
                        onMarkRead: (item) => context
                            .read<TeacherNotificationsCubit>()
                            .markAsRead(item.id),
                        onDelete: (item) => context
                            .read<TeacherNotificationsCubit>()
                            .deleteNotification(item.id),
                        isUnreadTab: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.onPrimary, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.isLoading,
    required this.notifications,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onMarkRead,
    required this.onDelete,
    required this.isUnreadTab,
  });

  final bool isLoading;
  final List<TeacherNotificationItem> notifications;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final ValueChanged<TeacherNotificationItem> onMarkRead;
  final ValueChanged<TeacherNotificationItem> onDelete;
  final bool isUnreadTab;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        itemCount: notifications.isEmpty ? 1 : notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (notifications.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 72),
              child: _EmptyNotificationsState(
                title: emptyTitle,
                subtitle: emptySubtitle,
              ),
            );
          }

          final item = notifications[index];
          return _NotificationCard(
            item: item,
            isUnreadTab: isUnreadTab,
            onMarkRead: () => onMarkRead(item),
            onDelete: () => onDelete(item),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.isUnreadTab,
    required this.onMarkRead,
    required this.onDelete,
  });

  final TeacherNotificationItem item;
  final bool isUnreadTab;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = item.isRead ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.isRead
                      ? Icons.mark_email_read_outlined
                      : Icons.mark_email_unread_outlined,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        StatusBadge(
                          label: item.isRead ? 'مقروء' : 'غير مقروء',
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.audienceLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.shortBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.76),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: AppColors.onSurface.withValues(alpha: 0.56),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.createdAt,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
              ),
              if (!item.isRead || isUnreadTab)
                IconButton(
                  tooltip: 'تعليم كمقروء',
                  onPressed: onMarkRead,
                  icon: const Icon(Icons.done_all),
                  color: AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
