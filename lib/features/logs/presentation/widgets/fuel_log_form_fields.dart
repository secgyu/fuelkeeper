import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/utils/formatters.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class StationField extends StatelessWidget {
  const StationField({super.key, required this.station, required this.onTap});

  final Station? station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderHair),
        ),
        child: Row(
          children: [
            if (station != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: station!.brand.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  station!.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ] else
              const Expanded(
                child: Text(
                  '주유소를 선택해주세요',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class DateField extends StatelessWidget {
  const DateField({super.key, required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = Formatters.date(date);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderHair),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formatted,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FuelTypeSelector extends StatelessWidget {
  const FuelTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final FuelType selected;
  final ValueChanged<FuelType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final t in FuelType.values)
          ChoiceChip(
            label: Text(t.label),
            selected: selected == t,
            onSelected: (_) => onChanged(t),
            backgroundColor: AppColors.bgPrimary,
            selectedColor: AppColors.textPrimary,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected == t ? Colors.white : AppColors.textSecondary,
            ),
            side: BorderSide(
              color: selected == t
                  ? AppColors.textPrimary
                  : AppColors.borderHair,
            ),
            showCheckmark: false,
          ),
      ],
    );
  }
}

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.suffix,
    this.allowDecimal = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;
  final bool allowDecimal;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
          inputFormatters: [
            if (allowDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: onChanged,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: suffix,
            suffixStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.bgPrimary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: _border(AppColors.borderHair),
            enabledBorder: _border(AppColors.borderHair),
            focusedBorder: _border(AppColors.primary, width: 1.5),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class TotalCostSummaryCard extends StatelessWidget {
  const TotalCostSummaryCard({super.key, required this.totalCost});

  final int totalCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '결제 금액',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            Formatters.currency(totalCost),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
