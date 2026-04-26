import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLauncher {
  ExternalLauncher._();

  static Future<void> phoneCall(BuildContext context, String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _snack(context, '전화번호 정보가 없어요');
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleaned);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      _snack(context, '전화 앱을 열 수 없어요');
    }
  }

  static Future<void> drivingDirections(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String name,
  }) async {
    final encodedName = Uri.encodeComponent(name);

    final naverApp = Uri.parse(
      'nmap://route/car?dlat=$latitude&dlng=$longitude'
      '&dname=$encodedName&appname=com.example.fuelkeeper',
    );
    if (await canLaunchUrl(naverApp)) {
      final ok = await launchUrl(
        naverApp,
        mode: LaunchMode.externalApplication,
      );
      if (ok) return;
    }

    final naverWeb = Uri.parse(
      'https://map.naver.com/p/directions/-/'
      '$longitude,$latitude,$encodedName/-/car',
    );
    final ok = await launchUrl(
      naverWeb,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      _snack(context, '지도 앱을 열 수 없어요');
    }
  }

  static void _snack(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
