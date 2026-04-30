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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
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
