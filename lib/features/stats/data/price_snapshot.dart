import 'package:fuelkeeper/features/home/domain/fuel_type.dart';

/// 특정 주유소의 특정 날짜 가격 한 건.
///
/// `${stationId}_${yyyymmdd}_${fuelTypeIndex}` 키로 저장되어
/// 같은 날짜에 여러 번 갱신돼도 1건으로 유지된다.
/// 시계열 그래프(1주/1개월/3개월)의 원천 데이터.
class PriceSnapshot {
  const PriceSnapshot({
    required this.stationId,
    required this.fuelType,
    required this.date,
    required this.price,
  });

  final String stationId;
  final FuelType fuelType;

  /// 자정 기준 날짜. 시·분·초는 0으로 정규화한다.
  final DateTime date;
  final int price;

  static String keyOf(String stationId, FuelType fuelType, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final ymd = '${d.year.toString().padLeft(4, '0')}'
        '${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}';
    return '${stationId}_${ymd}_${fuelType.index}';
  }
}
