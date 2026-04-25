import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title = '문제가 발생했어요',
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderHair),
              ),
              child: Icon(icon, color: AppColors.danger, size: 28),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('다시 시도'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bgSurface,
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderHair),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
