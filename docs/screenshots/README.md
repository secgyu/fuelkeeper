# 스크린샷 가이드

루트 README에서 참조하는 6장의 스크린샷을 이 폴더에 추가해주세요.

## 캡처할 화면 (6장)

| 파일명 | 화면 | 권장 캡처 시점 |
| --- | --- | --- |
| `home.png` | 홈 (주유소 리스트) | 가격순 정렬 + 우리동네/전국 평균 배너 보이는 상태 |
| `map.png` | 지도 | 마커 여러 개가 보이는 줌 레벨 |
| `detail.png` | 주유소 상세 | 7일 가격 추이 차트가 보이는 상태 |
| `logs.png` | 주유 로그 | 로그 2~3개 + 월별 그룹핑이 보이는 상태 |
| `stats.png` | 통계 | 월별 지출 막대 차트가 메인으로 |
| `favorites.png` | 즐겨찾기 | 즐겨찾기 1~2개 등록된 상태 |

## 캡처 방법

### Android Emulator
- 사이드바 카메라 아이콘 클릭 → `~/Pictures/`에 저장됨
- 또는 `adb exec-out screencap -p > home.png`

### Android 실기기
- 전원 + 볼륨다운 동시 누르기
- USB로 PC에 옮긴 후 이 폴더로 이동

## 권장 사양
- **해상도**: 1080×2340 정도 (Pixel 5 / 갤럭시 S 기본 에뮬레이터)
- **포맷**: PNG (투명도 X)
- **상태바**: 시간/배터리 등 깔끔하게 (에뮬레이터 데모 모드 권장 — `adb shell settings put global sysui_demo_allowed 1`)

## 데모 GIF (선택)

홈 → 상세 → 로그 추가까지의 짧은 플로우를 GIF로 만들면 임팩트가 큽니다.

```bash
# 안드로이드 화면 녹화 (최대 3분)
adb shell screenrecord /sdcard/demo.mp4
adb pull /sdcard/demo.mp4

# mp4 → gif 변환 (ffmpeg 필요)
ffmpeg -i demo.mp4 -vf "fps=15,scale=320:-1" demo.gif
```
