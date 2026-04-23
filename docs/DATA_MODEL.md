# DATA_MODEL: 데이터 모델 & API 명세

> 오피넷 공공 API 스펙, 내부 엔티티 모델, Hive 저장 스키마를 정의한다.  
> Cursor에서 모델 코드 생성 시 이 문서를 참조시켜라.

---

## 1. 오피넷 API 개요

### 1.1 API 기본 정보

- **Base URL:** `https://www.opinet.co.kr/api`
- **인증:** API Key (쿼리 파라미터 `code`)
- **응답 포맷:** JSON 또는 XML (기본 XML, `out=json`으로 JSON 요청)
- **발급:** 오피넷 공식 사이트 → 유가정보 API 신청 (심사 1~3일)
- **쿼터:** 무료 기본 일일 500회 내외 (정확한 한도는 발급 시 확인)

### 1.2 주요 엔드포인트

| Endpoint | 용도 | 주요 파라미터 |
|---|---|---|
| `/areaAvgAll.do` | 시도별 평균가격 | `code`, `out=json` |
| `/avgSidoPrice.do` | 시도별 평균 유가 | `code`, `out`, `prodcd` |
| `/avgSigunPrice.do` | 시군구별 평균가격 | `code`, `out`, `prodcd`, `sido` |
| `/lowTop10.do` | 지역별 최저가 TOP10 | `code`, `out`, `prodcd`, `area` |
| `/aroundAll.do` | 반경 내 주유소 조회 ⭐ | `code`, `out`, `x`, `y`, `radius`, `prodcd`, `sort` |
| `/detailById.do` | 주유소 상세 정보 | `code`, `out`, `id` |

### 1.3 유종 코드 (`prodcd`)

| 코드 | 유종 |
|---|---|
| `B027` | 고급휘발유 |
| `B034` | 보통휘발유 |
| `D047` | 경유 |
| `C004` | 실내등유 |
| `K015` | LPG 부탄 |

### 1.4 좌표계 주의사항

- 오피넷 API는 **KATEC 좌표계** 사용 (EPSG:5179)
- Flutter 위치는 **WGS84** (EPSG:4326)
- **변환 필수:** `proj4dart` 패키지로 좌표 변환 로직 구현

```dart
// WGS84 → KATEC 변환 예시
import 'package:proj4dart/proj4dart.dart';

final wgs84 = Projection.WGS84;
final katec = Projection.add(
  'KATEC',
  '+proj=tmerc +lat_0=38 +lon_0=128 +k=0.9999 +x_0=400000 +y_0=600000 +ellps=bessel +units=m +no_defs',
);

Point convertToKatec(double lat, double lng) {
  final point = Point(x: lng, y: lat);
  return wgs84.transform(katec, point);
}
```

---

## 2. 주요 API 상세 명세

### 2.1 반경 내 주유소 조회 (`/aroundAll.do`)

**요청:**
```
GET https://www.opinet.co.kr/api/aroundAll.do
    ?code={API_KEY}
    &x={KATEC_X}
    &y={KATEC_Y}
    &radius={METERS}       // 최대 5000
    &prodcd=B034
    &sort=1                // 1=가격순, 2=거리순
    &out=json
```

**응답:**
```json
{
  "RESULT": {
    "OIL": [
      {
        "UNI_ID": "A0019212",
        "POLL_DIV_CD": "SKE",
        "OS_NM": "뉴서울주유소",
        "PRICE": 1945,
        "DISTANCE": 823.5,
        "GIS_X_COOR": 313458.12,
        "GIS_Y_COOR": 550382.44,
        "ADDR": "서울 강남구 언주로 310",
        "TEL": "02-533-1234",
        "NEW_ADR": "서울 강남구 언주로 310",
        "KPETRO_YN": "N"
      }
    ]
  }
}
```

**필드 매핑:**
| API 필드 | 의미 | DTO 필드 |
|---|---|---|
| `UNI_ID` | 주유소 고유 ID | `id` |
| `POLL_DIV_CD` | 브랜드 코드 (SKE/GSC/HDO/SOL/RTE/RTX/ETC 등) | `brand` |
| `OS_NM` | 주유소명 | `name` |
| `PRICE` | 가격 (원/L) | `price` |
| `DISTANCE` | 거리 (m) | `distance` |
| `GIS_X_COOR` | KATEC X | `x` |
| `GIS_Y_COOR` | KATEC Y | `y` |
| `ADDR` | 주소 | `address` |
| `TEL` | 전화번호 | `tel` |
| `KPETRO_YN` | 알뜰 여부 (Y/N) | `isEconomy` |

### 2.2 주유소 상세 (`/detailById.do`)

**요청:**
```
GET /api/detailById.do?code={KEY}&id={UNI_ID}&out=json
```

**응답에 추가로 포함되는 필드:**
| 필드 | 의미 |
|---|---|
| `GPOLL_DIV_CD` | 자체상표 여부 |
| `CAR_WASH_YN` | 세차장 유무 |
| `MAINT_YN` | 경정비 유무 |
| `CVS_YN` | 편의점 유무 |
| `SELF_YN` | 셀프 여부 |
| `LPG_YN` | LPG 판매 여부 |
| `TEL` | 전화번호 |
| 유종별 가격 | `B027`, `B034`, `D047`, `C004`, `K015` |

### 2.3 브랜드 코드 매핑

| API 코드 | 브랜드 |
|---|---|
| `SKE` | SK에너지 |
| `GSC` | GS칼텍스 |
| `HDO` | 현대오일뱅크 |
| `SOL` | S-OIL |
| `RTE` | 자영알뜰 |
| `RTX` | NH알뜰 |
| `NHO` | NH농협 |
| `ETC` | 자가상표 |
| `E1G` | E1 |
| `SKG` | SK가스 |

---

## 3. 내부 도메인 모델

### 3.1 GasStation (도메인 엔티티)

```dart
@freezed
class GasStation with _$GasStation {
  const factory GasStation({
    required String id,
    required String name,
    required Brand brand,
    required String address,
    required String? tel,
    required double latitude,    // WGS84로 변환 저장
    required double longitude,
    required Map<FuelType, int> prices,  // 유종별 가격
    required double? distanceMeters,
    required StationFeatures features,
    required DateTime updatedAt,
  }) = _GasStation;

  factory GasStation.fromJson(Map<String, dynamic> json) 
      => _$GasStationFromJson(json);
}

@freezed
class StationFeatures with _$StationFeatures {
  const factory StationFeatures({
    required bool isSelf,
    required bool hasCarWash,
    required bool hasMaintenance,
    required bool hasConvenienceStore,
    required bool isEconomy,  // 알뜰주유소
    required bool hasLpg,
  }) = _StationFeatures;
}

enum Brand {
  sk('SKE', 'SK에너지'),
  gs('GSC', 'GS칼텍스'),
  hyundai('HDO', '현대오일뱅크'),
  sOil('SOL', 'S-OIL'),
  economy('RTE', '알뜰주유소'),
  nhEconomy('RTX', 'NH알뜰'),
  nh('NHO', 'NH농협'),
  independent('ETC', '자가상표'),
  unknown('', '기타');

  final String code;
  final String displayName;
  const Brand(this.code, this.displayName);
  
  static Brand fromCode(String code) {
    return Brand.values.firstWhere(
      (b) => b.code == code,
      orElse: () => Brand.unknown,
    );
  }
}

enum FuelType {
  gasoline('B034', '휘발유'),
  premium('B027', '고급휘발유'),
  diesel('D047', '경유'),
  kerosene('C004', '실내등유'),
  lpg('K015', 'LPG');

  final String code;
  final String displayName;
  const FuelType(this.code, this.displayName);
}
```

### 3.2 FuelLog (주유 기록)

```dart
@freezed
class FuelLog with _$FuelLog {
  const factory FuelLog({
    required String id,
    required DateTime timestamp,
    required String? stationId,       // null이면 직접 입력
    required String stationName,
    required FuelType fuelType,
    required int pricePerLiter,
    required int totalAmount,         // 결제 금액 (원)
    required double liters,           // 자동 계산: total / price
    required int? odometer,           // 주행거리 (km, 선택)
    required double? efficiency,      // 연비 (km/L, 자동 계산)
    required String? memo,
  }) = _FuelLog;

  factory FuelLog.fromJson(Map<String, dynamic> json) 
      => _$FuelLogFromJson(json);
}
```

### 3.3 Favorite (즐겨찾기)

```dart
@freezed
class Favorite with _$Favorite {
  const factory Favorite({
    required String stationId,
    required String name,
    required Brand brand,
    required String address,
    required int? lastKnownPrice,
    required DateTime lastCheckedAt,
    required DateTime addedAt,
  }) = _Favorite;
}
```

### 3.4 GovernmentCap (정부 최고가격)

```dart
@freezed
class GovernmentCap with _$GovernmentCap {
  const factory GovernmentCap({
    required int round,              // 차수 (3차 등)
    required Map<FuelType, int> caps,
    required DateTime announcedAt,
    required DateTime effectiveUntil,
  }) = _GovernmentCap;
}

// v1은 하드코딩 상수로 관리
const kCurrentGovernmentCap = GovernmentCap(
  round: 3,
  caps: {
    FuelType.gasoline: 1934,
    FuelType.diesel: 1923,
  },
  announcedAt: DateTime(2026, 4, 10),
  effectiveUntil: DateTime(2026, 5, 31),
);
```

---

## 4. Hive 저장 스키마

### 4.1 Box 설계

| Box 이름 | 타입 | 용도 |
|---|---|---|
| `gas_station_cache` | `Map<String, dynamic>` | 주유소 검색 결과 캐시 (key: 지역 코드 + 유종) |
| `station_detail_cache` | `GasStation` | 주유소 상세 캐시 (key: stationId) |
| `favorites` | `Favorite` | 즐겨찾기 (key: stationId) |
| `fuel_logs` | `FuelLog` | 주유 기록 (key: logId) |
| `app_settings` | 범용 | 설정값 (알림 on/off, 주 사용 유종 등) |

### 4.2 캐시 래퍼 객체

```dart
@freezed
class CachedResult<T> with _$CachedResult<T> {
  const factory CachedResult({
    required T data,
    required DateTime cachedAt,
    required Duration ttl,
  }) = _CachedResult<T>;

  bool get isFresh {
    return DateTime.now().difference(cachedAt) < ttl;
  }
}
```

### 4.3 TypeAdapter 등록

```dart
// main.dart
await Hive.initFlutter();
Hive.registerAdapter(GasStationAdapter());
Hive.registerAdapter(BrandAdapter());
Hive.registerAdapter(FuelTypeAdapter());
Hive.registerAdapter(FuelLogAdapter());
Hive.registerAdapter(FavoriteAdapter());
Hive.registerAdapter(StationFeaturesAdapter());

await Hive.openBox<dynamic>('gas_station_cache');
await Hive.openBox<GasStation>('station_detail_cache');
await Hive.openBox<Favorite>('favorites');
await Hive.openBox<FuelLog>('fuel_logs');
await Hive.openBox('app_settings');
```

---

## 5. Repository 인터페이스 설계

### 5.1 GasStationRepository

```dart
abstract class GasStationRepository {
  /// 반경 내 주유소 조회
  Future<Either<Failure, List<GasStation>>> getNearbyStations({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required FuelType fuelType,
    bool forceRefresh = false,
  });

  /// 주유소 상세
  Future<Either<Failure, GasStation>> getStationDetail(String stationId);

  /// 지역별 주유소 조회 (위치 권한 없을 때)
  Future<Either<Failure, List<GasStation>>> getStationsByRegion({
    required String sido,
    required String? sigungu,
    required FuelType fuelType,
  });

  /// 시도별 평균 가격
  Future<Either<Failure, Map<String, int>>> getAveragePriceBySido(
    FuelType fuelType,
  );
}
```

### 5.2 FavoriteRepository

```dart
abstract class FavoriteRepository {
  Future<List<Favorite>> getAll();
  Future<void> add(Favorite favorite);
  Future<void> remove(String stationId);
  Future<bool> isFavorite(String stationId);
  Stream<List<Favorite>> watchAll();
}
```

### 5.3 FuelLogRepository

```dart
abstract class FuelLogRepository {
  Future<List<FuelLog>> getAll();
  Future<List<FuelLog>> getByMonth(int year, int month);
  Future<void> add(FuelLog log);
  Future<void> update(FuelLog log);
  Future<void> delete(String logId);
  Future<MonthlyStats> getMonthlyStats(int year, int month);
}

@freezed
class MonthlyStats with _$MonthlyStats {
  const factory MonthlyStats({
    required int totalAmount,
    required double totalLiters,
    required int averagePricePerLiter,
    required double? averageEfficiency,
    required int sessionCount,
  }) = _MonthlyStats;
}
```

---

## 6. Riverpod Provider 구조

```dart
// 1. DataSource Provider
@riverpod
OpinetRemoteDataSource opinetDataSource(OpinetDataSourceRef ref) {
  return OpinetRemoteDataSource(ref.watch(dioClientProvider));
}

// 2. Repository Provider
@riverpod
GasStationRepository gasStationRepository(GasStationRepositoryRef ref) {
  return GasStationRepositoryImpl(
    remote: ref.watch(opinetDataSourceProvider),
    local: ref.watch(gasStationLocalDataSourceProvider),
  );
}

// 3. UseCase Provider
@riverpod
GetNearbyStations getNearbyStations(GetNearbyStationsRef ref) {
  return GetNearbyStations(ref.watch(gasStationRepositoryProvider));
}

// 4. 화면 상태 Provider (FutureProvider)
@riverpod
Future<List<GasStation>> nearbyStations(
  NearbyStationsRef ref, {
  required double lat,
  required double lng,
  required FuelType fuelType,
}) async {
  final useCase = ref.watch(getNearbyStationsProvider);
  final result = await useCase(
    lat: lat, 
    lng: lng, 
    radiusMeters: 3000,
    fuelType: fuelType,
  );
  return result.fold(
    (failure) => throw failure,
    (stations) => stations,
  );
}
```

---

## 7. 정부 최고가 비교 로직

```dart
extension PriceComparison on GasStation {
  /// 정부 최고가 대비 차이 (원)
  /// 음수 = 더 저렴, 양수 = 최고가 초과 (위험)
  int priceDiffFromGovCap(FuelType type) {
    final stationPrice = prices[type];
    final cap = kCurrentGovernmentCap.caps[type];
    if (stationPrice == null || cap == null) return 0;
    return stationPrice - cap;
  }
  
  /// 경고 레벨
  PriceWarningLevel warningLevel(FuelType type) {
    final diff = priceDiffFromGovCap(type);
    if (diff > 0) return PriceWarningLevel.exceeded;  // 최고가 초과
    if (diff > -30) return PriceWarningLevel.near;    // 최고가 근접
    return PriceWarningLevel.normal;
  }
}

enum PriceWarningLevel { normal, near, exceeded }
```
