
import 'package:flutter/foundation.dart';
import 'cso_info.dart';

/// 민원실의 전체 대기 현황을 나타내는 엔티티
@immutable
class CsoStatus {
  final String csoNm;
  final int totalWaitingCount;
  final int expectedWaitTimeMinutes;
  final CongestionLevel congestionLevel;
  final int operatingWindows;
  final double avgWaitingPerWindow;
  final List<CsoTaskStatus> taskStatuses;
  final DateTime updatedAt;

  // 선택적 부가 정보 (위치, 운영 시간 등)
  final CsoInfo? locationInfo;

  const CsoStatus({
    required this.csoNm,
    required this.totalWaitingCount,
    required this.expectedWaitTimeMinutes,
    required this.congestionLevel,
    required this.operatingWindows,
    required this.avgWaitingPerWindow,
    required this.updatedAt,
    this.taskStatuses = const [],
    this.locationInfo,
  });

  /// Pure Dart Entity의 불변성을 위한 copyWith 메서드
  CsoStatus copyWith({
    String? csoNm,
    int? totalWaitingCount,
    int? expectedWaitTimeMinutes,
    CongestionLevel? congestionLevel,
    int? operatingWindows,
    double? avgWaitingPerWindow,
    List<CsoTaskStatus>? taskStatuses,
    DateTime? updatedAt,
  }) {
    return CsoStatus(
      csoNm: csoNm ?? this.csoNm,
      totalWaitingCount: totalWaitingCount ?? this.totalWaitingCount,
      expectedWaitTimeMinutes: expectedWaitTimeMinutes ?? this.expectedWaitTimeMinutes,
      congestionLevel: congestionLevel ?? this.congestionLevel,
      operatingWindows: operatingWindows ?? this.operatingWindows,
      avgWaitingPerWindow: avgWaitingPerWindow ?? this.avgWaitingPerWindow,
      taskStatuses: taskStatuses ?? this.taskStatuses,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 더미 데이터를 생성하기 위한 팩토리 메서드 (임시)
  factory CsoStatus.mock() {
    return CsoStatus(
      csoNm: '중구청',
      totalWaitingCount: 26,
      expectedWaitTimeMinutes: 18,
      congestionLevel: CongestionLevel.low,
      operatingWindows: 8,
      avgWaitingPerWindow: 3.2,
      updatedAt: DateTime.now(),
      taskStatuses: const [
        CsoTaskStatus(taskNm: '여권발급', waitingCount: 12),
        CsoTaskStatus(taskNm: '가족관계등록', waitingCount: 5),
        CsoTaskStatus(taskNm: '주민등록/인감', waitingCount: 9),
      ],
    );
  }
}

/// 업무별 상세 대기 현황 엔티티
@immutable
class CsoTaskStatus {
  final String taskNm;
  final int waitingCount;

  const CsoTaskStatus({
    required this.taskNm,
    required this.waitingCount,
  });

  CsoTaskStatus copyWith({
    String? taskNm,
    int? waitingCount,
  }) {
    return CsoTaskStatus(
      taskNm: taskNm ?? this.taskNm,
      waitingCount: waitingCount ?? this.waitingCount,
    );
  }
}

/// 혼잡도 단계
enum CongestionLevel {
  low('여유'),
  medium('보통'),
  high('혼잡'),
  unknown('알 수 없음');

  final String label;
  const CongestionLevel(this.label);
}
