import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';

enum NotificationKind {
  priceDrop('가격 인하', Icons.trending_down_rounded, AppColors.accent),
  priceRise('가격 인상', Icons.trending_up_rounded, AppColors.danger),
  favorite('즐겨찾기', Icons.favorite_rounded, AppColors.danger),
  system('시스템', Icons.info_outline_rounded, AppColors.primary);

  const NotificationKind(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
}
