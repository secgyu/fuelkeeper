import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/logs/data/fuel_log_csv.dart';
import 'package:fuelkeeper/features/settings/presentation/widgets/settings_primitives.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 주유 로그 전체를 CSV로 내보낸 뒤 시스템 공유 시트로 전달.
class FuelLogsExportTile extends ConsumerWidget {
  const FuelLogsExportTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onExport() async {
      try {
        final logs = ref.read(allFuelLogsProvider).value ?? const [];
        if (logs.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('내보낼 주유 기록이 없어요'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        final csv = FuelLogCsv.encode(logs);
        final dir = await getTemporaryDirectory();
        final fileName =
            'fuelkeeper_logs_${DateTime.now().toIso8601String().substring(0, 10)}.csv';
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(csv, encoding: utf8);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
            subject: 'FuelKeeper 주유 기록 백업',
            text: '주유 기록 ${logs.length}건',
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('내보내기에 실패했어요: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    return SettingsTile(
      icon: Icons.upload_file_outlined,
      title: '주유 기록 내보내기',
      subtitle: 'CSV 파일로 백업하고 공유',
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.colors.textTertiary,
      ),
      onTap: onExport,
    );
  }
}

/// CSV 파일을 골라 주유 로그를 가져온다. 동일 id는 덮어쓴다.
class FuelLogsImportTile extends ConsumerWidget {
  const FuelLogsImportTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onImport() async {
      try {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
          withData: true,
        );
        if (result == null || result.files.isEmpty) return;
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes == null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('파일을 읽지 못했어요'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final csv = utf8.decode(bytes);
        final logs = FuelLogCsv.decode(csv);

        if (logs.isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('가져올 수 있는 기록이 없어요'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final actions = await ref.read(fuelLogActionsProvider.future);
        for (final l in logs) {
          await actions.save(l);
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${logs.length}건을 가져왔어요'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('가져오기에 실패했어요: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    return SettingsTile(
      icon: Icons.download_outlined,
      title: '주유 기록 가져오기',
      subtitle: 'CSV 파일에서 복원',
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.colors.textTertiary,
      ),
      onTap: onImport,
    );
  }
}
