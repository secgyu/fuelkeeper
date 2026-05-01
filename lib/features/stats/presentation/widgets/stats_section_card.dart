import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/features/stats/application/section_collapsed_providers.dart';

class StatsSectionCard extends ConsumerWidget {
  const StatsSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.collapsible = false,
    this.sectionId,
  }) : assert(
         !collapsible || sectionId != null,
         'collapsible=true이면 sectionId가 필요합니다',
       );

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final bool collapsible;
  final String? sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTrailing = trailing != null;

    final isCollapsed = collapsible
        ? ref.watch(collapsedSectionsProvider).contains(sectionId)
        : false;
    final isExpanded = !isCollapsed;

    void toggle() {
      if (!collapsible) return;
      ref.read(collapsedSectionsProvider.notifier).toggle(sectionId!);
    }

    final headerCenter = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null && hasTrailing) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderHair),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: collapsible ? toggle : null,
                  child: headerCenter,
                ),
              ),
              if (hasTrailing) trailing!,
              if (!hasTrailing && subtitle != null && !collapsible)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textTertiary,
                  ),
                ),
              if (collapsible) ...[
                const SizedBox(width: AppSpacing.xs),
                _ChevronButton(expanded: isExpanded, onTap: toggle),
              ],
            ],
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              heightFactor: isExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.base),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedRotation(
          turns: expanded ? 0.0 : -0.25,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
