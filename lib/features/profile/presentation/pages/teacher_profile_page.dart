import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الملف الشخصي',
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'ملف المعلم',
              subtitle: 'تفاصيل الحساب وسير العمل اليومي',
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 32)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('أ. فاطمة علي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          SizedBox(height: AppSpacing.xs),
                          Text('معلمة رياضيات • المرحلة المتوسطة'),
                          SizedBox(height: AppSpacing.sm),
                          Text('0501234567'),
                        ],
                      ),
                    ),
                    const StatusBadge(label: 'نشط', color: AppColors.success),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    _DetailRow(label: 'عدد الطلاب', value: '86'),
                    const Divider(),
                    _DetailRow(label: 'الصفوف الحالية', value: '5'),
                    const Divider(),
                    _DetailRow(label: 'الطلبات المعلقة', value: '7'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'حول المعلمة'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Text(
                  'معلمة متخصصة في الرياضيات بخبرة 8 سنوات، تهتم بتقديم تجربة تعليمية تفاعلية ومنظمة للطلاب والأهل.',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
              label: const Text('إعدادات الحساب'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
