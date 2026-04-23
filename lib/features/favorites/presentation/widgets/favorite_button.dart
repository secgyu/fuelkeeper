import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/features/favorites/application/favorites_providers.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.stationId, this.size = 22});

  final String stationId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(stationId));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(favoriteIdsProvider.notifier).toggle(stationId),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              key: ValueKey(isFav),
              size: size,
              color: isFav ? AppColors.danger : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
