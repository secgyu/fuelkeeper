import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/vehicles/application/vehicle_providers.dart';
import 'package:fuelkeeper/features/vehicles/domain/vehicle.dart';
import 'package:fuelkeeper/features/vehicles/presentation/widgets/vehicle_form_sheet.dart';

/// 차량 목록 + 활성 차량 선택 + 추가/편집 진입 화면.
class VehiclesPage extends ConsumerWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVehicles = ref.watch(vehiclesProvider);
    final activeId = ref.watch(activeVehicleIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('차량 관리')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showVehicleFormSheet(context),
        backgroundColor: context.colors.textPrimary,
        foregroundColor: context.colors.bgPrimary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          '차량 추가',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: asyncVehicles.when(
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
          error: (_, _) => const Center(child: Text('차량을 불러오지 못했어요')),
          data: (vehicles) {
            if (vehicles.isEmpty) return const _EmptyState();
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.base,
                AppSpacing.lg,
                AppSpacing.xxl + 56,
              ),
              itemCount: vehicles.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final v = vehicles[i];
                return _VehicleTile(
                  vehicle: v,
                  isActive: v.id == activeId,
                  onSelect: () =>
                      ref.read(activeVehicleIdProvider.notifier).set(v.id),
                  onEdit: () => showVehicleFormSheet(context, vehicle: v),
                  onDelete: () => _confirmDelete(context, ref, v),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Vehicle v,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('차량 삭제'),
        content: Text(
          '"${v.name}" 차량을 삭제할까요?\n주유 기록은 그대로 유지됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '삭제',
              style: TextStyle(color: ctx.colors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final actions = await ref.read(vehicleActionsProvider.future);
    await actions.delete(v.id);

    final activeId = ref.read(activeVehicleIdProvider);
    if (activeId == v.id) {
      await ref.read(activeVehicleIdProvider.notifier).set(null);
    }
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.vehicle,
    required this.isActive,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.bgSurface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isActive
                  ? context.colors.primary
                  : context.colors.borderHair,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: context.colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            vehicle.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.bgMuted,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            vehicle.fuelType.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '활성',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: context.colors.bgPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (vehicle.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: '편집',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: '삭제',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: context.colors.danger,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                color: context.colors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '아직 등록한 차량이 없어요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '차량을 추가하면 더 정확한 연비와\n맞춤 알림을 받을 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textTertiary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
