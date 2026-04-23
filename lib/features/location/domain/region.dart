class Region {
  const Region({
    required this.id,
    required this.sido,
    required this.gugun,
    required this.dong,
  });

  final String id;
  final String sido;
  final String gugun;
  final String dong;

  String get short => '$gugun $dong';
  String get full => '$sido $gugun $dong';
}

const kMockRegions = <Region>[
  Region(id: 'seoul-gn-yeoksam', sido: '서울특별시', gugun: '강남구', dong: '역삼동'),
  Region(id: 'seoul-gn-nonhyeon', sido: '서울특별시', gugun: '강남구', dong: '논현동'),
  Region(id: 'seoul-gn-samseong', sido: '서울특별시', gugun: '강남구', dong: '삼성동'),
  Region(id: 'seoul-sc-seocho', sido: '서울특별시', gugun: '서초구', dong: '서초동'),
  Region(id: 'seoul-sc-banpo', sido: '서울특별시', gugun: '서초구', dong: '반포동'),
  Region(id: 'seoul-sp-jamsil', sido: '서울특별시', gugun: '송파구', dong: '잠실동'),
  Region(id: 'seoul-sd-sinsa', sido: '서울특별시', gugun: '강남구', dong: '신사동'),
  Region(id: 'seoul-yd-yeouido', sido: '서울특별시', gugun: '영등포구', dong: '여의도동'),
  Region(id: 'seoul-mp-hapjeong', sido: '서울특별시', gugun: '마포구', dong: '합정동'),
  Region(id: 'seoul-jn-myeongdong', sido: '서울특별시', gugun: '중구', dong: '명동'),
];
