import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/entities/cso_status.dart';
import 'cso_repository_provider.dart';

part 'cso_detail_notifier.g.dart';

/// 민원실 상세 정보를 관리하는 ViewModel
/// Riverpod Generator를 활용하여 AsyncValue를 자동으로 관리합니다.
@riverpod
class CsoDetail extends _$CsoDetail {
  @override
  FutureOr<CsoStatus> build(String csoSn) async {
    // 1. Repository 의존성 획득
    final repository = ref.watch(csoRepositoryProvider);
    
    // 2. 데이터 페칭 시도
    final result = await repository.getCsoStatus(csoSn);
    
    // 3. Result 패턴 처리 (No Throws!)
    return result.fold(
      (status) => status, // 성공 시 데이터 반환
      (failure) => throw Error.safeToString(failure.message), // 에러 시 throw (AsyncValue.error로 변환됨)
    );
  }

  /// 사용자가 필터를 변경하거나 새로고침 할 때 호출
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(csoRepositoryProvider);
      final result = await repository.getCsoStatus(csoSn); // 빌드 시 전달받은 객체의 필드 사용
      return result.fold(
        (status) => status,
        (failure) => throw Error.safeToString(failure.message),
      );
    });
  }
}
