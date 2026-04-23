# DEVELOPMENT_PLAN: 3주 개발 일정

> 하루 평균 5시간 투입 기준. 주말은 보수적으로 3시간으로 계산.  
> 각 Task는 Cursor에서 한 세션 내에 완료 가능한 크기로 쪼개져 있다.

---

## 전체 일정 개요

| 주차 | 기간 | 주요 목표 | 산출물 |
|---|---|---|---|
| **Week 0 (준비)** | 1~2일 | 환경 설정 + API Key 발급 | 프로젝트 초기 구조 |
| **Week 1** | 7일 | 핵심 기능 (지도, 리스트, 상세, API 연동) | 지도+리스트 동작 |
| **Week 2** | 7일 | 즐겨찾기, 주유 기록, 통계, 설정 | 모든 P0 기능 완료 |
| **Week 3** | 7일 | 홈 위젯, 알림, 폴리싱, 배포, 포폴 | APK + 포폴 PDF |

---

## Week 0: 준비 단계 (2일)

### Day 0-1: 프로젝트 셋업

**Task 0-1-1: 오피넷 API 신청 (반드시 가장 먼저)**
- 오피넷 홈페이지 → 유가정보 API 신청
- 심사 기간 1~3일이므로 프로젝트 착수 전날 신청
- **대안:** 공공데이터포털에서도 동일 API 제공 → 즉시 발급

**Task 0-1-2: Flutter 프로젝트 생성**
```bash
flutter create fuelkeeper --org com.yourname --platforms android
cd fuelkeeper
```

**Task 0-1-3: 네이버 클라우드 플랫폼 가입 + Maps API 키 발급**
- 네이버 Cloud Platform → Maps API → Web Dynamic Map + Geocoding

**Task 0-1-4: 기본 패키지 설치**
- `pubspec.yaml`에 TECH_STACK.md의 의존성 전부 추가
- `flutter pub get`

**Task 0-1-5: 프로젝트 폴더 구조 잡기**
- TECH_STACK.md의 Clean Architecture 구조대로 폴더만 먼저 생성

**Task 0-1-6: GitHub 리포 생성 + 초기 커밋**
- README.md 기본 내용 작성
- .gitignore (.env 추가)

### Day 0-2: 기반 코드 작성

**Task 0-2-1: 테마 & 디자인 토큰 정의**
- `lib/app/theme.dart`에 AppColors, AppTypography, AppSpacing 정의 (UI_FLOW.md 참조)
- MaterialApp에 적용

**Task 0-2-2: Hive 초기화**
- `main.dart`에서 Hive.initFlutter()
- TypeAdapter 자리 마련 (모델 생성 후 채움)

**Task 0-2-3: dio 클라이언트 셋업**
- `core/network/dio_client.dart`에 Dio 인스턴스 생성
- 인터셉터: 로깅, 에러 처리, 타임아웃
- Base URL: `https://www.opinet.co.kr/api`

**Task 0-2-4: go_router 기본 라우팅 구조**
- 라우트: `/splash`, `/onboarding`, `/home`, `/detail/:id`, `/favorites`, `/logs`, `/stats`, `/settings`
- ShellRoute로 BottomNav 구성

**🚦 Checkpoint 0:** `flutter run` 시 빈 홈 화면 뜨면 OK

---

## Week 1: 핵심 기능 (지도 + API + 상세)

### Day 1-1: 도메인 모델 작성 (월)

**Task 1-1-1: Freezed 모델 정의**
- `GasStation`, `StationFeatures`, `Brand`, `FuelType`, `FuelLog`, `Favorite`, `Failure` (DATA_MODEL.md 참조)
- `build_runner` 실행해서 코드 생성

**Task 1-1-2: Hive TypeAdapter 등록**
- 각 모델에 `@HiveType` 어노테이션
- `main.dart`에서 registerAdapter

**Task 1-1-3: Repository 인터페이스 작성**
- `domain/repositories/`에 추상 클래스 3개 (GasStation, Favorite, FuelLog)

### Day 1-2~3: 오피넷 API 연동 (화~수)

**Task 1-2-1: OpinetRemoteDataSource 구현**
- `/aroundAll.do` 호출 메서드
- `/detailById.do` 호출 메서드
- `/avgSidoPrice.do` 호출 메서드
- 응답 DTO → 도메인 Entity 변환

**Task 1-2-2: 좌표 변환 로직 (KATEC ↔ WGS84)**
- `core/utils/coordinate_converter.dart`
- `proj4dart` 패키지 활용
- 단위 테스트 작성 (알려진 좌표로 검증)

**Task 1-2-3: GasStationLocalDataSource 구현 (Hive 캐시)**
- `CachedResult<T>` 래퍼로 TTL 관리
- 조회 시 `isFresh` 체크

**Task 1-2-4: GasStationRepositoryImpl 구현**
- Cache-first 전략
- Either<Failure, T> 패턴 적용 (`dartz` 또는 직접 구현)

**Task 1-2-5: Riverpod Provider 작성**
- `gas_station_providers.dart`
- `nearbyStationsProvider` (FutureProvider.family)

**🚦 Checkpoint 1:** 단위 테스트에서 API 호출 성공하면 OK

### Day 1-4~5: 지도 화면 (목~금)

**Task 1-4-1: 위치 권한 처리**
- `geolocator`로 권한 요청
- 거부 시 처리 플로우
- `PermissionProvider` 작성

**Task 1-4-2: 네이버 지도 통합**
- `flutter_naver_map` 초기화
- 현재 위치 기반 카메라 이동

**Task 1-4-3: 커스텀 마커 구현**
- 가격 표시 마커 (Canvas로 그리기 또는 Flutter 위젯 → 이미지 변환)
- 최저가/일반/초과 3가지 스타일

**Task 1-4-4: 마커 탭 시 바텀시트**
- `showModalBottomSheet` 또는 `DraggableScrollableSheet`
- 주유소 요약 카드 표시

**Task 1-4-5: PriceBanner 위젯**
- 지역 평균 + 정부 최고가 비교 배너

**🚦 Checkpoint 2:** 지도에 주유소 마커가 가격과 함께 표시되면 OK

### Day 1-6~7: 리스트 + 상세 (토~일)

**Task 1-6-1: 리스트 뷰 화면**
- `ListView.builder` + `StationCard` 위젯
- 정렬 토글, 브랜드 필터, 유종 필터
- Pull-to-refresh

**Task 1-6-2: 필터 상태 관리**
- `StationFilter` 모델
- `filterProvider` (StateNotifier)

**Task 1-6-3: 주유소 상세 화면**
- Hero 애니메이션 (리스트 → 상세)
- 유종별 가격 테이블
- 정부 최고가 대비 표시

**Task 1-6-4: 외부 앱 연동**
- 전화: `tel:` 스킴
- 길찾기: 네이버/T맵 앱 스킴 + 폴백

**🚦 Checkpoint 3:** 지도/리스트/상세 3화면이 자연스럽게 연결되면 Week 1 완료

---

## Week 2: 개인화 기능 (즐겨찾기 + 기록 + 통계)

### Day 2-1~2: 즐겨찾기 (월~화)

**Task 2-1-1: FavoriteRepository 구현**
- Hive Box 기반 CRUD
- `watchAll()` Stream으로 실시간 반영

**Task 2-1-2: 즐겨찾기 추가/제거 UI**
- 상세 화면 별 아이콘
- 상태 변경 시 토스트

**Task 2-1-3: 즐겨찾기 화면**
- 리스트 뷰 (StationCard 재활용)
- 빈 상태 UI

**Task 2-1-4: 즐겨찾기 가격 자동 갱신**
- 앱 포그라운드 진입 시 각 즐겨찾기의 현재 가격 재조회
- 직전 저장 가격과 비교 후 변동 계산

### Day 2-3~4: 주유 기록 (수~목)

**Task 2-3-1: FuelLogRepository 구현**
- CRUD + 월별 조회 + MonthlyStats 계산

**Task 2-3-2: 주유 기록 추가 모달**
- 주유소 선택 (검색 또는 즐겨찾기 리스트)
- 금액 입력 시 리터 자동 계산
- 주행거리 입력 시 연비 자동 계산 (직전 기록 참조)

**Task 2-3-3: 기록 리스트 화면**
- 날짜별 그룹핑 (`SliverList` + 헤더)
- 스와이프 삭제

**Task 2-3-4: 기록 수정**
- 동일 모달 재활용 + 초기값 채우기

### Day 2-5~6: 통계 (금~토)

**Task 2-5-1: MonthlyStats 계산 로직**
- 총 지출, 총 주유량, 평균 단가, 평균 연비

**Task 2-5-2: Bar Chart (최근 6개월 지출)**
- `fl_chart` BarChart 적용

**Task 2-5-3: Line Chart (평균 단가 추이)**
- `fl_chart` LineChart 적용

**Task 2-5-4: 월 전환 드롭다운**

### Day 2-7: 설정 + 수동 지역 선택 (일)

**Task 2-7-1: 설정 화면 구현**
- 주 사용 유종, 검색 반경, 알림 설정

**Task 2-7-2: 수동 지역 선택 화면**
- 시도/시군구 2-Depth 드롭다운
- 선택값 저장 (SharedPreferences)
- 해당 지역 주유소 조회 플로우

**🚦 Checkpoint 4:** 모든 P0 기능이 동작하면 Week 2 완료

---

## Week 3: 고도화 + 배포 + 포폴

### Day 3-1~2: 홈 위젯 (월~화) ⭐ 면접 어필 포인트

**Task 3-1-1: home_widget 패키지 통합**
- Flutter 측 데이터 저장 로직

**Task 3-1-2: Android Native 위젯 구현 (Kotlin)**
- `android/app/src/main/kotlin/.../FuelKeeperWidget.kt`
- `AppWidgetProvider` 상속
- 레이아웃 XML 작성 (Small, Medium)

**Task 3-1-3: 위젯 업데이트 로직**
- 30분 주기 업데이트 (WorkManager)
- 앱 데이터 변경 시 강제 업데이트

**Task 3-1-4: 딥링크 처리**
- 위젯 탭 → 해당 주유소 상세 화면

**💡 이 과정이 포폴 Challenge #1의 재료가 된다.**

### Day 3-3: 로컬 알림 (수)

**Task 3-3-1: flutter_local_notifications 셋업**
- 권한 요청, 채널 등록

**Task 3-3-2: 가격 변동 감지 로직**
- 즐겨찾기 가격 재조회 시 차이 계산
- ±20원 이상 변동 시 알림 발송

**Task 3-3-3: 알림 탭 핸들러**
- 딥링크로 주유소 상세로 이동

### Day 3-4: 온보딩 + 정부 배너 (목)

**Task 3-4-1: 온보딩 3개 페이지**
- `PageView` + 일러스트 (Duct Tape/Nano Banana로 생성한 이미지)
- 마지막 페이지에서 위치 권한 요청

**Task 3-4-2: 최초 실행 플래그 관리**
- SharedPreferences

**Task 3-4-3: 정부 최고가격 배너**
- 홈 상단에 하드코딩된 배너
- 탭 시 FAQ 모달

### Day 3-5: 테스트 + 에러 처리 (금)

**Task 3-5-1: 주요 UseCase 단위 테스트 5개**
- `GetNearbyStations`, `AddFuelLog`, `GetMonthlyStats` 등

**Task 3-5-2: Widget 테스트 (StationCard)**

**Task 3-5-3: 전역 에러 핸들링**
- `ErrorView` 위젯 공통화
- Failure 종류별 UI 분기

**Task 3-5-4: 오프라인 UX 점검**
- 캐시 뱃지 표시
- "마지막 업데이트 N분 전"

### Day 3-6: 폴리싱 + 빌드 (토)

**Task 3-6-1: 애니메이션 추가**
- 화면 전환, 가격 Count-up, Shimmer 로딩

**Task 3-6-2: 앱 아이콘 + 스플래시**
- `flutter_launcher_icons` 패키지
- 스플래시: `flutter_native_splash`

**Task 3-6-3: Release 빌드**
```bash
flutter build apk --release --split-per-abi
```

**Task 3-6-4: Firebase App Distribution 업로드**
- 또는 GitHub Release로 APK 배포

**Task 3-6-5: 지인 5명에게 APK 전달 + 피드백 수집**

### Day 3-7: 포트폴리오 작성 (일) ⭐

**Task 3-7-1: 데모 영상 촬영**
- 스크린 레코드 (에뮬레이터 또는 실기기)
- 30초~1분짜리 주요 기능 쇼케이스

**Task 3-7-2: README.md 작성 (GitHub)**
- 프로젝트 소개
- 스크린샷
- 기술 스택 + 아키텍처 다이어그램
- 실행 방법
- 트러블슈팅 기록

**Task 3-7-3: 포트폴리오 PDF 작성**
- 기존 포폴 양식 재활용
- 페이지 구성:
  1. 표지 (앱 아이콘 + 슬로건)
  2. 서비스 스크린샷 (Duct Tape로 목업 생성)
  3. 프로젝트 소개 (유가 급등 맥락 + 솔루션)
  4. 기술 스택
  5. 핵심 기능 1 (지도 + API)
  6. 핵심 기능 2 (주유 기록)
  7. 핵심 기능 3 (홈 위젯 + 알림)
  8. Challenge #1: KATEC ↔ WGS84 좌표 변환
  9. Challenge #2: Flutter ↔ Android 네이티브 브릿지 (홈 위젯)
  10. Challenge #3: API 쿼터 관리 + 캐싱 전략
  11. 배운 점

**Task 3-7-4: 랜딩 페이지 (선택)**
- 간단한 원페이지 HTML (Vercel 배포)
- 앱 소개 + APK 다운로드 링크 + 스크린샷

**🎯 최종 산출물:**
- [ ] 동작하는 APK 파일
- [ ] GitHub 리포 (README 포함)
- [ ] 포트폴리오 PDF (12~15페이지)
- [ ] 데모 영상 (1분 이내)
- [ ] (선택) 랜딩 페이지

---

## 일정 관리 팁

### 매일 루틴
1. 전날 남긴 TODO 확인
2. 오늘 목표 1~2개 Task 선택
3. Cursor에서 해당 섹션 문서 열고 작업
4. 커밋 + 푸시 + 다음 TODO 기록

### 주간 회고
- 일요일 저녁: 이번 주 달성한 것 / 밀린 것 정리
- 밀린 Task가 있으면 P2는 과감히 드롭

### Blocker 대응
- 오피넷 API 지연 → 공공데이터포털 API로 임시 대체
- 네이버 지도 이슈 → Google Maps로 폴백 (최후의 수단)
- 홈 위젯 구현 난이도 높음 → v1에서 제외하고 P2 기능으로 이동

### 절대 하지 말 것
- ❌ 디자인에 3일 이상 쓰기 (Cursor에게 맡겨라)
- ❌ iOS 빌드 시도 (시간 낭비)
- ❌ 백엔드 서버 구축 (범위 초과)
- ❌ 새로운 기술 학습 (이미 써본 기술로만)

---

## Cursor 활용 팁

### 효율적인 프롬프트 템플릿

**기능 구현 시:**
```
@FEATURES.md @DATA_MODEL.md

F-01 주변 주유소 지도 탐색 기능을 구현해줘.
- GasStationRepository는 이미 구현되어 있음
- map_page.dart를 완성
- 커스텀 마커는 PriceMarker 위젯으로 분리
- Riverpod FutureProvider로 데이터 구독
```

**문제 해결 시:**
```
@TECH_STACK.md

KATEC 좌표계를 WGS84로 변환하는 로직에서 부정확한 결과가 나와.
proj4dart로 구현한 코드인데 확인 부탁.

[코드 붙여넣기]
```

**리팩토링 시:**
```
@TECH_STACK.md

gas_station_repository_impl.dart를 Clean Architecture 원칙에 맞게 
리팩토링해줘. 현재 코드에서 Domain 레이어와 Data 레이어가 섞여 있음.
```

---

## 일정 지연 시 우선순위 조정

**1주 지연 시:**
- F-08 홈 위젯 → v1.1로 연기
- 대신 주유 기록에 집중해 완성도 높이기

**2주 지연 시:**
- F-05 가격 변동 알림 → 드롭
- F-07 통계 → 간소화 (요약 카드만 유지)

**핵심 방어선:**
- F-01 지도, F-02 리스트, F-03 상세, F-06 주유 기록은 절대 포기하지 않는다.
- 이 4개 + 포폴 PDF 만 있어도 완성도 있는 프로젝트다.
