import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/vehicles/domain/vehicle.dart';
import 'package:hive/hive.dart';

/// Vehicle을 Hive 박스에 영속화하기 위한 TypeAdapter.
///
/// typeId는 다른 도메인(FuelLog=1)과 겹치지 않게 2를 사용한다.
class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 2;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as String,
      name: fields[1] as String,
      fuelType: FuelType.values[fields[2] as int],
      maker: fields[3] as String? ?? '',
      model: fields[4] as String? ?? '',
      displacementCc: fields[5] as int?,
      tankCapacityL: fields[6] as double?,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fuelType.index)
      ..writeByte(3)
      ..write(obj.maker)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.displacementCc)
      ..writeByte(6)
      ..write(obj.tankCapacityL)
      ..writeByte(7)
      ..write(obj.createdAt);
  }
}
