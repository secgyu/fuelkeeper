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
    );
  }
}
