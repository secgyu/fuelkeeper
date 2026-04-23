import 'package:flutter/material.dart';
import 'package:fuelkeeper/features/shell/presentation/widgets/placeholder_page.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: '통계',
      icon: Icons.insights_outlined,
      description: '월별 주유 비용과 연비 트렌드를 시각화해드려요.',
    );
  }
}
