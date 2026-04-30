import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';

abstract class StationRepository {
  Future<List<Station>> fetchNearby({
    required FuelType fuelType,
    double? latitude,
    double? longitude,
    int? radiusMeters,
  });
  Future<Station?> fetchById(String id);

  void clearCache();
}
