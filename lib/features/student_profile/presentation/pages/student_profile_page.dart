import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملف الطالب',
      currentIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 30, child: Text('م')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مريم أحمد', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.xs),
                          const Text('الصف الثالث • شعبة A'),
                          const SizedBox(height: AppSpacing.sm),
                          const StatusBadge(label: 'حاضر اليوم', color: AppColors.success),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'سجل الحضور'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('منذ بداية الفصل: 92% حضور'),
                    SizedBox(height: AppSpacing.sm),
                    Text('غياب مبرر: 2 أيام'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'العلامات الأخيرة'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: const [
                    ListTile(title: Text('اختبار الرياضيات'), trailing: Text('89')),
                    Divider(),
                    ListTile(title: Text('واجب العلوم'), trailing: Text('94')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'ملاحظات الأهل'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Text('مراجعة واجب الرياضيات مساءً مع الأهل، وتم إرسال إشعار بالحضور اليومي.'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
