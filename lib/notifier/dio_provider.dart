import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/config/api_config.dart';

part 'dio_provider.g.dart';

/// 앱 전역에서 사용할 Dio 싱글톤 인스턴스 제공자
@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 공공데이터포털 공통 파라미터 Interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // API 모든 요청에 서비스 키와 JSON 포맷 요청을 강제로 주입합니다.
      options.queryParameters.addAll({
        'serviceKey': ApiConfig.serviceKey,
        'returnType': 'JSON',
        'type': 'json',
      });
      return handler.next(options);
    },
  ));

  // 로그를 출력하여 무한로딩/에러 원인 파악
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}
