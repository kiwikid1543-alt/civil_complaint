// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cso_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repository 주입을 위한 Provider

@ProviderFor(csoRepository)
const csoRepositoryProvider = CsoRepositoryProvider._();

/// Repository 주입을 위한 Provider

final class CsoRepositoryProvider
    extends $FunctionalProvider<CsoRepository, CsoRepository, CsoRepository>
    with $Provider<CsoRepository> {
  /// Repository 주입을 위한 Provider
  const CsoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'csoRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$csoRepositoryHash();

  @$internal
  @override
  $ProviderElement<CsoRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CsoRepository create(Ref ref) {
    return csoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CsoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CsoRepository>(value),
    );
  }
}

String _$csoRepositoryHash() => r'af28b3bdc64a60a9890a5ab630521a0997a3e479';
