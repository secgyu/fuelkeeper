import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station_amenity.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';

class Station {
  const Station({
    required this.id,
    required this.name,
    required this.brand,
    required this.address,
    required this.distanceKm,
    required this.prices,
    this.latitude,
    this.longitude,
    this.isSelfService = false,
    this.phone = '',
    this.operatingHours = '24시간 영업',
    this.amenities = const <StationAmenity>{},
  });

  final String id;
  final String name;
  final StationBrand brand;
  final String address;
  final double distanceKm;
  final Map<FuelType, int> prices;

  final double? latitude;
  final double? longitude;

  final bool isSelfService;
  final String phone;
  final String operatingHours;
  final Set<StationAmenity> amenities;

  bool get hasCoordinates => latitude != null && longitude != null;

  int? priceOf(FuelType type) => prices[type];
}
