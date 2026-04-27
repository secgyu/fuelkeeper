import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/utils/external_launcher.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({super.key, required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    final hasPhone = station.phone.trim().isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasPhone
                ? () => ExternalLauncher.phoneCall(context, station.phone)
                : null,
            icon: const Icon(Icons.call_outlined, size: 18),
            label: const Text('전화'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () => ExternalLauncher.drivingDirections(
              context,
              latitude: station.latitude,
              longitude: station.longitude,
              name: station.name,
            ),
            icon: const Icon(Icons.directions_rounded, size: 20),
            label: const Text('길찾기'),
          ),
        ),
      ],
    );
  }
}
