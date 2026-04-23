import 'package:flutter/material.dart';
import 'package:fuelkeeper/features/shell/presentation/widgets/placeholder_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: '지도',
      icon: Icons.map_outlined,
      description: '주변 주유소를 지도로 한눈에 확인해보세요.',
    );
  }
}
