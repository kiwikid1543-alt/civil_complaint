// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'congestion_analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 시간대별 혼잡도 통계를 제공하는 Provider
/// [csoSn]: 대상 민원실 일련번호
/// 오늘 요일을 자동 감지하여 해당 요일의 통계 데이터를 반환

@ProviderFor(congestionAnalytics)
const congestionAnalyticsProvider = CongestionAnalyticsFamily._();

/// 시간대별 혼잡도 통계를 제공하는 Provider
/// [csoSn]: 대상 민원실 일련번호
/// 오늘 요일을 자동 감지하여 해당 요일의 통계 데이터를 반환

final class CongestionAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HourlyCongestion>>,
          List<HourlyCongestion>,
          FutureOr<List<HourlyCongestion>>
        >
    with
        $FutureModifier<List<HourlyCongestion>>,
        $FutureProvider<List<HourlyCongestion>> {
  /// 시간대별 혼잡도 통계를 제공하는 Provider
  /// [csoSn]: 대상 민원실 일련번호
  /// 오늘 요일을 자동 감지하여 해당 요일의 통계 데이터를 반환
  const CongestionAnalyticsProvider._({
    required CongestionAnalyticsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'congestionAnalyticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$congestionAnalyticsHash();

  @override
  String toString() {
    return r'congestionAnalyticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HourlyCongestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HourlyCongestion>> create(Ref ref) {
    final argument = this.argument as String;
    return congestionAnalytics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CongestionAnalyticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$congestionAnalyticsHash() =>
    r'67df73137d9a8f072d4d01f865928eb816ba4e5a';

/// 시간대별 혼잡도 통계를 제공하는 Provider
/// [csoSn]: 대상 민원실 일련번호
/// 오늘 요일을 자동 감지하여 해당 요일의 통계 데이터를 반환

final class CongestionAnalyticsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HourlyCongestion>>, String> {
  const CongestionAnalyticsFamily._()
    : super(
        retry: null,
        name: r'congestionAnalyticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 시간대별 혼잡도 통계를 제공하는 Provider
  /// [csoSn]: 대상 민원실 일련번호
  /// 오늘 요일을 자동 감지하여 해당 요일의 통계 데이터를 반환

  CongestionAnalyticsProvider call(String csoSn) =>
      CongestionAnalyticsProvider._(argument: csoSn, from: this);

  @override
  String toString() => r'congestionAnalyticsProvider';
}
