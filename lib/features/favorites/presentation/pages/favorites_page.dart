import 'package:flutter/material.dart';
import 'package:fuelkeeper/features/shell/presentation/widgets/placeholder_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: '즐겨찾기',
      icon: Icons.favorite_outline_rounded,
      description: '자주 가는 주유소를 저장하고 가격 알림을 받아보세요.',
    );
  }
}
