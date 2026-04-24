import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';
import 'package:fuelkeeper/features/logs/domain/fuel_log.dart';
import 'package:hive/hive.dart';

class FuelLogAdapter extends TypeAdapter<FuelLog> {
  @override
  final int typeId = 1;

  @override
  FuelLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FuelLog(
      id: fields[0] as String,
      stationId: fields[1] as String,
      stationName: fields[2] as String,
      brand: StationBrand.values[fields[3] as int],
      date: fields[4] as DateTime,
      fuelType: FuelType.values[fields[5] as int],
      pricePerLiter: fields[6] as int,
      liters: fields[7] as double,
      odometerKm: fields[8] as int,
      memo: fields[9] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, FuelLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.stationId)
      ..writeByte(2)
      ..write(obj.stationName)
      ..writeByte(3)
      ..write(obj.brand.index)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.fuelType.index)
      ..writeByte(6)
      ..write(obj.pricePerLiter)
      ..writeByte(7)
      ..write(obj.liters)
      ..writeByte(8)
      ..write(obj.odometerKm)
      ..writeByte(9)
      ..write(obj.memo);
  }
}
