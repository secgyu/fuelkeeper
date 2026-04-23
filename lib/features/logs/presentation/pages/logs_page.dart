import 'package:flutter/material.dart';
import 'package:fuelkeeper/features/shell/presentation/widgets/placeholder_page.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: '주유로그',
      icon: Icons.receipt_long_outlined,
      description: '주유 기록을 남기고 연비를 자동으로 계산해드려요.',
    );
  }
}
