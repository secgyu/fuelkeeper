import 'package:flutter/material.dart';
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
import 'package:fuelkeeper/features/logs/presentation/widgets/fuel_log_form_fields.dart';
import 'package:fuelkeeper/features/logs/presentation/widgets/station_picker_sheet.dart';
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
      builder: (_) => StationPickerSheet(stations: stations),
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

  void _onFuelTypeChanged(FuelType t) {
    setState(() {
      _fuelType = t;
      final p = _station?.priceOf(t);
      if (p != null) _priceCtrl.text = p.toString();
    });
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            child: Column(
              children: [
                const _SheetGrabber(),
                _SheetHeader(onClose: () => Navigator.pop(context)),
                const Divider(height: 1, color: AppColors.borderHair),
                Expanded(
                  child: _FormBody(
                    scrollController: scrollController,
                    station: _station,
                    date: _date,
                    fuelType: _fuelType,
                    priceCtrl: _priceCtrl,
                    litersCtrl: _litersCtrl,
                    odometerCtrl: _odometerCtrl,
                    totalCost: _totalCost,
                    canSave: _canSave,
                    saving: _saving,
                    onPickStation: _pickStation,
                    onPickDate: _pickDate,
                    onFuelTypeChanged: _onFuelTypeChanged,
                    onAnyFieldChanged: () => setState(() {}),
                    onSave: _save,
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

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderHair,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onPressed: onClose,
            style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
          ),
        ],
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.scrollController,
    required this.station,
    required this.date,
    required this.fuelType,
    required this.priceCtrl,
    required this.litersCtrl,
    required this.odometerCtrl,
    required this.totalCost,
    required this.canSave,
    required this.saving,
    required this.onPickStation,
    required this.onPickDate,
    required this.onFuelTypeChanged,
    required this.onAnyFieldChanged,
    required this.onSave,
  });

  final ScrollController scrollController;
  final Station? station;
  final DateTime date;
  final FuelType fuelType;
  final TextEditingController priceCtrl;
  final TextEditingController litersCtrl;
  final TextEditingController odometerCtrl;
  final int totalCost;
  final bool canSave;
  final bool saving;
  final VoidCallback onPickStation;
  final VoidCallback onPickDate;
  final ValueChanged<FuelType> onFuelTypeChanged;
  final VoidCallback onAnyFieldChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const FieldLabel('주유소'),
        StationField(station: station, onTap: onPickStation),
        const SizedBox(height: AppSpacing.lg),
        const FieldLabel('날짜'),
        DateField(date: date, onTap: onPickDate),
        const SizedBox(height: AppSpacing.lg),
        const FieldLabel('연료'),
        FuelTypeSelector(selected: fuelType, onChanged: onFuelTypeChanged),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NumberField(
                label: '단가 (원/L)',
                controller: priceCtrl,
                suffix: '원',
                onChanged: (_) => onAnyFieldChanged(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: NumberField(
                label: '주유량',
                controller: litersCtrl,
                suffix: 'L',
                allowDecimal: true,
                onChanged: (_) => onAnyFieldChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NumberField(
          label: '주행거리 (총 누적)',
          controller: odometerCtrl,
          suffix: 'km',
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: AppSpacing.lg),
        TotalCostSummaryCard(totalCost: totalCost),
        const SizedBox(height: AppSpacing.lg),
        _SaveButton(canSave: canSave, saving: saving, onPressed: onSave),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.canSave,
    required this.saving,
    required this.onPressed,
  });

  final bool canSave;
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: canSave && !saving ? onPressed : null,
        child: saving
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
    );
  }
}
