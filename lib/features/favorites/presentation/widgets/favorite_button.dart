import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/features/favorites/application/favorites_providers.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.stationId, this.size = 22});

  final String stationId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(stationId));

    return Semantics(
      button: true,
      toggled: isFav,
      label: isFav ? '즐겨찾기 해제' : '즐겨찾기 추가',
      child: GestureDetector(
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
                isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                key: ValueKey(isFav),
                size: size,
                color: isFav
                    ? context.colors.danger
                    : context.colors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
