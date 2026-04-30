import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/notifications/local_notifications.dart';
import 'package:fuelkeeper/features/notifications/notification_providers.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';

/// 주유 알림 ON/OFF 스위치 + 주기(일) 선택을 한 타일에서 제공.
class NotificationSettingTile extends ConsumerWidget {
  const NotificationSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationEnabledProvider);
    final days = ref.watch(notificationPeriodProvider);

    Future<void> onToggle(bool next) async {
      if (next) {
        final granted = await LocalNotifications.instance.requestPermissions();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('알림 권한이 거부됐어요. 시스템 설정에서 허용해주세요.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }
      await ref.read(notificationEnabledProvider.notifier).set(next);
    }

    Future<void> onPickDays() async {
      final picked = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _PeriodPickerSheet(current: days),
      );
      if (picked != null) {
        await ref.read(notificationPeriodProvider.notifier).set(picked);
      }
    }

    return Column(
      children: [
        SettingsTile(
          icon: Icons.notifications_active_outlined,
          title: '주유 후 미주유 알림',
          subtitle: enabled
              ? '마지막 주유 $days일 뒤 오전 9시에 알림'
              : '꺼져있어요',
          trailing: Switch(value: enabled, onChanged: onToggle),
          onTap: () => onToggle(!enabled),
        ),
        if (enabled) ...[
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.schedule_rounded,
            title: '알림 주기',
            subtitle: '$days일',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textTertiary,
            ),
            onTap: onPickDays,
          ),
        ],
      ],
    );
  }
}

class _PeriodPickerSheet extends StatelessWidget {
  const _PeriodPickerSheet({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderHair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '알림 주기 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final option in NotificationPeriodNotifier.options)
              ListTile(
                title: Text('$option일'),
                trailing: option == current
                    ? Icon(
                        Icons.check_rounded,
                        color: context.colors.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
  }
}
