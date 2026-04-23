import 'package:flutter/material.dart';

enum StationAmenity {
  carWash('세차장', Icons.local_car_wash_outlined),
  convenience('편의점', Icons.store_outlined),
  maintenance('경정비', Icons.build_outlined),
  nightDiscount('야간할인', Icons.bedtime_outlined);

  const StationAmenity(this.label, this.icon);
  final String label;
  final IconData icon;
}
