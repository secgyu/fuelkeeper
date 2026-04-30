import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:fuelkeeper/features/logs/presentation/widgets/fuel_log_form_sheet.dart';
import 'package:fuelkeeper/features/logs/presentation/widgets/log_tile.dart';
import 'package:fuelkeeper/features/logs/presentation/widgets/logs_empty_state.dart';
import 'package:fuelkeeper/features/logs/presentation/widgets/monthly_summary_card.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/core/widgets/skeleton.dart';

class LogsPage extends ConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(fuelLogsProvider);
    final summary = ref.watch(currentMonthSummaryProvider);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: context.colors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('주유 로그', style: AppTypography.h2),
        centerTitle: false,
      ),
      body: logsAsync.when(
        loading: () => const _LogsLoadingSkeleton(),
        error: (e, _) {
          debugPrint('[logs] load failed: $e');
          return const Center(child: Text('주유 기록을 불러오지 못했어요'));
        },
        data: (logs) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: MonthlySummaryCard(summary: summary),
              ),
            ),
            if (logs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: LogsEmptyState(),
              )
            else
              ..._buildGroupedLogs(ref, logs),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFuelLogFormSheet(context),
        backgroundColor: context.colors.textPrimary,

        foregroundColor: context.colors.bgPrimary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          '주유 기록',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedLogs(WidgetRef ref, List<FuelLog> logs) {
    final groups = <String, List<FuelLog>>{};
    for (final log in logs) {
      final key =
          '${log.date.year}년 ${log.date.month.toString().padLeft(2, '0')}월';
      groups.putIfAbsent(key, () => []).add(log);
    }

    final widgets = <Widget>[];
    groups.forEach((month, monthLogs) {
      widgets.add(_MonthHeader(month: month));
      widgets.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => LogTile(
              log: monthLogs[i],
              onDelete: () async {
                final actions = await ref.read(fuelLogActionsProvider.future);
                await actions.delete(monthLogs[i].id);
              },
            ),
            childCount: monthLogs.length,
          ),
        ),
      );
    });
    return widgets;
  }
}

class _LogsLoadingSkeleton extends StatelessWidget {
  const _LogsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.colors.borderHair),
          ),
          padding: const EdgeInsets.all(AppSpacing.base),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 80, height: 12),
              SizedBox(height: 10),
              Skeleton(width: 130, height: 26),
              Spacer(),
              Skeleton(width: 220, height: 12),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < 4; i++) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: context.colors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.borderHair),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 100, height: 14),
                      SizedBox(height: 6),
                      Skeleton(width: 70, height: 12),
                    ],
                  ),
                ),
                Skeleton(width: 80, height: 18),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month});

  final String month;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Text(
          month,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.colors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
