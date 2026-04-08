class HourlyCongestion {
  final int hour; // 9 ~ 18
  final double congestionRate; // 0.0 ~ 1.0 (비율)
  final bool isFallback; // 데이터 부족으로 인한 임시 데이터 여부

  const HourlyCongestion({
    required this.hour,
    required this.congestionRate,
    this.isFallback = false,
  });
}
