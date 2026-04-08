// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_cso_congestion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllCsoCongestion)
const allCsoCongestionProvider = AllCsoCongestionProvider._();

final class AllCsoCongestionProvider
    extends $AsyncNotifierProvider<AllCsoCongestion, List<CsoStatus>> {
  const AllCsoCongestionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCsoCongestionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCsoCongestionHash();

  @$internal
  @override
  AllCsoCongestion create() => AllCsoCongestion();
}

String _$allCsoCongestionHash() => r'f16caad88c8c989a2d8b98b1de9cda27ddea3cbf';

abstract class _$AllCsoCongestion extends $AsyncNotifier<List<CsoStatus>> {
  FutureOr<List<CsoStatus>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<CsoStatus>>, List<CsoStatus>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CsoStatus>>, List<CsoStatus>>,
              AsyncValue<List<CsoStatus>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
