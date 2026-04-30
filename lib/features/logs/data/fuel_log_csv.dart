import 'package:csv/csv.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';

/// 주유 로그를 CSV로 직렬화/역직렬화한다.
///
/// 필드 순서를 enum 인덱스가 아닌 enum name으로 저장해 enum 정의가 바뀌어도
/// 안전하게 import할 수 있게 한다.
class FuelLogCsv {
  FuelLogCsv._();

  static const headers = <String>[
    'id',
    'station_id',
    'station_name',
    'brand',
    'date_iso',
    'fuel_type',
    'price_per_liter',
    'liters',
    'odometer_km',
    'memo',
    'vehicle_id',
  ];

  static final Csv _codec = Csv(lineDelimiter: '\n');

  static String encode(List<FuelLog> logs) {
    final rows = <List<dynamic>>[headers];
    for (final l in logs) {
      rows.add([
        l.id,
        l.stationId,
        l.stationName,
        l.brand.name,
        l.date.toIso8601String(),
        l.fuelType.name,
        l.pricePerLiter,
        l.liters,
        l.odometerKm,
        l.memo,
        l.vehicleId ?? '',
      ]);
    }
    return _codec.encode(rows);
  }

  /// CSV 문자열을 파싱해 FuelLog 목록을 반환한다.
  ///
  /// 헤더가 일치하지 않거나 필수 필드가 누락되면 [FormatException]을 던진다.
  /// 줄 단위 파싱 실패는 무시하고 가능한 만큼 복원한다.
  static List<FuelLog> decode(String csv) {
    final rows = _codec.decode(csv);
    if (rows.isEmpty) return const [];

    final header = rows.first.map((e) => e.toString()).toList();
    final indexOf = <String, int>{
      for (var i = 0; i < header.length; i++) header[i].trim(): i,
    };

    int? colIndex(String key) => indexOf[key];

    if (colIndex('id') == null ||
        colIndex('station_id') == null ||
        colIndex('date_iso') == null) {
      throw const FormatException('CSV 헤더가 올바르지 않습니다');
    }

    final logs = <FuelLog>[];
    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      try {
        final id = r[colIndex('id')!].toString();
        final stationId = r[colIndex('station_id')!].toString();
        if (id.isEmpty || stationId.isEmpty) continue;

        final brand = _brandByName(r[colIndex('brand')!].toString());
        final fuelType = _fuelByName(r[colIndex('fuel_type')!].toString());
        final date = DateTime.parse(r[colIndex('date_iso')!].toString());
        final price =
            int.tryParse(r[colIndex('price_per_liter')!].toString()) ?? 0;
        final liters =
            double.tryParse(r[colIndex('liters')!].toString()) ?? 0;
        final odometer =
            int.tryParse(r[colIndex('odometer_km')!].toString()) ?? 0;
        final memo = colIndex('memo') != null
            ? r[colIndex('memo')!].toString()
            : '';
        final vehicleIdRaw = colIndex('vehicle_id') != null
            ? r[colIndex('vehicle_id')!].toString()
            : '';

        logs.add(FuelLog(
          id: id,
          stationId: stationId,
          stationName: r[colIndex('station_name')!].toString(),
          brand: brand,
          date: date,
          fuelType: fuelType,
          pricePerLiter: price,
          liters: liters,
          odometerKm: odometer,
          memo: memo,
          vehicleId: vehicleIdRaw.isEmpty ? null : vehicleIdRaw,
        ));
      } catch (_) {
        // 한 줄 깨졌다고 전체 import를 막지 않는다.
      }
    }
    return logs;
  }

  static StationBrand _brandByName(String name) {
    for (final b in StationBrand.values) {
      if (b.name == name) return b;
    }
    return StationBrand.values.first;
  }

  static FuelType _fuelByName(String name) {
    for (final f in FuelType.values) {
      if (f.name == name) return f;
    }
    return FuelType.gasoline;
  }
}
