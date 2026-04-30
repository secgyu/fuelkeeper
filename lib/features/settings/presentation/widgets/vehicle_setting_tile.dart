import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';
import 'package:fuelkeeper/features/vehicles/application/vehicle_providers.dart';
import 'package:go_router/go_router.dart';

/// 설정 페이지에서 차량 관리 화면으로 진입하는 타일.
///
/// 활성 차량 이름과 부제(제조사·모델)를 함께 보여줘 한눈에 인식되게 한다.
class VehicleSettingTile extends ConsumerWidget {
  const VehicleSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeVehicleProvider);
    final asyncVehicles = ref.watch(vehiclesProvider);
    final count = asyncVehicles.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    final subtitle = active == null
        ? (count == 0 ? '등록된 차량이 없어요' : '활성 차량을 선택해주세요')
        : (active.subtitle.isEmpty ? null : active.subtitle);

    return SettingsTile(
      icon: Icons.directions_car_outlined,
      title: active?.name ?? '차량 관리',
      subtitle: subtitle,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.colors.textTertiary,
      ),
      onTap: () => context.push(AppRoutes.vehicles),
    );
  }
}
