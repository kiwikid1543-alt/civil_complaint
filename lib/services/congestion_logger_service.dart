import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/cso_repository_provider.dart';

/// 앱 실행 시 백그라운드에서 주기적으로 혼잡도 데이터를 저장하는 서비스 Provider
final congestionLoggerProvider = Provider<CongestionLoggerService>((ref) {
  return CongestionLoggerService(ref);
});

class CongestionLoggerService {
  final Ref _ref;
  Timer? _timer;
  
  // 파이어베이스 연동 전 에러 방지를 위해 getter 형태로 지연 초기화
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CongestionLoggerService(this._ref);

  void startLogging() {
    print('CongestionLoggerService started: 5분 주기로 데이터 수집을 시작합니다.');
    
    // 시작 시 1회 즉시 실행
    _fetchAndLog();

    // 이후 5분 간격 = 300초
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchAndLog();
    });
  }

  void stopLogging() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchAndLog() async {
    final now = DateTime.now();
    
    // 08:00 (8) ~ 20:59 (20) 사이인지 확인. 아니면 종료
    if (now.hour < 8 || now.hour > 20) {
      print('CongestionLoggerService: 현재 시간(${now.hour}시)은 수집 시간이 아닙니다.');
      return; 
    }

    // 대상 CSO Sn: CS0005(서초구청), CS0041(부산남구), CS0002(광진구청)
    final targets = ['CS0005', 'CS0041', 'CS0002'];
    final repository = _ref.read(csoRepositoryProvider);

    for (var csoSn in targets) {
      try {
        final result = await repository.getCsoStatus(csoSn);
        result.fold(
          (status) async {
            // Task 리스트 추출
            final tasks = status.taskStatuses.map((t) => {
              'taskNm': t.taskNm,
              'waitingCount': t.waitingCount,
            }).toList();

            // 시간대 슬롯 생성 (ex: "08:15", "14:30")
            final minuteSlot = (now.minute ~/ 5 * 5).toString().padLeft(2, '0');
            final timeSlot = '${now.hour.toString().padLeft(2, '0')}:$minuteSlot';

            // Firestore에 문서 추가
            await _firestore.collection('congestion_logs').add({
              'csoSn': csoSn,
              'csoNm': status.csoNm,
              'timestamp': FieldValue.serverTimestamp(),
              'dayOfWeek': now.weekday, // 1~7 (월~일)
              'timeSlot': timeSlot,
              'totalWaitingCount': status.totalWaitingCount,
              'operatingWindows': status.operatingWindows,
              'congestionLevel': status.congestionLevel.name,
              'tasks': tasks,
            });
            
            print('CongestionLoggerService: $csoSn 로그 수집 완료 [$timeSlot]');
          },
          (failure) {
            print('CongestionLoggerService Error: ${failure.message}');
          }
        );
      } catch (e) {
        print('CongestionLoggerService Exception: $e');
      }
    }
  }
}
