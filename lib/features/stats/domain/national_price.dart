import 'package:fuelkeeper/features/stats/domain/sido.dart';

class SidoAverage {
  const SidoAverage({required this.sido, required this.price});

  final Sido sido;
  final int price;
}

class LowPriceStation {
  const LowPriceStation({
    required this.id,
    required this.name,
    required this.brandCode,
    required this.address,
    required this.price,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String brandCode;
  final String address;
  final int price;
  final double? latitude;
  final double? longitude;
}
