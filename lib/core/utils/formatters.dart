/// 숫자 / 가격 / 거리 / 용량 포맷 헬퍼.
///
/// 앱 전반에서 동일한 표기를 보장하기 위해 한 곳으로 모은 유틸.
library;

class Formatters {
  Formatters._();

  /// 천 단위 콤마 포맷. 예: 1234567 -> "1,234,567"
  static String thousands(num value) {
    final s = value.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remain = s.length - i - 1;
      if (remain > 0 && remain % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  /// "₩ 1,234" 형태의 통화 표기.
  static String currency(num value) => '₩ ${thousands(value)}';

  /// "1,234원" 형태의 단가 표기.
  static String won(num value) => '${thousands(value)}원';

  /// "12.3L" 형태의 용량 표기 (소수 1자리).
  static String liters(double value) => '${value.toStringAsFixed(1)}L';

  /// "1.2km" 형태의 거리 표기 (소수 1자리).
  static String km(double value) => '${value.toStringAsFixed(1)}km';

  /// "13.4km/L" 형태의 연비 표기 (소수 1자리).
  static String efficiency(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(1)}km/L';

  /// "2024.05.13" 형태의 날짜 표기.
  static String date(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}.$mm.$dd';
  }
}
