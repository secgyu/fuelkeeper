# TECH_STACK: FuelKeeper 기술 스택 및 아키텍처

> 기술 선택에는 **선정 이유와 대안 검토**를 함께 기재한다.  
> 면접에서 "왜 이 기술을 선택했나요?"에 답할 수 있어야 한다.

---

## 1. 핵심 스택 한눈에 보기

| 레이어 | 기술 | 버전 | 역할 |
|---|---|---|---|
| **Framework** | Flutter | 3.24+ | 크로스 플랫폼 UI |
| **Language** | Dart | 3.5+ | 로직 구현 |
| **State Management** | Riverpod | 2.5+ | 전역 상태 관리 |
| **Routing** | go_router | 14+ | 선언적 라우팅 |
| **HTTP Client** | dio | 5+ | API 통신 + 인터셉터 |
| **Local DB** | Hive | 2.2+ | 주유 기록, 캐시, 즐겨찾기 |
| **Map** | flutter_naver_map | 1.3+ | 지도 렌더링 |
| **Location** | geolocator | 13+ | GPS 조회 |
| **Notifications** | flutter_local_notifications | 17+ | 로컬 푸시 |
| **Chart** | fl_chart | 0.68+ | 통계 시각화 |
| **Home Widget** | home_widget | 0.6+ | 네이티브 홈 위젯 |
| **Env** | flutter_dotenv | 5+ | API 키 관리 |
| **Freezed** | freezed | 2.5+ | 불변 모델 + Sealed class |
| **JSON** | json_serializable | 6+ | DTO 직렬화 |

---

## 2. 기술 선정 근거

### 2.1 State Management: Riverpod vs Provider vs Bloc

**선택: Riverpod**

| 기준 | Riverpod | Provider | Bloc |
|---|---|---|---|
| 컴파일 타임 안전성 | ✅ | ❌ | ✅ |
| Boilerplate | 중간 | 적음 | 많음 |
| 테스트 용이성 | ✅ | 중간 | ✅ |
| 비동기 처리 (FutureProvider, StreamProvider) | 뛰어남 | 수동 | 중간 |
| 러닝 커브 | 중간 | 낮음 | 높음 |
| 2026 커뮤니티 지지 | 최상 | 하향 | 높음 |

**결정 이유:**
- API 데이터를 FutureProvider로 깔끔하게 캐싱 가능
- Riverpod 2.5+의 `@riverpod` 어노테이션으로 코드 생성 자동화
- Bloc 대비 보일러플레이트가 적어 3주 일정에 적합

**면접 대비 답변 포인트:**
> "오피넷 API 호출 결과를 여러 화면에서 공유해야 했고, 가격 데이터의 TTL 기반 캐싱이 필요했습니다. FutureProvider의 `autoDispose`와 `keepAlive`로 메모리 효율과 데이터 신선도를 동시에 관리할 수 있었습니다."

---

### 2.2 Local DB: Hive vs Drift vs sqflite

**선택: Hive**

**결정 이유:**
- NoSQL 기반이라 주유 기록, 즐겨찾기, 캐시 등 **스키마 자주 변경되는 포트폴리오 프로젝트에 유리**
- SQL 지식 없이 Dart 객체 그대로 저장 가능
- 순수 Dart 구현이라 네이티브 의존성 없음 (빌드 이슈 최소)

**예외:** 월별 통계처럼 복잡한 쿼리가 필요해지면 v2에서 Drift로 마이그레이션 검토

---

### 2.3 지도: 네이버 지도 vs Google Maps vs Kakao Map

**선택: 네이버 지도 (flutter_naver_map)**

| 기준 | 네이버 | Google | Kakao |
|---|---|---|---|
| 국내 도로 정확도 | 최상 | 중간 | 상 |
| 주유소 POI 데이터 | 상 | 중간 | 상 |
| Flutter 공식/커뮤니티 패키지 | 공식 (1.3+) | 공식 | 비공식 |
| 무료 할당량 | 넉넉 | 월 $200 크레딧 | 넉넉 |
| 다크 모드 | ✅ | ✅ | 제한적 |

**결정 이유:**
- 한국 유저 타겟이므로 국내 도로 데이터 정확도가 최우선
- 네이버 클라우드 플랫폼에서 무료 할당량 내 운영 가능

**대안 플랜:** 
- 네이버 API 키 발급이 지연될 경우 Google Maps로 폴백

---

### 2.4 HTTP Client: dio vs http

**선택: dio**

**결정 이유:**
- **인터셉터**로 공통 로깅, 에러 처리, 토큰 주입 한 곳에서 관리
- **CancelToken**으로 화면 전환 시 요청 취소 가능
- 타임아웃 설정이 http 패키지 대비 유연

---

### 2.5 코드 생성: Freezed + json_serializable

**도입 이유:**
- `sealed class` 기반 UI 상태 관리 (Loading / Success / Error)
- `copyWith`, `==`, `hashCode` 자동 생성
- JSON ↔ Dart 객체 매핑 자동화

**면접 어필:**
> "모든 UI 상태를 sealed class로 만들어 타입 안전한 패턴 매칭을 구현했습니다."

---

## 3. 아키텍처

### 3.1 Clean Architecture 간소화 버전

```
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp, 테마, 라우터 설정
│   ├── router.dart              # go_router 설정
│   └── theme.dart               # 컬러, 타이포그래피
│
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart   # 오피넷 API URL
│   │   └── government_cap.dart  # 정부 최고가격 상수
│   ├── errors/
│   │   ├── failures.dart        # Failure sealed class
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── dio_client.dart      # dio 인스턴스 + 인터셉터
│   │   └── api_interceptor.dart
│   ├── storage/
│   │   ├── hive_boxes.dart      # Hive box 이름 상수
│   │   └── hive_init.dart
│   └── utils/
│       ├── distance_calculator.dart
│       └── price_formatter.dart
│
├── features/
│   ├── gas_station/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── gas_station_dto.dart       # API 응답 모델
│   │   │   │   └── gas_station_entity.dart    # 도메인 엔티티
│   │   │   ├── datasources/
│   │   │   │   ├── opinet_remote_datasource.dart
│   │   │   │   └── gas_station_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── gas_station_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── gas_station_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_nearby_stations.dart
│   │   │       └── get_station_detail.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── gas_station_providers.dart  # Riverpod
│   │       ├── pages/
│   │       │   ├── map_page.dart
│   │       │   └── list_page.dart
│   │       └── widgets/
│   │           ├── station_card.dart
│   │           └── price_marker.dart
│   │
│   ├── favorite/
│   ├── fuel_log/
│   ├── statistics/
│   ├── settings/
│   └── onboarding/
│
└── shared/
    ├── widgets/
    │   ├── loading_indicator.dart
    │   ├── error_view.dart
    │   └── empty_state.dart
    └── extensions/
        ├── context_extension.dart
        └── num_extension.dart
```

### 3.2 레이어별 역할

**Presentation Layer:**
- UI, Widget
- Riverpod Provider로 UseCase 호출
- 상태에 따른 화면 렌더링

**Domain Layer:**
- UseCase (비즈니스 로직)
- Repository 추상화 (interface)
- 도메인 엔티티 (Freezed)

**Data Layer:**
- Repository 구현체
- Remote DataSource (dio)
- Local DataSource (Hive)
- DTO ↔ Entity 매핑

### 3.3 데이터 흐름

```
[User Action]
    ↓
[Widget] → watch(Provider)
    ↓
[Provider] → call UseCase
    ↓
[UseCase] → call Repository
    ↓
[Repository]
    ├── Cache hit? → [Local DataSource] → Hive
    └── Cache miss → [Remote DataSource] → 오피넷 API
         ↓
    [DTO] → [Entity 매핑]
         ↓
    [Local DataSource] 캐시 저장
         ↓
    [Repository] → [UseCase] → [Provider] → [Widget 재빌드]
```

---

## 4. 캐싱 전략

### 4.1 TTL 기반 캐시

| 데이터 | TTL | 저장소 |
|---|---|---|
| 주유소 가격 | 30분 | Hive (메모리 + 디스크) |
| 주유소 목록 (지역별) | 30분 | Hive |
| 주유소 상세 정보 | 1시간 | Hive |
| 정부 최고가격 | 24시간 | Hive |

### 4.2 오프라인 폴백

- 네트워크 오류 시 마지막 캐시 반환
- UI에 "마지막 업데이트: N분 전" 뱃지 표시

### 4.3 캐시 무효화

- 설정 화면의 [데이터 새로고침] 버튼으로 수동 무효화
- Pull-to-refresh 제스처로 개별 화면 새로고침

---

## 5. 에러 처리 전략

### 5.1 Failure Sealed Class

```dart
@freezed
sealed class Failure with _$Failure {
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.server(int statusCode, String message) = ServerFailure;
  const factory Failure.cache(String message) = CacheFailure;
  const factory Failure.permission(String message) = PermissionFailure;
  const factory Failure.location() = LocationFailure;
  const factory Failure.unknown(String message) = UnknownFailure;
}
```

### 5.2 UI에서의 처리

- Network Error → 재시도 버튼 + 캐시 폴백
- Permission Error → 설정 앱으로 이동하는 CTA
- Location Error → 수동 지역 선택 화면으로 이동

---

## 6. 패키지 의존성 (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State & Routing
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0
  
  # Network
  dio: ^5.4.0
  retrofit: ^4.1.0  # 선택적, 타입 안전한 API 정의
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # Map & Location
  flutter_naver_map: ^1.3.0
  geolocator: ^13.0.1
  
  # Notifications & Home Widget
  flutter_local_notifications: ^17.2.2
  home_widget: ^0.6.0
  
  # Chart
  fl_chart: ^0.68.0
  
  # Code Generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  
  # Utils
  intl: ^0.19.0
  url_launcher: ^6.3.0
  flutter_dotenv: ^5.1.0

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  hive_generator: ^2.0.1
  
  # Lint & Test
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4
```

---

## 7. 빌드 & 배포

### 7.1 Android APK 빌드

```bash
flutter build apk --release --dart-define-from-file=.env.production
```

- 배포 채널: **Firebase App Distribution** 무료 (또는 GitHub Release)
- 서명: `keystore` 생성 후 `key.properties`로 관리 (gitignore)

### 7.2 iOS 지원 (v2)

v1에서는 Apple Developer 미가입으로 제외.  
데모 영상만 시뮬레이터로 촬영.

---

## 8. 품질 도구

### 8.1 Lint

- `flutter_lints` 기본 + 자체 룰 추가
- `analysis_options.yaml`에 unused_import, prefer_const 등 강제

### 8.2 테스트

**최소 요구:**
- [ ] UseCase 단위 테스트 (최소 5개)
- [ ] Repository 테스트 (mocktail로 DataSource 모킹)
- [ ] Widget 테스트 (StationCard 등 재사용 컴포넌트)

**이유:** 포폴에 테스트 커버리지를 언급하면 "기본기 갖춘 개발자" 인상 제공.

### 8.3 CI/CD (선택)

GitHub Actions로 PR 생성 시:
- `flutter analyze`
- `flutter test`
- APK 빌드 (main 브랜치 머지 시)

---

## 9. 보안 & 개인정보

### 9.1 API 키 관리

- 오피넷 API 키는 `.env` 파일로 분리 (gitignore)
- 빌드 시 `--dart-define`으로 주입
- GitHub Secrets에 저장

### 9.2 사용자 데이터

- 위치 정보: 기기 내 처리, 서버 전송 없음
- 주유 기록: 로컬 Hive에만 저장
- 분석 도구: Firebase Analytics 선택 (민감 정보 제외)

---

## 10. 면접 대비 핵심 토킹 포인트

1. **"왜 Flutter인가"** → 크로스 플랫폼, 빠른 프로토타이핑, iOS 대응 준비
2. **"왜 Riverpod인가"** → 컴파일 타임 안전성, FutureProvider 캐싱
3. **"캐싱 전략"** → TTL 기반 + 오프라인 폴백 + Pull-to-refresh
4. **"홈 위젯 구현"** → Flutter ↔ Android 네이티브(Kotlin) 브릿지 경험
5. **"Clean Architecture"** → 3-layer 구조로 테스트 용이성 확보
6. **"에러 처리"** → Failure sealed class로 타입 안전한 분기
