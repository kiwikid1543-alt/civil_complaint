import 'secrets.dart';

class ApiConfig {
  /// 공공데이터포털 Base URL
  static const String baseUrl =
      'https://apis.data.go.kr/B551982/cso_v2';

  /// 공공데이터포털 일반 인증키 (Decoding)
  /// 보안을 위해 secrets.dart 파일에서 관리합니다.
  static const String serviceKey = Secrets.serviceKey;
}
