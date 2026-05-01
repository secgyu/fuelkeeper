enum Sido {
  seoul('01', '서울'),
  gyeonggi('02', '경기'),
  gangwon('03', '강원'),
  chungbuk('04', '충북'),
  chungnam('05', '충남'),
  jeonbuk('06', '전북'),
  jeonnam('07', '전남'),
  gyeongbuk('08', '경북'),
  gyeongnam('09', '경남'),
  busan('10', '부산'),
  jeju('11', '제주'),
  gwangju('14', '광주'),
  daegu('15', '대구'),
  daejeon('16', '대전'),
  ulsan('17', '울산'),
  sejong('18', '세종'),
  incheon('19', '인천');

  const Sido(this.code, this.label);

  final String code;
  final String label;

  static Sido? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim();
    for (final s in values) {
      if (s.code == normalized) return s;
    }
    return null;
  }

  /// 카카오 Local API의 `region_1depth_name` 같은 행정 구역 라벨에서
  /// 가장 비슷한 시·도를 추정한다 ("서울특별시" → seoul, "경상북도" → gyeongbuk 등).
  static Sido? fromRegionName(String? name) {
    if (name == null) return null;
    final n = name.trim();
    if (n.isEmpty) return null;
    for (final s in values) {
      if (n.startsWith(s.label)) return s;
    }

    if (n.contains('서울')) return seoul;
    if (n.contains('부산')) return busan;
    if (n.contains('대구')) return daegu;
    if (n.contains('인천')) return incheon;
    if (n.contains('광주')) return gwangju;
    if (n.contains('대전')) return daejeon;
    if (n.contains('울산')) return ulsan;
    if (n.contains('세종')) return sejong;
    if (n.contains('경기')) return gyeonggi;
    if (n.contains('강원')) return gangwon;
    if (n.contains('충북') || n.contains('충청북')) return chungbuk;
    if (n.contains('충남') || n.contains('충청남')) return chungnam;
    if (n.contains('전북') || n.contains('전라북')) return jeonbuk;
    if (n.contains('전남') || n.contains('전라남')) return jeonnam;
    if (n.contains('경북') || n.contains('경상북')) return gyeongbuk;
    if (n.contains('경남') || n.contains('경상남')) return gyeongnam;
    if (n.contains('제주')) return jeju;
    return null;
  }
}
