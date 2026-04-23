# FuelKeeper 📍⛽

> "오늘, 가장 싸게 넣자"  
> 실시간 주유소 가격 비교 + 주유 가계부 Flutter 앱

## 📚 문서 구조

이 프로젝트를 이해하려면 아래 문서를 **순서대로** 읽어주세요.

1. **[PRD.md](./PRD.md)** — 제품이 왜 존재하는지, 무엇을 해결하는지 (필독)
2. **[FEATURES.md](./FEATURES.md)** — 구현해야 할 기능 명세
3. **[TECH_STACK.md](./TECH_STACK.md)** — 기술 스택 선정 이유 및 아키텍처
4. **[DATA_MODEL.md](./DATA_MODEL.md)** — 데이터 모델, API 명세, 로컬 DB 스키마
5. **[UI_FLOW.md](./UI_FLOW.md)** — 화면 구성, 사용자 플로우, 디자인 가이드
6. **[DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md)** — 3주 개발 일정, 마일스톤

## 🎯 한 줄 요약

> **Flutter + 오피넷 공공 API로 만드는, 지금 가장 시의적절한 주유소 가격 비교 앱**

## 🚀 Cursor 사용 가이드

Cursor AI에게 작업을 시킬 때는 다음과 같이 컨텍스트를 제공하세요.

```
@PRD.md @FEATURES.md 
요구사항을 참고해서 [작업 내용]을 구현해줘.
```

구체적인 파일 구현을 요청할 때는:

```
@TECH_STACK.md @DATA_MODEL.md 
gas_station_repository.dart를 구현해줘.
오피넷 API를 호출하고, Hive로 캐싱하는 로직 포함.
```

## ⚠️ 핵심 원칙

1. **공공 API의 쿼터를 존중한다** — 캐싱 전략 필수
2. **오프라인에서도 최소한의 기능은 돌아간다** — 로컬 DB 기반
3. **운전 중에도 볼 수 있게** — 큰 폰트, 명확한 컬러 대비
4. **프라이버시** — 위치 정보는 서버 전송 없이 기기 내에서만 처리
