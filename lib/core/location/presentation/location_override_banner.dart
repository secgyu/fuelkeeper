import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';

/// 사용자가 검색을 통해 임시로 다른 지역을 보고 있을 때, 그 사실을 명확히
/// 알리고 "내 위치로 돌아가기" 버튼을 함께 제공하는 배너.
///
/// 오버라이드가 없으면 빈 위젯을 반환한다.
class LocationOverrideBanner extends ConsumerWidget {
  const LocationOverrideBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(locationOverrideProvider);
    if (override == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 18,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${override.label} 주변을 보는 중',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(locationOverrideProvider.notifier).clear(),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '내 위치로',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
