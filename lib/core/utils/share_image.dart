import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareImage {
  ShareImage._();

  static Future<void> capture(
    BuildContext context, {
    required Widget widget,
    String fileNamePrefix = 'fuelkeeper',
    String? text,
    String? subject,
  }) async {
    final controller = ScreenshotController();
    final media = MediaQuery.of(context);

    final bytes = await controller.captureFromWidget(
      MediaQuery(
        data: media,
        child: Theme(
          data: Theme.of(context),
          child: Directionality(
            textDirection: Directionality.of(context),
            child: widget,
          ),
        ),
      ),
      pixelRatio: media.devicePixelRatio.clamp(2.0, 3.0),
      delay: const Duration(milliseconds: 60),
    );

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${fileNamePrefix}_$ts.png');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
        subject: subject,
      ),
    );
  }
}
