import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/dashboard_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../core/navigation/route_names.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'teacher-avatar',
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.onPrimary.withOpacity(0.2),
                              child: const Icon(Icons.person, color: AppColors.onPrimary, size: 32),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'صباح الخير، أ. فاطمة',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'معلمة الرياضيات - الصف الثالث',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onPrimary.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'هذه لمحة سريعة عن يومك الدراسي ومهامك الحالية.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    DashboardCard(
                      title: 'عدد الطلاب اليوم',
                      value: '24',
                      label: 'الصفوف النشطة',
                      color: AppColors.primary,
                      icon: Icons.groups,
                    ),
                    DashboardCard(
                      title: 'مهام معلقة',
                      value: '5',
                      label: 'طلبات غياب وملاحظات',
                      color: AppColors.warning,
                      icon: Icons.pending_actions,
                    ),
                    DashboardCard(
                      title: 'الحضور اليوم',
                      value: '88%',
                      label: 'نسبة حضور الطلاب',
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                    DashboardCard(
                      title: 'إعلانات جديدة',
                      value: '3',
                      label: 'تنبيهات من الإدارة',
                      color: AppColors.info,
                      icon: Icons.campaign,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Today's Schedule
                const SectionHeader(
                  title: 'برنامج اليوم',
                  subtitle: 'مقدمة إلى المادة ووقت الحصة',
                  actionLabel: 'عرض الكل',
                ),
                Hero(
                  tag: 'schedule-card',
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.surface, AppColors.surfaceVariant],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الرياضيات - الصف الثالث',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '08:30 - 09:15',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'خطة اليوم: مراجعة الجبر، توزيع الواجب، فتح نقاش تفاعلي.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                StatusBadge(label: 'مؤكد', color: AppColors.success),
                                StatusBadge(label: 'نشط', color: AppColors.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Pending Requests
                const SectionHeader(
                  title: 'طلبات تبرير الغياب',
                  subtitle: 'انتظر الموافقة أو اطلع على التفاصيل',
                  actionLabel: 'عرض الطلبات',
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.warning.withOpacity(0.1),
                            child: Icon(Icons.warning, color: AppColors.warning),
                          ),
                          title: const Text('طلب جديد من ولي الأمر'),
                          subtitle: const Text('غياب يوم 12/5 - مرض'),
                          trailing: const StatusBadge(label: 'قيد الانتظار', color: AppColors.warning),
                          onTap: () => Navigator.pushNamed(context, RouteNames.absenceRequests),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.success.withOpacity(0.1),
                            child: Icon(Icons.check, color: AppColors.success),
                          ),
                          title: const Text('طلب مرفق من ولي أمر الطالب محمد'),
                          subtitle: const Text('غياب يوم 10/5 - عائلة'),
                          trailing: const StatusBadge(label: 'مقبول', color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Quick Actions
                const SectionHeader(title: 'اختصارات سريعة'),
                Row(
                  children: [
                    ActionTile(
                      icon: Icons.how_to_reg,
                      label: 'تسجيل الحضور',
                      onTap: () => Navigator.pushNamed(context, RouteNames.attendance),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ActionTile(
                      icon: Icons.edit_note,
                      label: 'إدارة العلامات',
                      onTap: () => Navigator.pushNamed(context, RouteNames.grades),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    ActionTile(
                      icon: Icons.campaign,
                      label: 'الأخبار',
                      onTap: () => Navigator.pushNamed(context, RouteNames.news),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ActionTile(
                      icon: Icons.mail_outline,
                      label: 'ملاحظات للأهل',
                      onTap: () => Navigator.pushNamed(context, RouteNames.notes),
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
