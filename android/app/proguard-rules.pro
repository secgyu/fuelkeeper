# 우리 앱 전용 R8 규칙.
# Flutter / 의존성의 기본 규칙은 각 패키지의 consumer-rules.pro에서 자동 머지.

# Hive: 우리는 TypeAdapter를 직접 작성해서 reflection을 쓰지 않으므로 별도 규칙 불필요.
# Riverpod 3.x도 코드 생성/리플렉션을 사용하지 않으므로 추가 규칙 불필요.
# Naver Map / flutter_local_notifications / dio 등은 자체 consumer-rules.pro 보유.

# 안전장치: split-compat / window-resize 등에서 R8가 너무 공격적으로 제거하는 경우를 대비.
-keepattributes *Annotation*,Signature,EnclosingMethod,InnerClasses

# Stack trace 가독성(라인 번호) 유지.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
