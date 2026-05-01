import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/stats/application/national_stats_providers.dart';
import 'package:fuelkeeper/features/stats/domain/sido.dart';

class SidoSelector extends ConsumerWidget {
  const SidoSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(effectiveSidoProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.full),
      onTap: () => _open(context, ref, current),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: context.colors.bgMuted,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: context.colors.borderHair),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: context.colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              current.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Sido current) async {
    final picked = await showModalBottomSheet<Sido>(
      context: context,
      backgroundColor: context.colors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => _SidoListSheet(current: current),
    );
    if (picked != null) {
      ref.read(selectedSidoProvider.notifier).set(picked);
    }
  }
}

class _SidoListSheet extends StatelessWidget {
  const _SidoListSheet({required this.current});

  final Sido current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.base),
              decoration: BoxDecoration(
                color: context.colors.borderHair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '시·도 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final sido in Sido.values)
                    ListTile(
                      title: Text(
                        sido.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: sido == current
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      trailing: sido == current
                          ? Icon(
                              Icons.check_rounded,
                              color: context.colors.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(sido),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
