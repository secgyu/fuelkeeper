import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:geolocator/geolocator.dart';

class LocationStatusBanner extends ConsumerWidget {
  const LocationStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(locationResultProvider);
    return asyncResult.maybeWhen(
      data: (result) {
        if (result.status == LocationStatus.granted) {
          return const SizedBox.shrink();
        }
        return _Banner(status: result.status, ref: ref);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.status, required this.ref});

  final LocationStatus status;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final spec = _specOf(status);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_off_rounded,
            color: context.colors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.title,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(spec.description, style: AppTypography.body2),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => _runAction(spec.primaryAction),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.warning.withValues(
                          alpha: 0.18,
                        ),
                        foregroundColor: context.colors.warning,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(spec.primaryActionLabel),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(locationResultProvider),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAction(_BannerAction action) async {
    switch (action) {
      case _BannerAction.openAppSettings:
        await Geolocator.openAppSettings();
      case _BannerAction.openLocationSettings:
        await Geolocator.openLocationSettings();
      case _BannerAction.requestPermission:
        await Geolocator.requestPermission();
        ref.invalidate(locationResultProvider);
    }
  }

  _BannerSpec _specOf(LocationStatus status) {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return const _BannerSpec(
          title: '위치 서비스가 꺼져있어요',
          description: '주변 주유소를 보려면 단말기 설정에서 위치 서비스를 켜주세요.',
          primaryActionLabel: '설정 열기',
          primaryAction: _BannerAction.openLocationSettings,
        );
      case LocationStatus.denied:
        return const _BannerSpec(
          title: '위치 권한이 필요해요',
          description: '주변 주유소를 검색하려면 위치 접근을 허용해주세요.',
          primaryActionLabel: '권한 허용',
          primaryAction: _BannerAction.requestPermission,
        );
      case LocationStatus.deniedForever:
        return const _BannerSpec(
          title: '위치 권한이 차단되어 있어요',
          description: '앱 설정에서 위치 권한을 허용해주세요.',
          primaryActionLabel: '앱 설정 열기',
          primaryAction: _BannerAction.openAppSettings,
        );
      case LocationStatus.unavailable:
        return const _BannerSpec(
          title: '현재 위치를 가져오지 못했어요',
          description: '실외에서 잠시 기다린 뒤 다시 시도해주세요.',
          primaryActionLabel: '다시 시도',
          primaryAction: _BannerAction.requestPermission,
        );
      case LocationStatus.granted:
        return const _BannerSpec(
          title: '',
          description: '',
          primaryActionLabel: '',
          primaryAction: _BannerAction.requestPermission,
        );
    }
  }
}

enum _BannerAction { openAppSettings, openLocationSettings, requestPermission }

class _BannerSpec {
  const _BannerSpec({
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.primaryAction,
  });

  final String title;
  final String description;
  final String primaryActionLabel;
  final _BannerAction primaryAction;
}
