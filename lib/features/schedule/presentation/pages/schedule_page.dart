import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الجدول والمهمات',
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'جدول الأسبوع',
              subtitle: 'راجع حصصك اليومية وجدولك المؤكد',
              actionLabel: 'اليوم',
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الثلاثاء', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('08:30 - 09:15 • الرياضيات • الصف الثالث'),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('09:30 - 10:15 • العلوم • الصف الثاني'),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('10:30 - 11:15 • اللغة العربية • الصف الرابع'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(
              title: 'مهام اليوم',
              subtitle: 'أهم الإجراءات التي يجب تنفيذها الآن',
            ),
            Card(
              child: ListTile(
                title: const Text('توزيع نتائج الاختبار الأسبوعي'),
                subtitle: const Text('مهلة قبل 12:00 مساءً'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('مراجعة طلبات غياب الطلاب'),
                subtitle: const Text('عدد الطلبات 5'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
