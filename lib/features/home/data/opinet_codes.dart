import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';

class OpinetCodes {
  OpinetCodes._();

  static const Map<String, StationBrand> _brandFromCode = {
    'SKE': StationBrand.sk,
    'GSC': StationBrand.gs,
    'HDO': StationBrand.hyundai,
    'SOL': StationBrand.sOil,
    'RTO': StationBrand.economy,
    'RTX': StationBrand.economy,
    'NHO': StationBrand.economy,
    'E1G': StationBrand.economy,
    'SKG': StationBrand.economy,
    'ETC': StationBrand.economy,
  };

  static StationBrand brandFromCode(String? code) {
    if (code == null) return StationBrand.economy;
    return _brandFromCode[code.trim().toUpperCase()] ?? StationBrand.economy;
  }

  static const Map<FuelType, String> fuelToProdcd = {
    FuelType.gasoline: 'B027',
    FuelType.premiumGasoline: 'B034',
    FuelType.diesel: 'D047',
    FuelType.lpg: 'K015',
  };

  static const Map<String, FuelType> _fuelFromCode = {
    'B027': FuelType.gasoline,
    'B034': FuelType.premiumGasoline,
    'D047': FuelType.diesel,
    'K015': FuelType.lpg,
  };

  static FuelType? fuelFromCode(String? code) {
    if (code == null) return null;
    return _fuelFromCode[code.trim().toUpperCase()];
  }

  static String prodcdOf(FuelType type) => fuelToProdcd[type]!;
}

bool parseYN(String? value) => value?.trim().toUpperCase() == 'Y';
