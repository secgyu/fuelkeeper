import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/vehicles/application/vehicle_providers.dart';
import 'package:fuelkeeper/features/vehicles/domain/vehicle.dart';

/// 차량 추가 또는 편집 시트.
///
/// [vehicle]이 주어지면 편집 모드, 없으면 새로 추가 모드.
Future<void> showVehicleFormSheet(
  BuildContext context, {
  Vehicle? vehicle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => VehicleFormSheet(vehicle: vehicle),
  );
}

class VehicleFormSheet extends ConsumerStatefulWidget {
  const VehicleFormSheet({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  ConsumerState<VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends ConsumerState<VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _maker;
  late final TextEditingController _model;
  late final TextEditingController _displacement;
  late final TextEditingController _tank;
  late FuelType _fuelType;

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _name = TextEditingController(text: v?.name ?? '');
    _maker = TextEditingController(text: v?.maker ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _displacement =
        TextEditingController(text: v?.displacementCc?.toString() ?? '');
    _tank = TextEditingController(text: v?.tankCapacityL?.toString() ?? '');
    _fuelType = v?.fuelType ?? FuelType.gasoline;
  }

  @override
  void dispose() {
    _name.dispose();
    _maker.dispose();
    _model.dispose();
    _displacement.dispose();
    _tank.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final id = widget.vehicle?.id ??
        'veh_${DateTime.now().microsecondsSinceEpoch}';
    final vehicle = Vehicle(
      id: id,
      name: _name.text.trim(),
      fuelType: _fuelType,
      maker: _maker.text.trim(),
      model: _model.text.trim(),
      displacementCc: int.tryParse(_displacement.text.trim()),
      tankCapacityL: double.tryParse(_tank.text.trim()),
      createdAt: widget.vehicle?.createdAt ?? DateTime.now(),
    );

    final actions = await ref.read(vehicleActionsProvider.future);
    await actions.save(vehicle);

    // 첫 차량이면 자동 활성화.
    final activeId = ref.read(activeVehicleIdProvider);
    if (activeId == null) {
      await ref.read(activeVehicleIdProvider.notifier).set(vehicle.id);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.borderHair,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _isEdit ? '차량 편집' : '차량 추가',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Field(
                  controller: _name,
                  label: '차량 별명 *',
                  hint: '예) 내 차, 출퇴근용',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? '별명을 입력해주세요'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _FuelTypeSelector(
                  selected: _fuelType,
                  onChanged: (v) => setState(() => _fuelType = v),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _maker,
                        label: '제조사',
                        hint: '현대',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _Field(
                        controller: _model,
                        label: '모델명',
                        hint: '소나타',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _displacement,
                        label: '배기량(cc)',
                        hint: '2000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _Field(
                        controller: _tank,
                        label: '연료탱크(L)',
                        hint: '60',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.textPrimary,
                    foregroundColor: context.colors.bgPrimary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    _isEdit ? '저장' : '추가',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: context.colors.borderHair),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: context.colors.borderHair),
            ),
          ),
        ),
      ],
    );
  }
}

class _FuelTypeSelector extends StatelessWidget {
  const _FuelTypeSelector({required this.selected, required this.onChanged});

  final FuelType selected;
  final ValueChanged<FuelType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '연료 종류',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FuelType.values.map((t) {
            final isSelected = t == selected;
            return GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.borderHair,
                  ),
                ),
                child: Text(
                  t.label,
                  style: TextStyle(
                    color: isSelected
                        ? context.colors.bgPrimary
                        : context.colors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
