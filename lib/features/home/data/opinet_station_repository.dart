import 'package:fuelkeeper/core/network/opinet_api.dart';
import 'package:fuelkeeper/core/utils/coordinate_converter.dart';
import 'package:fuelkeeper/features/home/data/opinet_codes.dart';
import 'package:fuelkeeper/features/home/data/station_repository.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/domain/station_amenity.dart';

class OpinetStationRepository implements StationRepository {
  OpinetStationRepository({OpinetApi? api}) : _api = api ?? OpinetApi();

  final OpinetApi _api;

  static const _gangnamStation = LatLng(37.4979, 127.0276);
  static const _radiusMeters = 5000;
  static const _cacheTtl = Duration(minutes: 30);

  final Map<String, _CacheEntry<List<Station>>> _nearbyCache = {};
  final Map<String, _CacheEntry<Station>> _detailCache = {};

  @override
  Future<List<Station>> fetchNearby({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? _gangnamStation.latitude;
    final lng = longitude ?? _gangnamStation.longitude;
    final cacheKey =
        '${lat.toStringAsFixed(3)}:${lng.toStringAsFixed(3)}:$_radiusMeters';

    final cached = _nearbyCache[cacheKey];
    if (cached != null && !cached.isExpired) return cached.value;

    final katec = CoordinateConverter.wgs84ToKatec(lat, lng);
    final list = await _api.aroundAll(
      katecX: katec.x,
      katecY: katec.y,
      radius: _radiusMeters,
      prodcd: OpinetCodes.prodcdOf(FuelType.gasoline),
      sort: 1,
    );

    final stations = <Station>[];
    for (final raw in list) {
      if (raw is! Map) continue;
      final station = _mapNearby(raw.cast<String, dynamic>());
      if (station != null) stations.add(station);
    }

    _nearbyCache[cacheKey] = _CacheEntry(stations);
    return stations;
  }

  @override
  Future<Station?> fetchById(String id) async {
    final cached = _detailCache[id];
    if (cached != null && !cached.isExpired) return cached.value;

    final json = await _api.detailById(id);
    if (json == null) return null;

    final detail = _mapDetail(json);
    if (detail != null) _detailCache[id] = _CacheEntry(detail);
    return detail;
  }

  Station? _mapNearby(Map<String, dynamic> json) {
    final id = json['UNI_ID'] as String?;
    final name = json['OS_NM'] as String?;
    if (id == null || name == null) return null;

    final brandCode = (json['POLL_DIV_CD'] ?? json['POLL_DIV_CO']) as String?;
    final brand = OpinetCodes.brandFromCode(brandCode);

    final price = _toInt(json['PRICE']);
    final distance = _toDouble(json['DISTANCE']) ?? 0.0;
    final gisX = _toDouble(json['GIS_X_COOR']);
    final gisY = _toDouble(json['GIS_Y_COOR']);

    LatLng position = _gangnamStation;
    if (gisX != null && gisY != null) {
      position = CoordinateConverter.katecToWgs84(gisX, gisY);
    }

    return Station(
      id: id,
      name: name,
      brand: brand,
      address: '',
      distanceKm: distance / 1000.0,
      latitude: position.latitude,
      longitude: position.longitude,
      prices: price == null ? const {} : {FuelType.gasoline: price},
    );
  }

  Station? _mapDetail(Map<String, dynamic> json) {
    final id = json['UNI_ID'] as String?;
    final name = json['OS_NM'] as String?;
    if (id == null || name == null) return null;

    final brandCode = (json['POLL_DIV_CD'] ?? json['POLL_DIV_CO']) as String?;
    final brand = OpinetCodes.brandFromCode(brandCode);

    final address = (json['NEW_ADR'] ?? json['VAN_ADR'] ?? '') as String;
    final phone = (json['TEL'] ?? '') as String;

    final amenities = <StationAmenity>{};
    if (parseYN(json['CAR_WASH_YN'] as String?)) {
      amenities.add(StationAmenity.carWash);
    }
    if (parseYN(json['MAINT_YN'] as String?)) {
      amenities.add(StationAmenity.maintenance);
    }
    if (parseYN(json['CVS_YN'] as String?)) {
      amenities.add(StationAmenity.convenience);
    }

    final prices = <FuelType, int>{};
    final oilPrice = json['OIL_PRICE'];
    if (oilPrice is List) {
      for (final entry in oilPrice) {
        if (entry is! Map) continue;
        final code = entry['PRODCD'] as String?;
        final price = _toInt(entry['PRICE']);
        final fuelType = OpinetCodes.fuelFromCode(code);
        if (fuelType != null && price != null) {
          prices[fuelType] = price;
        }
      }
    }

    final gisX = _toDouble(json['GIS_X_COOR']);
    final gisY = _toDouble(json['GIS_Y_COOR']);
    LatLng position = _gangnamStation;
    if (gisX != null && gisY != null) {
      position = CoordinateConverter.katecToWgs84(gisX, gisY);
    }

    return Station(
      id: id,
      name: name,
      brand: brand,
      address: address,
      distanceKm: 0.0,
      latitude: position.latitude,
      longitude: position.longitude,
      phone: phone,
      amenities: amenities,
      prices: prices,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class _CacheEntry<T> {
  _CacheEntry(this.value) : timestamp = DateTime.now();
  final T value;
  final DateTime timestamp;

  bool get isExpired =>
      DateTime.now().difference(timestamp) > OpinetStationRepository._cacheTtl;
}
