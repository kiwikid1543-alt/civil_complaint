// lib/models/repositories/congestion_analytics_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/hourly_congestion.dart';

/// 혼잡도 통계 분석을 위한 Firestore 조회 레포지토리
class CongestionAnalyticsRepository {
  final FirebaseFirestore _firestore;

  // 신뢰할 수 있는 통계로 판단하기 위한 최소 데이터 수 기준
  static const int _minDataPointsForStats = 3;

  // 운영 시간대 (8시~20시)
  static const int _operationStartHour = 8;
  static const int _operationEndHour = 20;

  CongestionAnalyticsRepository(this._firestore);

  /// [csoSn]: 민원실 일련번호 (ex: "CS0005")
  /// [dayOfWeek]: 요일 (1: 월요일 ~ 7: 일요일)
  /// 반환값: 시간대별 혼잡 비율 리스트. 데이터 부족 시 isFallback=true인 임시 데이터를 반환.
  Future<List<HourlyCongestion>> getHourlyCongestion({
    required String csoSn,
    required int dayOfWeek,
  }) async {
    try {
      // 특정 민원실 + 특정 요일 기준으로 Firestore 쿼리
      final snapshot = await _firestore
          .collection('congestion_logs')
          .where('csoSn', isEqualTo: csoSn)
          .where('dayOfWeek', isEqualTo: dayOfWeek)
          .orderBy('timestamp', descending: false)
          .get();

      // 최소 데이터 기준에 미달하면 임시 데이터 반환
      if (snapshot.docs.length < _minDataPointsForStats) {
        return _fallbackData();
      }

      // 시간대별(hour)로 데이터 그룹핑 및 평균 대기 인원 계산
      final Map<int, List<int>> hourlyWaitCounts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timeSlot = data['timeSlot'] as String? ?? '09:00';
        final waitCount = (data['totalWaitingCount'] as num?)?.toInt() ?? 0;

        // "08:15" → 8
        final hour = int.tryParse(timeSlot.split(':').first) ?? 9;

        // 운영 시간 외 데이터 제외
        if (hour < _operationStartHour || hour > _operationEndHour) continue;

        hourlyWaitCounts.putIfAbsent(hour, () => []).add(waitCount);
      }

      if (hourlyWaitCounts.isEmpty) return _fallbackData();

      // 시간대별 평균 대기 인원 계산
      final Map<int, double> hourlyAvgCounts = {};
      for (final entry in hourlyWaitCounts.entries) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        hourlyAvgCounts[entry.key] = avg;
      }

      // 정규화: 가장 높은 평균값을 1.0로 기준 삼아 0.0 ~ 1.0 비율로 변환
      final maxAvg = hourlyAvgCounts.values.reduce((a, b) => a > b ? a : b);

      // 최대값이 0이면 모두 여유 상태
      if (maxAvg == 0) {
        return _buildHoursInRange().map((hour) => HourlyCongestion(
          hour: hour,
          congestionRate: 0.05, // 완전히 0이면 막대가 안 보이므로 최소값 설정
        )).toList();
      }

      // 운영 시간 전체를 채워 반환 (데이터가 없는 시간대는 0으로)
      return _buildHoursInRange().map((hour) {
        final avg = hourlyAvgCounts[hour] ?? 0.0;
        return HourlyCongestion(
          hour: hour,
          congestionRate: (avg / maxAvg).clamp(0.0, 1.0),
        );
      }).toList();
    } catch (e) {
      // 오류 발생 시 임시 데이터로 안전하게 Fallback
      return _fallbackData();
    }
  }

  /// 08 ~ 20시 사이 각 정시(hour) 정수 리스트 반환
  List<int> _buildHoursInRange() {
    return List.generate(
      _operationEndHour - _operationStartHour + 1,
      (i) => _operationStartHour + i,
    );
  }

  /// 데이터 부족 시 사용할 임시(Fallback) 데이터
  List<HourlyCongestion> _fallbackData() {
    return const [
      HourlyCongestion(hour: 8,  congestionRate: 0.20, isFallback: true),
      HourlyCongestion(hour: 9,  congestionRate: 0.30, isFallback: true),
      HourlyCongestion(hour: 10, congestionRate: 0.55, isFallback: true),
      HourlyCongestion(hour: 11, congestionRate: 0.75, isFallback: true),
      HourlyCongestion(hour: 12, congestionRate: 0.90, isFallback: true),
      HourlyCongestion(hour: 13, congestionRate: 0.60, isFallback: true),
      HourlyCongestion(hour: 14, congestionRate: 0.85, isFallback: true),
      HourlyCongestion(hour: 15, congestionRate: 0.70, isFallback: true),
      HourlyCongestion(hour: 16, congestionRate: 0.45, isFallback: true),
      HourlyCongestion(hour: 17, congestionRate: 0.35, isFallback: true),
      HourlyCongestion(hour: 18, congestionRate: 0.20, isFallback: true),
      HourlyCongestion(hour: 19, congestionRate: 0.15, isFallback: true),
      HourlyCongestion(hour: 20, congestionRate: 0.10, isFallback: true),
    ];
  }
}
