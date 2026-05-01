import 'package:fuelkeeper/core/network/opinet_api.dart';
import 'package:fuelkeeper/core/utils/coordinate_converter.dart';
import 'package:fuelkeeper/features/home/data/opinet_codes.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/stats/domain/national_price.dart';
import 'package:fuelkeeper/features/stats/domain/sido.dart';

class NationalStatsRepository {
  NationalStatsRepository({OpinetApi? api}) : _api = api ?? OpinetApi();

  final OpinetApi _api;

  static const _cacheTtl = Duration(minutes: 30);

  final Map<String, _CacheEntry<List<SidoAverage>>> _avgCache = {};
  final Map<String, _CacheEntry<List<LowPriceStation>>> _topCache = {};

  Future<List<SidoAverage>> fetchSidoAverages(FuelType fuelType) async {
    final key = fuelType.name;
    final cached = _avgCache[key];
    if (cached != null && !cached.isExpired) return cached.value;

    final raw = await _api.avgSidoPrice(prodcd: OpinetCodes.prodcdOf(fuelType));
    final result = <SidoAverage>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final code = entry['SIDOCD'] as String?;
      final sido = Sido.fromCode(code);
      final price = _toInt(entry['PRICE']);
      if (sido == null || price == null) continue;
      result.add(SidoAverage(sido: sido, price: price));
    }
    result.sort((a, b) => a.price.compareTo(b.price));
    _avgCache[key] = _CacheEntry(result);
    return result;
  }

  Future<List<LowPriceStation>> fetchLowTop10(
    Sido sido,
    FuelType fuelType,
  ) async {
    final key = '${sido.code}|${fuelType.name}';
    final cached = _topCache[key];
    if (cached != null && !cached.isExpired) return cached.value;

    final raw = await _api.lowTop10(
      area: sido.code,
      prodcd: OpinetCodes.prodcdOf(fuelType),
    );
    final result = <LowPriceStation>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final id = entry['UNI_ID'] as String?;
      final name = entry['OS_NM'] as String?;
      final price = _toInt(entry['PRICE']);
      if (id == null || name == null || price == null) continue;
      final brandCode =
          (entry['POLL_DIV_CD'] ?? entry['POLL_DIV_CO']) as String? ?? '';
      final address = (entry['NEW_ADR'] ?? entry['VAN_ADR'] ?? '') as String;
      final position = _coordinatesOf(entry);
      result.add(
        LowPriceStation(
          id: id,
          name: name,
          brandCode: brandCode,
          address: address,
          price: price,
          latitude: position?.latitude,
          longitude: position?.longitude,
        ),
      );
    }
    result.sort((a, b) => a.price.compareTo(b.price));
    _topCache[key] = _CacheEntry(result);
    return result;
  }

  void clearCache() {
    _avgCache.clear();
    _topCache.clear();
  }

  LatLng? _coordinatesOf(Map entry) {
    final gisX = _toDouble(entry['GIS_X_COOR']);
    final gisY = _toDouble(entry['GIS_Y_COOR']);
    if (gisX == null || gisY == null) return null;
    return CoordinateConverter.katecToWgs84(gisX, gisY);
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) {
      final parsed = double.tryParse(v.trim());
      if (parsed != null) return parsed.round();
    }
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }
}

class _CacheEntry<T> {
  _CacheEntry(this.value) : timestamp = DateTime.now();
  final T value;
  final DateTime timestamp;

  bool get isExpired =>
      DateTime.now().difference(timestamp) > NationalStatsRepository._cacheTtl;
}
