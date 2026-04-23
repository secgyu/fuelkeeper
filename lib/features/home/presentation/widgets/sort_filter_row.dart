import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/sort_order.dart';

class SortFilterRow extends ConsumerWidget {
  const SortFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSortOrderProvider);
    return Row(
      children: [
        for (var i = 0; i < SortOrder.values.length; i++) ...[
          _SortChip(
            label: SortOrder.values[i].label,
            selected: SortOrder.values[i] == selected,
            onTap: () => ref
                .read(selectedSortOrderProvider.notifier)
                .set(SortOrder.values[i]),
          ),
          if (i != SortOrder.values.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 14,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
