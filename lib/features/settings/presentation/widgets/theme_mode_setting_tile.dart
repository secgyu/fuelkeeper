import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/theme_mode_provider.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';

class ThemeModeSettingTile extends ConsumerWidget {
  const ThemeModeSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return SettingsTile(
      icon: _iconOf(mode),
      title: '테마',
      trailing: Text(
        _labelOf(mode),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
        ),
      ),
      onTap: () => _showPicker(context, ref, mode),
    );
  }

  Future<void> _showPicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: context.colors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _ThemeModePickerSheet(current: current),
    );

    if (picked != null && picked != current) {
      await ref.read(themeModeProvider.notifier).set(picked);
    }
  }

  static IconData _iconOf(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }

  static String _labelOf(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '시스템 설정';
      case ThemeMode.light:
        return '라이트';
      case ThemeMode.dark:
        return '다크';
    }
  }
}

class _ThemeModePickerSheet extends StatelessWidget {
  const _ThemeModePickerSheet({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '테마',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),
          for (final m in ThemeMode.values)
            ListTile(
              leading: Icon(ThemeModeSettingTile._iconOf(m)),
              title: Text(ThemeModeSettingTile._labelOf(m)),
              trailing: m == current
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colors.primary,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(m),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
