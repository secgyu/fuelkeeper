# 우리 앱 전용 R8 규칙.
# Flutter / 의존성의 기본 규칙은 각 패키지의 consumer-rules.pro에서 자동 머지.

# Hive: 우리는 TypeAdapter를 직접 작성해서 reflection을 쓰지 않으므로 별도 규칙 불필요.
# Riverpod 3.x도 코드 생성/리플렉션을 사용하지 않으므로 추가 규칙 불필요.
# flutter_local_notifications / dio 등은 자체 consumer-rules.pro 보유.

# Naver Map SDK (com.naver.maps.map 3.23.0).
# flutter_naver_map 1.4.4가 consumer-rules.pro를 동봉하지 않고,
# Naver Map AAR의 기본 keep 규칙은 Activity/위젯 위주여서
# NcpKeyClient / NaverCloudPlatformClient 같은 인증 클라이언트와
# internal.http / internal.net / internal.FileSource 등 타일 로더가
# R8에 의해 dead code로 판단되어 통째로 제거된다.
# (release 빌드에서 마커는 그려지는데 타일만 회색 격자로 뜨는 정확한 원인.)
# 내부 패키지 구조가 SDK 마이너 버전마다 바뀌므로 안전하게 광범위 keep 한다.
-keep class com.naver.maps.** { *; }
-keep interface com.naver.maps.** { *; }
-dontwarn com.naver.maps.**

# Naver Map SDK가 내부적으로 OkHttp를 사용하므로 같이 보호.
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# 안전장치: split-compat / window-resize 등에서 R8가 너무 공격적으로 제거하는 경우를 대비.
-keepattributes *Annotation*,Signature,EnclosingMethod,InnerClasses

# Stack trace 가독성(라인 번호) 유지.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
