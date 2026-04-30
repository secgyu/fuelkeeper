import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:geolocator/geolocator.dart';

/// 위치 권한이 영구 거부 또는 서비스 OFF 상태일 때 표시하는 안내 다이얼로그.
///
/// 세션당 한 번만 노출되도록 호출부에서 플래그로 제어한다.
/// 사용자가 [openAppSettings]/[openLocationSettings]로 설정 화면에 진입할 수 있다.
Future<void> showLocationPermissionDialog(
  BuildContext context, {
  required LocationStatus status,
}) async {
  final isService = status == LocationStatus.serviceDisabled;
  final title = isService ? '위치 서비스가 꺼져있어요' : '위치 권한이 차단되어 있어요';
  final body = isService
      ? '주변 주유소를 정확히 보여드리려면\n시스템 설정에서 위치 서비스를 켜주세요.'
      : '주변 주유소를 정확히 보여드리려면\n앱 설정에서 위치 권한을 허용해주세요.';
  final actionLabel = isService ? '위치 설정 열기' : '앱 설정 열기';

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ctx.colors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isService
                      ? Icons.location_off_rounded
                      : Icons.lock_outline_rounded,
                  color: ctx.colors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ctx.colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ctx.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  if (isService) {
                    await Geolocator.openLocationSettings();
                  } else {
                    await Geolocator.openAppSettings();
                  }
                },
                child: Text(actionLabel),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  '나중에',
                  style: TextStyle(color: ctx.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
