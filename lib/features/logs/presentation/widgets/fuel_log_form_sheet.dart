import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:uuid/uuid.dart';

Future<void> showFuelLogFormSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FuelLogFormSheet(),
  );
}

class _FuelLogFormSheet extends ConsumerStatefulWidget {
  const _FuelLogFormSheet();

  @override
  ConsumerState<_FuelLogFormSheet> createState() => _FuelLogFormSheetState();
}

class _FuelLogFormSheetState extends ConsumerState<_FuelLogFormSheet> {
  Station? _station;
  DateTime _date = DateTime.now();
  FuelType _fuelType = FuelType.gasoline;
  final _priceCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _litersCtrl.dispose();
    _odometerCtrl.dispose();
    super.dispose();
  }

  int get _price => int.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0;
  double get _liters => double.tryParse(_litersCtrl.text) ?? 0;
  int get _odometer =>
      int.tryParse(_odometerCtrl.text.replaceAll(',', '')) ?? 0;
  int get _totalCost => (_price * _liters).round();

  bool get _canSave =>
      _station != null && _price > 0 && _liters > 0 && _odometer > 0;

  Future<void> _pickStation() async {
    final stations = ref.read(stationsProvider).value ?? const [];
    final picked = await showModalBottomSheet<Station>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StationPickerSheet(stations: stations),
    );
    if (picked != null) {
      setState(() {
        _station = picked;
        _priceCtrl.text = picked.priceOf(_fuelType)?.toString() ?? '';
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_canSave || _station == null) return;
    setState(() => _saving = true);
    final log = FuelLog(
      id: const Uuid().v4(),
      stationId: _station!.id,
      stationName: _station!.name,
      brand: _station!.brand,
      date: _date,
      fuelType: _fuelType,
      pricePerLiter: _price,
      liters: _liters,
      odometerKm: _odometer,
    );
    final actions = await ref.read(fuelLogActionsProvider.future);
    await actions.save(log);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderHair,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.base,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Text('주유 기록 추가', style: AppTypography.h3),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderHair),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _FieldLabel('주유소'),
                      _StationField(station: _station, onTap: _pickStation),
                      const SizedBox(height: AppSpacing.lg),
                      _FieldLabel('날짜'),
                      _DateField(date: _date, onTap: _pickDate),
                      const SizedBox(height: AppSpacing.lg),
                      _FieldLabel('연료'),
                      _FuelTypeSelector(
                        selected: _fuelType,
                        onChanged: (t) {
                          setState(() {
                            _fuelType = t;
                            final p = _station?.priceOf(t);
                            if (p != null) _priceCtrl.text = p.toString();
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _NumberField(
                              label: '단가 (원/L)',
                              controller: _priceCtrl,
                              suffix: '원',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _NumberField(
                              label: '주유량',
                              controller: _litersCtrl,
                              suffix: 'L',
                              allowDecimal: true,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NumberField(
                        label: '주행거리 (총 누적)',
                        controller: _odometerCtrl,
                        suffix: 'km',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SummaryCard(totalCost: _totalCost),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _canSave && !_saving ? _save : null,
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '저장',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
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

class _StationField extends StatelessWidget {
  const _StationField({required this.station, required this.onTap});
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

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
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
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
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

class _FuelTypeSelector extends StatelessWidget {
  const _FuelTypeSelector({required this.selected, required this.onChanged});
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

class _NumberField extends StatelessWidget {
  const _NumberField({
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
        _FieldLabel(label),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.borderHair),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.borderHair),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalCost});
  final int totalCost;

  String _format(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remain = s.length - i - 1;
      if (remain > 0 && remain % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

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
            '₩ ${_format(totalCost)}',
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

class _StationPickerSheet extends StatelessWidget {
  const _StationPickerSheet({required this.stations});
  final List<Station> stations;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderHair,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('주유소 선택', style: AppTypography.h3),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.borderHair),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: stations.length,
                  itemBuilder: (context, i) {
                    final s = stations[i];
                    return ListTile(
                      onTap: () => Navigator.pop(context, s),
                      leading: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: s.brand.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${s.brand.label} · ${s.distanceKm.toStringAsFixed(1)}km',
                        style: AppTypography.caption,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
