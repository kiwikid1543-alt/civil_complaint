// lib/notifier/congestion_analytics_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/entities/hourly_congestion.dart';
import '../models/repositories/congestion_analytics_repository.dart';

part 'congestion_analytics_provider.g.dart';

/// 시간대별 혼잡도 통계를 제공하는 Provider
/// [csoSn]: 대상 민원실 일련번호
/// 오늘 요일을 자동 감지하여 해당 요일의 통계 데이터를 반환
@riverpod
Future<List<HourlyCongestion>> congestionAnalytics(
  Ref ref,
  String csoSn,
) async {
  final repository = CongestionAnalyticsRepository(FirebaseFirestore.instance);
  final today = DateTime.now().weekday; // 1:월요일 ~ 7:일요일

  return repository.getHourlyCongestion(
    csoSn: csoSn,
    dayOfWeek: today,
  );
}
