import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/entities/cso_status.dart';
import 'cso_repository_provider.dart';

part 'all_cso_congestion_provider.g.dart';

@riverpod
class AllCsoCongestion extends _$AllCsoCongestion {
  @override
  Future<List<CsoStatus>> build() async {
    final repository = ref.watch(csoRepositoryProvider);
    final result = await repository.getAllCsoStatus();

    if (result.isSuccess) {
      return result.valueOrNull ?? [];
    } else {
      throw Exception(result.errorOrNull?.message ?? '지도 데이터를 불러오는 데 실패했습니다.');
    }
  }

  /// 새로고침 (수동으로 데이터 갱신이 필요할 때 사용)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(csoRepositoryProvider);
      final result = await repository.getAllCsoStatus();
      if (result.isSuccess) {
        return result.valueOrNull ?? [];
      } else {
        throw Exception(
            result.errorOrNull?.message ?? '지도 데이터를 새로고침하는 데 실패했습니다.');
      }
    });
  }
}
