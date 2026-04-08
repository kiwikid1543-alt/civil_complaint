// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_cso_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 사용자 위치를 기반으로 가까운 관공서 목록을 반환

@ProviderFor(nearbyCso)
const nearbyCsoProvider = NearbyCsoProvider._();

/// 사용자 위치를 기반으로 가까운 관공서 목록을 반환

final class NearbyCsoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CsoInfo>>,
          List<CsoInfo>,
          FutureOr<List<CsoInfo>>
        >
    with $FutureModifier<List<CsoInfo>>, $FutureProvider<List<CsoInfo>> {
  /// 사용자 위치를 기반으로 가까운 관공서 목록을 반환
  const NearbyCsoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyCsoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyCsoHash();

  @$internal
  @override
  $FutureProviderElement<List<CsoInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CsoInfo>> create(Ref ref) {
    return nearbyCso(ref);
  }
}

String _$nearbyCsoHash() => r'f8b29beee5b23d74090ed4ad3951b2f7cdba2e04';
