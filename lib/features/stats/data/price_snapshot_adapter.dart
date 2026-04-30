import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/stats/data/price_snapshot.dart';
import 'package:hive/hive.dart';

class PriceSnapshotAdapter extends TypeAdapter<PriceSnapshot> {
  @override
  final int typeId = 3;

  @override
  PriceSnapshot read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return PriceSnapshot(
      stationId: fields[0] as String,
      fuelType: FuelType.values[fields[1] as int],
      date: fields[2] as DateTime,
      price: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PriceSnapshot obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.stationId)
      ..writeByte(1)
      ..write(obj.fuelType.index)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.price);
  }
}
