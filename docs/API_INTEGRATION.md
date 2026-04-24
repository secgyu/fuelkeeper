# API_INTEGRATION: 오피넷 API 연동 가이드

> **이 문서는 실제 API 테스트 결과를 바탕으로 작성됨 (2026-04-22 검증 완료)**  
> Cursor에서 API 연동 코드를 작성할 때 이 문서를 반드시 참조할 것.

---

## 🔑 기본 정보

### Base URL
```
https://www.opinet.co.kr/api
```

### 인증
- **인증 방식:** 쿼리 파라미터 `certkey`
- ⚠️ **주의: `code` 아님! `certkey`가 정확한 파라미터 이름**
- 공식 문서 일부에 `code`라고 표기된 부분이 있으나 **틀렸음**

### 응답 포맷
- 기본: XML
- JSON으로 받으려면 **`out=json`** 필수
- Flutter 프로젝트는 **항상 `out=json` 사용**

### 쿼터 (검증 완료)
- **일일 1,500건** (매일 자정 리셋)
- 빈 응답도 카운트됨
- **30분 TTL 캐싱으로 호출 최소화 필수**

---

## 📋 사용하는 5개 API 전체 목록

| # | API 이름 | 엔드포인트 | 용도 | 관련 기능 |
|---|---|---|---|---|
| 1 | **반경 내 주유소** | `/aroundAll.do` | 지도 탐색, 리스트 뷰 | F-01, F-02 |
| 2 | **주유소 상세정보** | `/detailById.do` | 상세 화면 | F-03 |
| 3 | **지역별 최저가 TOP10** | `/lowTop10.do` | 지역 선택, 홈 위젯 | F-08, F-09 |
| 4 | **시도별 평균가격** | `/avgSidoPrice.do` | 상단 배너 | F-12 |
| 5 | **지역 코드** | `/areaCode.do` | 지역 드롭다운 | F-09 |

---

## 🎯 API 1: 반경 내 주유소 (`/aroundAll.do`)

### 용도
현재 위치 기반 주변 주유소 조회 (F-01 지도 기능의 핵심)

### 요청 URL
```
GET https://www.opinet.co.kr/api/aroundAll.do
```

### 필수 파라미터
| 파라미터 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `certkey` | string | 인증키 | `Jod8qcDj...` |
| `out` | string | 응답 포맷 | `json` |
| `x` | double | KATEC X 좌표 | `314871.8` |
| `y` | double | KATEC Y 좌표 | `544012.0` |
| `radius` | int | 반경 (m, 최대 5000) | `3000` |
| `prodcd` | string | 유종 코드 | `B034` |
| `sort` | int | 정렬 (1=가격순, 2=거리순) | `1` |

### 실제 요청 예시
```
https://www.opinet.co.kr/api/aroundAll.do?out=json&x=314871&y=544012&radius=3000&prodcd=B034&sort=1&certkey={API_KEY}
```

### 실제 응답 샘플 (검증 완료)
```json
{
  "RESULT": {
    "OIL": [
      {
        "UNI_ID": "A0009861",
        "POLL_DIV_CD": "SOL",
        "OS_NM": "오토테크주유소",
        "PRICE": 2295,
        "DISTANCE": 1379.5,
        "GIS_X_COOR": 313775.43118,
        "GIS_Y_COOR": 543172.19675
      },
      {
        "UNI_ID": "A0010207",
        "POLL_DIV_CD": "SKE",
        "OS_NM": "SK서광주유소",
        "PRICE": 2450,
        "DISTANCE": 0.0,
        "GIS_X_COOR": 314871.80000,
        "GIS_Y_COOR": 544012.00000
      }
    ]
  }
}
```

### 응답 필드 설명
| 필드 | 타입 | 설명 | 주의사항 |
|---|---|---|---|
| `UNI_ID` | string | 주유소 고유 ID | 상세 API 호출 시 사용 |
| `POLL_DIV_CD` | string | 브랜드 코드 | ⚠️ `CD`이지 `CO`가 아님 |
| `OS_NM` | string | 상호명 | |
| `PRICE` | int | 가격 (원) | 판매가 |
| `DISTANCE` | double | 거리 (미터) | 사용자 좌표 기준 |
| `GIS_X_COOR` | double | KATEC X | WGS84 변환 필요 |
| `GIS_Y_COOR` | double | KATEC Y | WGS84 변환 필요 |

### ⚠️ 정렬 주의
- `sort=1`이 "가격순"이라고 문서에 있지만, **실제로는 거리+가격 혼합 정렬**
- Flutter 클라이언트에서 **반드시 재정렬 로직 구현**

---

## 🎯 API 2: 주유소 상세정보 (`/detailById.do`)

### 용도
특정 주유소 ID로 상세 정보 조회 (F-03 상세 화면)

### 요청 URL
```
GET https://www.opinet.co.kr/api/detailById.do
```

### 필수 파라미터
| 파라미터 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `certkey` | string | 인증키 | `Jod8qcDj...` |
| `out` | string | 응답 포맷 | `json` |
| `id` | string | 주유소 ID | `A0010207` |

### 실제 요청 예시
```
https://www.opinet.co.kr/api/detailById.do?out=json&id=A0010207&certkey={API_KEY}
```

### 실제 응답 샘플 (검증 완료)
```json
{
  "RESULT": {
    "OIL": [
      {
        "UNI_ID": "A0010207",
        "POLL_DIV_CO": "SKE",
        "GPOLL_DIV_CO": " ",
        "OS_NM": "SK서광주유소",
        "VAN_ADR": "서울 강남구 역삼동 834-47",
        "NEW_ADR": "서울 강남구 역삼로 142",
        "TEL": "02-562-4855",
        "SIGUNCD": "0113",
        "LPG_YN": "N",
        "MAINT_YN": "Y",
        "CAR_WASH_YN": "Y",
        "KPETRO_YN": "N",
        "CVS_YN": "N",
        "GOOD_YN": "Y",
        "GIS_X_COOR": 314871.80000,
        "GIS_Y_COOR": 544012.00000,
        "OIL_PRICE": [
          {"PRODCD": "B027", "PRICE": 2040, "TRADE_DT": "20260422", "TRADE_TM": "173342"},
          {"PRODCD": "B034", "PRICE": 2450, "TRADE_DT": "20260422", "TRADE_TM": "173343"},
          {"PRODCD": "D047", "PRICE": 1990, "TRADE_DT": "20260422", "TRADE_TM": "173343"}
        ]
      }
    ]
  }
}
```

### ⚠️ 중요 이슈: 필드명 불일치

**상세 API는 `POLL_DIV_CO`로 오지만, 반경 API는 `POLL_DIV_CD`로 옴!**

두 API를 모두 사용해야 하므로 DTO에서 양쪽 다 처리해야 함:

```dart
factory GasStationDto.fromJson(Map<String, dynamic> json) {
  return GasStationDto(
    id: json['UNI_ID'] as String,
    // POLL_DIV_CD 또는 POLL_DIV_CO 둘 다 처리
    brandCode: (json['POLL_DIV_CD'] ?? json['POLL_DIV_CO']) as String,
    // ... 나머지 필드
  );
}
```

### 부가 서비스 필드 (Y/N 문자열)
| 필드 | 의미 |
|---|---|
| `LPG_YN` | LPG 판매 여부 |
| `MAINT_YN` | 경정비 시설 |
| `CAR_WASH_YN` | 세차장 |
| `CVS_YN` | 편의점 |
| `KPETRO_YN` | 품질인증 주유소 |
| `GOOD_YN` | 우수 주유소 |

**Dart에서 변환:**
```dart
bool parseYN(String? value) => value?.toUpperCase() == 'Y';
```

### 유종별 가격 배열 처리
`OIL_PRICE`는 배열이며, 주유소가 판매하는 유종만 포함됨:
```dart
Map<FuelType, int> parseOilPrices(List<dynamic> oilPriceJson) {
  final map = <FuelType, int>{};
  for (final item in oilPriceJson) {
    final prodcd = item['PRODCD'] as String;
    final price = item['PRICE'] as int;
    final fuelType = FuelType.fromCode(prodcd);
    if (fuelType != null) map[fuelType] = price;
  }
  return map;
}
```

---

## 🎯 API 3: 지역별 최저가 TOP10 (`/lowTop10.do`)

### 용도
특정 지역의 최저가 주유소 TOP 10 (F-08 홈 위젯, F-09 지역 선택)

### 요청 URL
```
GET https://www.opinet.co.kr/api/lowTop10.do
```

### 필수 파라미터
| 파라미터 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `certkey` | string | 인증키 | |
| `out` | string | 응답 포맷 | `json` |
| `prodcd` | string | 유종 코드 | `B034` |
| `area` | string | 지역 코드 (시도) | `16` (부산) |

### 지역 코드 (시도)
| 코드 | 지역 |
|---|---|
| `01` | 서울 |
| `02` | 경기 |
| `03` | 강원 |
| `04` | 충북 |
| `05` | 충남 |
| `06` | 전북 |
| `07` | 전남 |
| `08` | 경북 |
| `09` | 경남 |
| `10` | 부산 |
| `11` | 제주 |
| `14` | 대구 |
| `15` | 인천 |
| `16` | 광주 |
| `17` | 대전 |
| `18` | 울산 |
| `19` | 세종 |

---

## 🎯 API 4: 시도별 평균가격 (`/avgSidoPrice.do`)

### 용도
시도별 평균 유가 조회 (F-12 정부 최고가 배너, 홈 상단 배너)

### 요청 URL
```
GET https://www.opinet.co.kr/api/avgSidoPrice.do
```

### 필수 파라미터
| 파라미터 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `certkey` | string | 인증키 | |
| `out` | string | 응답 포맷 | `json` |
| `prodcd` | string | 유종 코드 | `B034` |

### 응답 구조 (예상)
```json
{
  "RESULT": {
    "OIL": [
      {"SIDOCD": "01", "SIDONAME": "서울", "PRICE": 2026.0, "DIFF": 2.3},
      {"SIDOCD": "10", "SIDONAME": "부산", "PRICE": 1995.0, "DIFF": -1.2}
    ]
  }
}
```

⚠️ 실제 응답은 테스트 후 이 문서에 업데이트 필요

---

## 🎯 API 5: 지역 코드 (`/areaCode.do`)

### 용도
시군구 지역 코드 조회 (F-09 수동 지역 선택)

### 요청 URL
```
GET https://www.opinet.co.kr/api/areaCode.do
```

### 필수 파라미터
| 파라미터 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `certkey` | string | 인증키 | |
| `out` | string | 응답 포맷 | `json` |
| `area` | string | 시도 코드 | `10` (부산) |

### 응답 구조 (예상)
```json
{
  "RESULT": {
    "OIL": [
      {"AREA_CD": "1001", "AREA_NM": "강서구"},
      {"AREA_CD": "1002", "AREA_NM": "금정구"}
    ]
  }
}
```

---

## 🔄 좌표 변환 (KATEC ↔ WGS84)

### 왜 필요한가
- Flutter `geolocator`는 **WGS84** (일반 위도/경도) 반환
- 오피넷 API는 **KATEC** 요구
- 반드시 변환 필요

### 패키지
```yaml
dependencies:
  proj4dart: ^2.1.0
```

### 구현 예시
```dart
// lib/core/utils/coordinate_converter.dart
import 'package:proj4dart/proj4dart.dart';

class CoordinateConverter {
  static final _wgs84 = Projection.WGS84;
  static final _katec = Projection.add(
    'KATEC',
    '+proj=tmerc +lat_0=38 +lon_0=128 +k=0.9999 '
    '+x_0=400000 +y_0=600000 +ellps=bessel +units=m +no_defs',
  );

  /// WGS84 (lat, lng) → KATEC (x, y)
  static Point wgs84ToKatec(double lat, double lng) {
    final point = Point(x: lng, y: lat);
    return _wgs84.transform(_katec, point);
  }

  /// KATEC (x, y) → WGS84 (lat, lng)
  static Point katecToWgs84(double x, double y) {
    final point = Point(x: x, y: y);
    return _katec.transform(_wgs84, point);
  }
}
```

### 검증된 좌표 샘플 (테스트용)
| 위치 | WGS84 (lat, lng) | KATEC (x, y) |
|---|---|---|
| 강남역 (서울) | 37.4979, 127.0276 | 314871, 544012 |
| 부산 대연동 | 35.1350, 129.1017 | 약 422700, 258500 |

---

## 📐 Dio 설정

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://www.opinet.co.kr/api',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
  queryParameters: {
    'out': 'json',  // 모든 요청에 자동 추가
    'certkey': dotenv.env['OPINET_API_KEY']!,
  },
));

// 로깅 인터셉터
dio.interceptors.add(LogInterceptor(
  request: true,
  requestBody: false,
  responseBody: true,
  error: true,
));
```

---

## ❌ 에러 처리

### 공통 에러 패턴
| 상황 | 응답 | 대응 |
|---|---|---|
| 인증키 오류 | `{"RESULT":{"OIL":[]}}` (빈 배열) | 로컬 캐시 + 에러 토스트 |
| 좌표 범위 밖 | 빈 배열 | 반경 확장 또는 지역 선택 유도 |
| 네트워크 오류 | DioException | 재시도 + 캐시 폴백 |
| 쿼터 초과 | TBD (확인 필요) | 다음 날까지 캐시만 사용 |

### 빈 응답 처리

**주의: 오피넷은 에러가 나도 HTTP 200 + 빈 배열을 반환할 수 있음!**

```dart
if (response.data['RESULT']['OIL'] is! List ||
    (response.data['RESULT']['OIL'] as List).isEmpty) {
  throw const Failure.emptyResult();
}
```

---

## 💾 캐싱 전략

### TTL 테이블
| API | TTL | 근거 |
|---|---|---|
| 반경 내 주유소 | 30분 | 가격 변동 빈도 |
| 주유소 상세 | 1시간 | 부가 서비스는 거의 안 변함 |
| 지역별 최저가 | 30분 | 동일 |
| 시도별 평균 | 6시간 | 일일 집계 데이터 |
| 지역 코드 | 30일 | 행정구역 거의 안 바뀜 |

### Hive 캐시 키 규칙
```dart
// 반경 API: 좌표 + 반경 + 유종
'nearby:{x}:{y}:{radius}:{fuelType}'

// 상세: 주유소 ID
'detail:{stationId}'

// 지역별: 시도 코드 + 유종
'regional:{areaCode}:{fuelType}'

// 평균: 유종
'average:{fuelType}'

// 지역코드: 시도 코드
'areacode:{areaCode}'
```

---

## 🧪 Mock DataSource (개발 중 쿼터 절약)

개발 중에는 실제 API 호출 없이 Mock으로 개발하는 것을 강력 권장:

```dart
// lib/features/gas_station/data/datasources/mock_opinet_datasource.dart
import 'package:flutter/services.dart';

class MockOpinetDataSource implements OpinetRemoteDataSource {
  @override
  Future<List<GasStationDto>> getNearbyStations({
    required double x,
    required double y,
    required int radius,
    required String prodcd,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
    final jsonString = await rootBundle.loadString('assets/mock/nearby_stations.json');
    final json = jsonDecode(jsonString);
    return (json['RESULT']['OIL'] as List)
        .map((e) => GasStationDto.fromJson(e))
        .toList();
  }
}

// Riverpod에서 환경별 분기
@riverpod
OpinetRemoteDataSource opinetDataSource(Ref ref) {
  const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);
  if (useMock) {
    return MockOpinetDataSource();
  }
  return RealOpinetDataSource(ref.watch(dioProvider));
}
```

### 실행 시 환경 변수로 전환
```bash
# 개발 중 (Mock)
flutter run

# 실제 API 테스트
flutter run --dart-define=USE_MOCK=false
```

---

## 📁 Mock JSON 파일 (이미 검증된 실제 응답)

아래 JSON들을 `assets/mock/` 폴더에 저장:

### `assets/mock/nearby_stations.json`
실제 2026-04-22 강남역 반경 3km 응답 (위 API 1 실제 응답 샘플)

### `assets/mock/station_detail.json`
실제 SK서광주유소(A0010207) 응답 (위 API 2 실제 응답 샘플)

---

## ✅ 체크리스트

API 연동 구현 시 이 체크리스트를 확인:

- [ ] `.env`에 `OPINET_API_KEY` 설정
- [ ] `pubspec.yaml`에 `dio`, `proj4dart`, `flutter_dotenv` 추가
- [ ] Dio BaseOptions에 `certkey`와 `out=json` 자동 주입
- [ ] `CoordinateConverter` 유틸 클래스 구현
- [ ] `GasStationDto.fromJson`에서 `POLL_DIV_CD`/`POLL_DIV_CO` 양쪽 처리
- [ ] 빈 응답 체크 로직 추가
- [ ] Hive 캐시 레이어 구현
- [ ] Mock DataSource로 먼저 UI 개발
- [ ] 실제 호출은 배포 직전에만

---

## 📞 문의

- 오피넷 데이터 문의: price@knoc.co.kr / 052-216-2514
- 쿼터 증설 문의: 052-216-2508
