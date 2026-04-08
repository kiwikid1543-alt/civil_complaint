
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/repositories/cso_repository.dart';
import '../models/repositories/cso_repository_impl.dart';


import 'dio_provider.dart';

part 'cso_repository_provider.g.dart';

/// Repository 주입을 위한 Provider
@riverpod
CsoRepository csoRepository(Ref ref) {
  final dioClient = ref.watch(dioProvider);
  return CsoRepositoryImpl(dioClient);
}
