
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

  /// 현재 실시간으로 업무가 진행 중인지 판별하는 게터
  bool get isOperatingNow {
    final now = DateTime.now();
    final info = locationInfo;
    
    // 위치 정보가 없는 경우 기본적으로 데이터 노출 (데이터 유실 방지)
    if (info == null) return true;

    // 1. 기본 평일 운영 (09:00 ~ 18:00)
    final isWeekday = now.weekday >= 1 && now.weekday <= 5;
    final currentTimeValue = now.hour * 100 + now.minute; // HHmm 포맷으로 변환 (ex: 18:30 -> 1830)

    if (isWeekday) {
      // 야간 운영 지점의 경우 21:00까지 허용
      final endTime = info.isNightOperating ? 2100 : 1800;
      if (currentTimeValue >= 0900 && currentTimeValue < endTime) {
        return true;
      }
    } else {
      // 2. 주말 운영 지점 (토/일 중 운영하는 경우, 통상 09:00~13:00 혹은 18:00 기준)
      // 정확한 상세 시간이 없으므로 주말 운영 플래그가 있으면 09:00 ~ 18:00 사이 노출 허용
      if (info.isWeekendOperating && currentTimeValue >= 0900 && currentTimeValue < 1800) {
        return true;
      }
    }

    return false;
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
