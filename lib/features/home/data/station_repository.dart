import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/domain/station_amenity.dart';
import 'package:fuelkeeper/features/home/domain/station_brand.dart';

class StationRepository {
  Future<List<Station>> fetchNearby() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mock;
  }

  Future<Station?> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final s in _mock) {
      if (s.id == id) return s;
    }
    return null;
  }

  static const _mock = <Station>[
    Station(
      id: 's1',
      name: '강남대로주유소',
      brand: StationBrand.sk,
      address: '서울 강남구 강남대로 358',
      distanceKm: 0.4,
      isSelfService: true,
      phone: '02-555-1894',
      operatingHours: '24시간 영업',
      amenities: {
        StationAmenity.carWash,
        StationAmenity.convenience,
        StationAmenity.nightDiscount,
      },
      prices: {
        FuelType.gasoline: 1894,
        FuelType.premiumGasoline: 2194,
        FuelType.diesel: 1734,
        FuelType.lpg: 1080,
      },
      priceHistory: {
        FuelType.gasoline: [1912, 1908, 1903, 1898, 1898, 1894, 1894],
        FuelType.diesel: [1748, 1745, 1742, 1738, 1736, 1734, 1734],
      },
    ),
    Station(
      id: 's2',
      name: '논현사거리주유소',
      brand: StationBrand.gs,
      address: '서울 강남구 논현로 421',
      distanceKm: 0.7,
      isSelfService: true,
      phone: '02-543-1902',
      operatingHours: '05:00 - 24:00',
      amenities: {StationAmenity.convenience, StationAmenity.maintenance},
      prices: {
        FuelType.gasoline: 1902,
        FuelType.premiumGasoline: 2204,
        FuelType.diesel: 1748,
        FuelType.lpg: 1095,
      },
      priceHistory: {
        FuelType.gasoline: [1918, 1914, 1910, 1908, 1905, 1902, 1902],
      },
    ),
    Station(
      id: 's3',
      name: '역삼중앙주유소',
      brand: StationBrand.hyundai,
      address: '서울 강남구 테헤란로 142',
      distanceKm: 1.1,
      phone: '02-567-1908',
      operatingHours: '24시간 영업',
      amenities: {StationAmenity.carWash, StationAmenity.maintenance},
      prices: {
        FuelType.gasoline: 1908,
        FuelType.premiumGasoline: 2210,
        FuelType.diesel: 1755,
        FuelType.lpg: 1098,
      },
      priceHistory: {
        FuelType.gasoline: [1922, 1918, 1915, 1912, 1910, 1908, 1908],
      },
    ),
    Station(
      id: 's4',
      name: '도곡알뜰주유소',
      brand: StationBrand.economy,
      address: '서울 강남구 남부순환로 2789',
      distanceKm: 1.6,
      isSelfService: true,
      phone: '02-578-1879',
      operatingHours: '05:00 - 23:00',
      amenities: {StationAmenity.convenience},
      prices: {
        FuelType.gasoline: 1879,
        FuelType.premiumGasoline: 2179,
        FuelType.diesel: 1719,
        FuelType.lpg: 1075,
      },
      priceHistory: {
        FuelType.gasoline: [1898, 1895, 1892, 1888, 1884, 1881, 1879],
      },
    ),
    Station(
      id: 's5',
      name: '삼성SK주유소',
      brand: StationBrand.sk,
      address: '서울 강남구 삼성로 521',
      distanceKm: 1.9,
      phone: '02-565-1924',
      operatingHours: '24시간 영업',
      amenities: {
        StationAmenity.carWash,
        StationAmenity.convenience,
        StationAmenity.maintenance,
      },
      prices: {
        FuelType.gasoline: 1924,
        FuelType.premiumGasoline: 2230,
        FuelType.diesel: 1762,
        FuelType.lpg: 1112,
      },
      priceHistory: {
        FuelType.gasoline: [1928, 1928, 1926, 1925, 1925, 1924, 1924],
      },
    ),
    Station(
      id: 's6',
      name: '대치GS칼텍스',
      brand: StationBrand.gs,
      address: '서울 강남구 영동대로 412',
      distanceKm: 2.2,
      isSelfService: true,
      phone: '02-562-1915',
      operatingHours: '24시간 영업',
      amenities: {StationAmenity.nightDiscount, StationAmenity.convenience},
      prices: {
        FuelType.gasoline: 1915,
        FuelType.premiumGasoline: 2218,
        FuelType.diesel: 1758,
        FuelType.lpg: 1102,
      },
      priceHistory: {
        FuelType.gasoline: [1924, 1922, 1920, 1918, 1916, 1915, 1915],
      },
    ),
    Station(
      id: 's7',
      name: '청담S-OIL',
      brand: StationBrand.sOil,
      address: '서울 강남구 학동로 789',
      distanceKm: 2.6,
      phone: '02-549-1932',
      operatingHours: '06:00 - 24:00',
      amenities: {StationAmenity.carWash, StationAmenity.convenience},
      prices: {
        FuelType.gasoline: 1932,
        FuelType.premiumGasoline: 2241,
        FuelType.diesel: 1772,
        FuelType.lpg: 1118,
      },
      priceHistory: {
        FuelType.gasoline: [1930, 1930, 1931, 1932, 1932, 1932, 1932],
      },
    ),
    Station(
      id: 's8',
      name: '신사현대오일뱅크',
      brand: StationBrand.hyundai,
      address: '서울 강남구 도산대로 230',
      distanceKm: 2.9,
      isSelfService: true,
      phone: '02-541-1898',
      operatingHours: '24시간 영업',
      amenities: {StationAmenity.maintenance, StationAmenity.nightDiscount},
      prices: {
        FuelType.gasoline: 1898,
        FuelType.premiumGasoline: 2199,
        FuelType.diesel: 1742,
        FuelType.lpg: 1088,
      },
      priceHistory: {
        FuelType.gasoline: [1908, 1905, 1902, 1900, 1899, 1898, 1898],
      },
    ),
    Station(
      id: 's9',
      name: '압구정S-OIL',
      brand: StationBrand.sOil,
      address: '서울 강남구 언주로 858',
      distanceKm: 3.2,
      phone: '02-512-1949',
      operatingHours: '06:00 - 23:00',
      amenities: {StationAmenity.carWash, StationAmenity.convenience},
      prices: {
        FuelType.gasoline: 1949,
        FuelType.premiumGasoline: 2255,
        FuelType.diesel: 1788,
        FuelType.lpg: 1128,
      },
      priceHistory: {
        FuelType.gasoline: [1944, 1946, 1947, 1948, 1948, 1949, 1949],
      },
    ),
    Station(
      id: 's10',
      name: '개포알뜰주유소',
      brand: StationBrand.economy,
      address: '서울 강남구 개포로 521',
      distanceKm: 3.5,
      isSelfService: true,
      phone: '02-572-1885',
      operatingHours: '05:00 - 23:00',
      amenities: {StationAmenity.convenience},
      prices: {
        FuelType.gasoline: 1885,
        FuelType.premiumGasoline: 2185,
        FuelType.diesel: 1725,
        FuelType.lpg: 1078,
      },
      priceHistory: {
        FuelType.gasoline: [1900, 1898, 1894, 1890, 1887, 1885, 1885],
      },
    ),
  ];
}
