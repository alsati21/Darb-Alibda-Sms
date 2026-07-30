import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/route_names.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/teacher_complaint_item.dart';
import '../cubit/teacher_complaints_cubit.dart';
import '../cubit/teacher_complaints_state.dart';

class TeacherComplaintsPage extends StatefulWidget {
  const TeacherComplaintsPage({super.key});

  @override
  State<TeacherComplaintsPage> createState() => _TeacherComplaintsPageState();
}

class _TeacherComplaintsPageState extends State<TeacherComplaintsPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  late final TabController _tabController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(duration: const Duration(milliseconds: 850), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthCubit>().sessionToken;
      context.read<TeacherComplaintsCubit>().loadComplaints(token);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherComplaintsCubit, TeacherComplaintsState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage || previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          showAppFeedback(context, message: state.errorMessage!, isError: true);
          context.read<TeacherComplaintsCubit>().clearTransientMessages();
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          showAppFeedback(context, message: state.successMessage!, isError: false);
          _titleController.clear();
          _bodyController.clear();
          context.read<TeacherComplaintsCubit>().clearTransientMessages();
          _tabController.animateTo(1);
        }
      },
      builder: (context, state) {
        final total = state.complaints.length;
        final pendingCount = state.complaints.where((c) => c.isPending).length;
        final resolvedCount = state.complaints.where((c) => c.isResolved).length;

        return AppScaffold(
          title: 'الشكاوى',
          currentIndex:4,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                            decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(18)),
                            child: const Icon(Icons.report_gmailerrorred_outlined, color: AppColors.onPrimary, size: 30),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('بلغ عن مشكلة', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w800)),
                                const SizedBox(height: AppSpacing.xs),
                                Text('أرسل شكوى وسيتم متابعتها من قبل الإدارة.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.9))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
                        _MiniMetric(label: 'الإجمالي', value: total.toString(), icon: Icons.list_alt_outlined),
                        _MiniMetric(label: 'قيد المراجعة', value: pendingCount.toString(), icon: Icons.pending_actions),
                        _MiniMetric(label: 'تم الرد', value: resolvedCount.toString(), icon: Icons.verified_outlined),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.onPrimary,
                    unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.7),
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary])),
                    tabs: const [Tab(icon: Icon(Icons.create_outlined), text: 'إرسال شكوى'), Tab(icon: Icon(Icons.dynamic_feed_outlined), text: 'قائمة الشكاوى')],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: TabBarView(controller: _tabController, children: [_buildComposerTab(context, state), _buildListTab(context, state)]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposerTab(BuildContext context, TeacherComplaintsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border.withValues(alpha: 0.55)), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('اكتب شكواك', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.xs),
            Text('شاركنا المشكلة بتفصيل وسيتم اتخاذ الإجراء اللازم.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.72))),
            const SizedBox(height: AppSpacing.md),
            _buildComposerForm(context, state),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLastSentPreview(context, state),
      ]),
    );
  }

  Widget _buildComposerForm(BuildContext context, TeacherComplaintsState state) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextFormField(controller: _titleController, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: 'عنوان الشكوى', hintText: 'مثال: مشكلة في المختبر', prefixIcon: const Icon(Icons.short_text), filled: true, fillColor: AppColors.surfaceVariant, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)), validator: (value) {
          if (value == null || value.trim().isEmpty) return 'الرجاء إدخال عنوان مناسب';
          if (value.trim().length < 3) return 'العنوان قصير جداً';
          return null;
        }),
        const SizedBox(height: AppSpacing.md),
        TextFormField(controller: _bodyController, minLines: 5, maxLines: 8, textInputAction: TextInputAction.newline, decoration: InputDecoration(labelText: 'تفاصيل الشكوى', hintText: 'اشرح المشكلة بالتفصيل...', alignLabelWithHint: true, prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 70), child: Icon(Icons.notes_outlined)), filled: true, fillColor: AppColors.surfaceVariant, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)), validator: (value) {
          if (value == null || value.trim().isEmpty) return 'الرجاء كتابة التفاصيل';
          if (value.trim().length < 10) return 'أضف تفاصيل أكثر للشكوى';
          return null;
        }),
        const SizedBox(height: AppSpacing.md),
        Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(18)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.info_outline, color: AppColors.primary), const SizedBox(width: AppSpacing.sm), Expanded(child: Text('الشكوى ستُسجل وسيتم التواصل معك لاحقاً عند الحاجة.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.82))))])),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: state.isSubmitting ? 'جارٍ الإرسال...' : 'إرسال الشكوى', icon: state.isSubmitting ? Icons.hourglass_bottom : Icons.send_rounded, onPressed: state.isSubmitting ? () {} : () {
          if (!_formKey.currentState!.validate()) return;
          context.read<TeacherComplaintsCubit>().submitComplaint(title: _titleController.text.trim(), body: _bodyController.text.trim());
        }),
      ]),
    );
  }

  Widget _buildLastSentPreview(BuildContext context, TeacherComplaintsState state) {
    final item = state.selectedComplaint;
    if (item == null) return const SizedBox.shrink();

    return Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border.withValues(alpha: 0.55))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [const Icon(Icons.check_circle_outline, color: AppColors.success), const SizedBox(width: AppSpacing.sm), Expanded(child: Text('آخر شكوى تم إرسالها', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))) ]), const SizedBox(height: AppSpacing.sm), Text(item.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: AppSpacing.xs), Text(item.shortBody, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.72)))]));
  }

  Widget _buildListTab(BuildContext context, TeacherComplaintsState state) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.complaints.isEmpty) {
      return RefreshIndicator(onRefresh: () => context.read<TeacherComplaintsCubit>().loadComplaints(context.read<AuthCubit>().sessionToken), child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg), children: [const SizedBox(height: 60), _EmptyComplaintsState(onRetry: () => context.read<TeacherComplaintsCubit>().loadComplaints(context.read<AuthCubit>().sessionToken))]));
    }

    return RefreshIndicator(onRefresh: () => context.read<TeacherComplaintsCubit>().loadComplaints(context.read<AuthCubit>().sessionToken), child: ListView.separated(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg), itemCount: state.complaints.length, separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm), itemBuilder: (context, index) { final item = state.complaints[index]; return _ComplaintListCard(item: item, onTap: () => _openDetails(context, item.id)); }));
  }

  Future<void> _openDetails(BuildContext context, int id) async {
    await context.read<TeacherComplaintsCubit>().loadComplaintDetails(id);
    if (!mounted) return;
    final state = context.read<TeacherComplaintsCubit>().state;
    final item = state.selectedComplaint;
    if (item == null) return;

    await showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _ComplaintDetailSheet(item: item));
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.12))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: AppColors.onPrimary, size: 18), const SizedBox(width: AppSpacing.xs), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w800)), Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.82)))]) ]));
  }
}

class _ComplaintListCard extends StatelessWidget {
  const _ComplaintListCard({required this.item, required this.onTap});
  final TeacherComplaintItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final statusColor = item.isPending ? AppColors.warning : (item.isResolved ? AppColors.success : AppColors.info);
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border.withValues(alpha: 0.55)), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), const SizedBox(width: AppSpacing.sm), StatusBadge(label: item.statusLabel, color: statusColor)]), const SizedBox(height: AppSpacing.sm), Text(item.shortBody, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.76))), const SizedBox(height: AppSpacing.md), Row(children: [Icon(Icons.schedule_outlined, size: 16, color: AppColors.onSurface.withValues(alpha: 0.62)), const SizedBox(width: 6), Text(item.createdAt, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.64))), const Spacer(), Text(item.isResolved ? 'تم الرد' : 'قيد المراجعة', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: item.isResolved ? AppColors.success : AppColors.warning)), const SizedBox(width: 4), Icon(Icons.chevron_left, color: AppColors.onSurface.withValues(alpha: 0.42))]) ])));
  }
}

class _ComplaintDetailSheet extends StatelessWidget {
  const _ComplaintDetailSheet({required this.item});
  final TeacherComplaintItem item;
  @override
  Widget build(BuildContext context) {
    final statusColor = item.isPending ? AppColors.warning : (item.isResolved ? AppColors.success : AppColors.info);
    return DraggableScrollableSheet(initialChildSize: 0.78, minChildSize: 0.55, maxChildSize: 0.95, builder: (context, scrollController) {
      return Container(decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: SingleChildScrollView(controller: scrollController, padding: const EdgeInsets.all(AppSpacing.md), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)))), const SizedBox(height: AppSpacing.md), Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w800))), StatusBadge(label: item.statusLabel, color: statusColor)]), const SizedBox(height: AppSpacing.sm), Text('رقم الشكوى #${item.id}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.9))) ])), const SizedBox(height: AppSpacing.md), _DetailCard(title: 'التفاصيل', child: Text(item.body, style: Theme.of(context).textTheme.bodyLarge)), const SizedBox(height: AppSpacing.sm), _DetailCard(title: 'رد الإدارة', child: Text(item.response?.isNotEmpty == true ? item.response! : 'لا يوجد رد حتى الآن', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: item.response?.isNotEmpty == true ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.62)))), const SizedBox(height: AppSpacing.sm), _DetailCard(title: 'معلومات إضافية', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ _DetailRow(label: 'تم الحل', value: item.resolvedAt?.isNotEmpty == true ? 'نعم' : 'لا'), const SizedBox(height: 10), _DetailRow(label: 'تاريخ الإنشاء', value: item.createdAt), const SizedBox(height: 10), _DetailRow(label: 'آخر تحديث', value: item.updatedAt) ])), const SizedBox(height: AppSpacing.lg), PrimaryButton(label: 'إغلاق', icon: Icons.close, onPressed: () => Navigator.pop(context)), ])));
    });
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.border.withValues(alpha: 0.55))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: AppSpacing.sm), child]));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(children: [Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700))), const SizedBox(width: AppSpacing.sm), Expanded(flex: 2, child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.74))))]);
  }
}

class _EmptyComplaintsState extends StatelessWidget {
  const _EmptyComplaintsState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(child: Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border.withValues(alpha: 0.55))), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.report_gmailerrorred_outlined, size: 34, color: AppColors.primary)), const SizedBox(height: AppSpacing.md), Text('لا توجد شكاوى بعد', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: AppSpacing.xs), Text('أرسل أول شكوى، وستظهر هنا جميع الشكاوى بعد جلبها من الخادم.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.7))), const SizedBox(height: AppSpacing.md), ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('إعادة التحميل'))])));
  }
}
