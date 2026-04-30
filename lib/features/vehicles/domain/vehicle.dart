import 'package:fuelkeeper/features/home/domain/fuel_type.dart';

class Vehicle {
  const Vehicle({
    required this.id,
    required this.name,
    required this.fuelType,
    this.maker = '',
    this.model = '',
    this.displacementCc,
    this.tankCapacityL,
    this.createdAt,
  });

  final String id;
  final String name;
  final FuelType fuelType;
  final String maker;
  final String model;
  final int? displacementCc;
  final double? tankCapacityL;
  final DateTime? createdAt;

  String get subtitle {
    final parts = <String>[];
    if (maker.isNotEmpty) parts.add(maker);
    if (model.isNotEmpty) parts.add(model);
    if (displacementCc != null) parts.add('${displacementCc}cc');
    return parts.join(' · ');
  }

  Vehicle copyWith({
    String? id,
    String? name,
    FuelType? fuelType,
    String? maker,
    String? model,
    int? displacementCc,
    double? tankCapacityL,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      fuelType: fuelType ?? this.fuelType,
      maker: maker ?? this.maker,
      model: model ?? this.model,
      displacementCc: displacementCc ?? this.displacementCc,
      tankCapacityL: tankCapacityL ?? this.tankCapacityL,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
