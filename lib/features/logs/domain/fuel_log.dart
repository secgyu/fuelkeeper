import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';

class FuelLog {
  const FuelLog({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.brand,
    required this.date,
    required this.fuelType,
    required this.pricePerLiter,
    required this.liters,
    required this.odometerKm,
    this.memo = '',
    this.vehicleId,
  });

  final String id;
  final String stationId;
  final String stationName;
  final StationBrand brand;
  final DateTime date;
  final FuelType fuelType;
  final int pricePerLiter;
  final double liters;
  final int odometerKm;
  final String memo;

  /// 어떤 차량으로 주유한 기록인지. 다중 차량 지원을 위해 추가됐다.
  /// 차량 도입 이전에 작성된 로그는 null이며, 통계에서 "전체" 또는
  /// 사용자가 명시적으로 매칭한 차량 기준으로 다뤄진다.
  final String? vehicleId;

  int get totalCost => (pricePerLiter * liters).round();

  FuelLog copyWith({
    String? id,
    String? stationId,
    String? stationName,
    StationBrand? brand,
    DateTime? date,
    FuelType? fuelType,
    int? pricePerLiter,
    double? liters,
    int? odometerKm,
    String? memo,
    String? vehicleId,
  }) {
    return FuelLog(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      brand: brand ?? this.brand,
      date: date ?? this.date,
      fuelType: fuelType ?? this.fuelType,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      liters: liters ?? this.liters,
      odometerKm: odometerKm ?? this.odometerKm,
      memo: memo ?? this.memo,
      vehicleId: vehicleId ?? this.vehicleId,
    );
  }
}
