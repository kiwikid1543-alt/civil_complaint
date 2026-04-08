import '../../core/result.dart';
import '../entities/cso_info.dart';
import '../entities/cso_status.dart';

/// 민원실 데이터를 가져오기 위한 저장소 인터페이스
abstract class CsoRepository {
  /// 모든 관공서 기본 정보 목록을 반환
  Future<Result<List<CsoInfo>, AppFailure>> getAllCsoList();

  /// 전체 민원실의 실시간 현황 및 혼잡도 정보 리스트 조회 (지도 표시용)
  Future<Result<List<CsoStatus>, AppFailure>> getAllCsoStatus();

  /// 특정 민원실의 실시간 현황 및 업무별 대기 인원 조회
  Future<Result<CsoStatus, AppFailure>> getCsoStatus(String csoSn);
}
