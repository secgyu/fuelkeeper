enum SortOrder {
  price('가격순'),
  distance('거리순'),
  brand('브랜드순');

  const SortOrder(this.label);
  final String label;
}
