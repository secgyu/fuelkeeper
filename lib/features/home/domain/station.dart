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
    this.isSelfService = false,
    this.phone = '',
    this.operatingHours = '24시간 영업',
    this.amenities = const <StationAmenity>{},
    this.priceHistory = const <FuelType, List<int>>{},
  });

  final String id;
  final String name;
  final StationBrand brand;
  final String address;
  final double distanceKm;
  final Map<FuelType, int> prices;
  final bool isSelfService;
  final String phone;
  final String operatingHours;
  final Set<StationAmenity> amenities;
  final Map<FuelType, List<int>> priceHistory;

  int? priceOf(FuelType type) => prices[type];

  List<int> historyOf(FuelType type) {
    final explicit = priceHistory[type];
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final current = prices[type];
    if (current == null) return const [];
    return _syntheticHistory(current);
  }

  static List<int> _syntheticHistory(int current) {
    const offsets = [18, 14, 10, 6, 3, 1, 0];
    return [for (final o in offsets) current + o];
  }
}
