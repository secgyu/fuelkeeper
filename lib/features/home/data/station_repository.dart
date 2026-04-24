import 'package:fuelkeeper/features/home/domain/station.dart';

abstract class StationRepository {
  Future<List<Station>> fetchNearby({double? latitude, double? longitude});
  Future<Station?> fetchById(String id);
}
