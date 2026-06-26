import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/teacher_news_item.dart';
import '../cubit/news_cubit.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthCubit>().sessionToken;
      context.read<NewsCubit>().loadNews(token);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        final news = state is NewsLoaded ? state.news : <TeacherNewsItem>[];
        final unreadCount = state is NewsLoaded ? state.unreadCount : 0;
        final isLoading = state is NewsLoading;
        final errorMessage = state is NewsError ? state.message : null;

        return AppScaffold(
          title: 'الأخبار',
          currentIndex: 3,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'آخر الأخبار',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'تابع الإعلانات الرسمية والتنبيهات المهمة',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onPrimary.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.onPrimary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_none, color: AppColors.onPrimary, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$unreadCount غير مقروءة',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (unreadCount > 0)
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              label: 'تحديد الكل كمقروء',
                              onPressed: () => context.read<NewsCubit>().markAllAsRead(),
                              icon: Icons.done_all,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildBody(context, isLoading, errorMessage, news),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, bool isLoading, String? errorMessage, List<TeacherNewsItem> news) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: AppColors.warning),
              const SizedBox(height: AppSpacing.sm),
              Text('تعذر تحميل الأخبار', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              Text(errorMessage, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () {
                  final token = context.read<AuthCubit>().sessionToken;
                  context.read<NewsCubit>().loadNews(token);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (news.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 42, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text('لا توجد أخبار حاليا', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              Text('ستظهر الإعلانات القادمة هنا بمجرد وصولها من الخادم.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: news.length,
      itemBuilder: (context, index) {
        final item = news[index];
        return _NewsCard(
          news: item,
          onMarkAsRead: () => context.read<NewsCubit>().markAsRead(item.id),
        );
      },
    );
  }
}

class _NewsCard extends StatefulWidget {
  const _NewsCard({required this.news, required this.onMarkAsRead});

  final TeacherNewsItem news;
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
    final isRead = widget.news.isRead;
    final accent = isRead ? AppColors.info : AppColors.error;

    return Card(
      elevation: isRead ? 1 : 3,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.news.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isRead ? AppColors.onSurface.withValues(alpha: 0.75) : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.news.formattedCreatedAt,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.65)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isRead ? 'مقروء' : 'جديد',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.news.body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: AppColors.onSurface.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'منشئ الخبر: ${widget.news.creatorName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
                    ),
                  ),
                  if (widget.news.hasAttachments)
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Text('مرفقات', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'البريد: ${widget.news.creatorEmail}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: AppSpacing.xs),
                        Text(_isExpanded ? 'إخفاء التفاصيل' : 'عرض التفاصيل', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
