// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cso_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 민원실 상세 정보를 관리하는 ViewModel
/// Riverpod Generator를 활용하여 AsyncValue를 자동으로 관리합니다.

@ProviderFor(CsoDetail)
const csoDetailProvider = CsoDetailFamily._();

/// 민원실 상세 정보를 관리하는 ViewModel
/// Riverpod Generator를 활용하여 AsyncValue를 자동으로 관리합니다.
final class CsoDetailProvider
    extends $AsyncNotifierProvider<CsoDetail, CsoStatus> {
  /// 민원실 상세 정보를 관리하는 ViewModel
  /// Riverpod Generator를 활용하여 AsyncValue를 자동으로 관리합니다.
  const CsoDetailProvider._({
    required CsoDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'csoDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$csoDetailHash();

  @override
  String toString() {
    return r'csoDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CsoDetail create() => CsoDetail();

  @override
  bool operator ==(Object other) {
    return other is CsoDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$csoDetailHash() => r'fbdac06b66de851d45622e95d2c7ab87ead37b2b';

/// 민원실 상세 정보를 관리하는 ViewModel
/// Riverpod Generator를 활용하여 AsyncValue를 자동으로 관리합니다.

final class CsoDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          CsoDetail,
          AsyncValue<CsoStatus>,
          CsoStatus,
          FutureOr<CsoStatus>,
          String
        > {
  const CsoDetailFamily._()
    : super(
        retry: null,
        name: r'csoDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 민원실 상세 정보를 관리하는 ViewModel
  /// Riverpod Generator를 활용하여 AsyncValue를 자동으로 관리합니다.

  CsoDetailProvider call(String csoSn) =>
      CsoDetailProvider._(argument: csoSn, from: this);

  @override
  String toString() => r'csoDetailProvider';
}

/// 민원실 상세 정보를 관리하는 ViewModel
/// Riverpod Generator를 활용하여 AsyncValue를 자동으로 관리합니다.

abstract class _$CsoDetail extends $AsyncNotifier<CsoStatus> {
  late final _$args = ref.$arg as String;
  String get csoSn => _$args;

  FutureOr<CsoStatus> build(String csoSn);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<CsoStatus>, CsoStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CsoStatus>, CsoStatus>,
              AsyncValue<CsoStatus>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
