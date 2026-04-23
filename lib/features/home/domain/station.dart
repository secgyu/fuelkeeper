import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';

class Station {
  const Station({
    required this.id,
    required this.name,
    required this.brand,
    required this.address,
    required this.distanceKm,
    required this.prices,
    this.isSelfService = false,
  });

  final String id;
  final String name;
  final StationBrand brand;
  final String address;
  final double distanceKm;
  final Map<FuelType, int> prices;
  final bool isSelfService;

  int? priceOf(FuelType type) => prices[type];
}
