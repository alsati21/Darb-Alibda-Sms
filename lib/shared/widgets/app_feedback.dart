import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

void showAppFeedback(
  BuildContext context, {
  required String message,
  required bool isError,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      content: Row(
        children: [
          Icon(
            icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
            color: AppColors.onPrimary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}
