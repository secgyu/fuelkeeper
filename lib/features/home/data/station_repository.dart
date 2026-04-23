import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';

class StationRepository {
  Future<List<Station>> fetchNearby() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mock;
  }

  static const _mock = <Station>[
    Station(
      id: 's1',
      name: '강남대로주유소',
      brand: StationBrand.sk,
      address: '서울 강남구 강남대로 358',
      distanceKm: 0.4,
      isSelfService: true,
      prices: {
        FuelType.gasoline: 1894,
        FuelType.premiumGasoline: 2194,
        FuelType.diesel: 1734,
        FuelType.lpg: 1080,
      },
    ),
    Station(
      id: 's2',
      name: '논현사거리주유소',
      brand: StationBrand.gs,
      address: '서울 강남구 논현로 421',
      distanceKm: 0.7,
      isSelfService: true,
      prices: {
        FuelType.gasoline: 1902,
        FuelType.premiumGasoline: 2204,
        FuelType.diesel: 1748,
        FuelType.lpg: 1095,
      },
    ),
    Station(
      id: 's3',
      name: '역삼중앙주유소',
      brand: StationBrand.hyundai,
      address: '서울 강남구 테헤란로 142',
      distanceKm: 1.1,
      isSelfService: false,
      prices: {
        FuelType.gasoline: 1908,
        FuelType.premiumGasoline: 2210,
        FuelType.diesel: 1755,
        FuelType.lpg: 1098,
      },
    ),
    Station(
      id: 's4',
      name: '도곡알뜰주유소',
      brand: StationBrand.economy,
      address: '서울 강남구 남부순환로 2789',
      distanceKm: 1.6,
      isSelfService: true,
      prices: {
        FuelType.gasoline: 1879,
        FuelType.premiumGasoline: 2179,
        FuelType.diesel: 1719,
        FuelType.lpg: 1075,
      },
    ),
    Station(
      id: 's5',
      name: '삼성SK주유소',
      brand: StationBrand.sk,
      address: '서울 강남구 삼성로 521',
      distanceKm: 1.9,
      isSelfService: false,
      prices: {
        FuelType.gasoline: 1924,
        FuelType.premiumGasoline: 2230,
        FuelType.diesel: 1762,
        FuelType.lpg: 1112,
      },
    ),
    Station(
      id: 's6',
      name: '대치GS칼텍스',
      brand: StationBrand.gs,
      address: '서울 강남구 영동대로 412',
      distanceKm: 2.2,
      isSelfService: true,
      prices: {
        FuelType.gasoline: 1915,
        FuelType.premiumGasoline: 2218,
        FuelType.diesel: 1758,
        FuelType.lpg: 1102,
      },
    ),
    Station(
      id: 's7',
      name: '청담S-OIL',
      brand: StationBrand.sOil,
      address: '서울 강남구 학동로 789',
      distanceKm: 2.6,
      isSelfService: false,
      prices: {
        FuelType.gasoline: 1932,
        FuelType.premiumGasoline: 2241,
        FuelType.diesel: 1772,
        FuelType.lpg: 1118,
      },
    ),
    Station(
      id: 's8',
      name: '신사현대오일뱅크',
      brand: StationBrand.hyundai,
      address: '서울 강남구 도산대로 230',
      distanceKm: 2.9,
      isSelfService: true,
      prices: {
        FuelType.gasoline: 1898,
        FuelType.premiumGasoline: 2199,
        FuelType.diesel: 1742,
        FuelType.lpg: 1088,
      },
    ),
    Station(
      id: 's9',
      name: '압구정S-OIL',
      brand: StationBrand.sOil,
      address: '서울 강남구 언주로 858',
      distanceKm: 3.2,
      isSelfService: false,
      prices: {
        FuelType.gasoline: 1949,
        FuelType.premiumGasoline: 2255,
        FuelType.diesel: 1788,
        FuelType.lpg: 1128,
      },
    ),
    Station(
      id: 's10',
      name: '개포알뜰주유소',
      brand: StationBrand.economy,
      address: '서울 강남구 개포로 521',
      distanceKm: 3.5,
      isSelfService: true,
      prices: {
        FuelType.gasoline: 1885,
        FuelType.premiumGasoline: 2185,
        FuelType.diesel: 1725,
        FuelType.lpg: 1078,
      },
    ),
  ];
}
