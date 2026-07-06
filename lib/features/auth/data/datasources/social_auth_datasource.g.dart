// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_auth_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialAuthDatasource)
final socialAuthDatasourceProvider = SocialAuthDatasourceProvider._();

final class SocialAuthDatasourceProvider
    extends
        $FunctionalProvider<
          SocialAuthDatasource,
          SocialAuthDatasource,
          SocialAuthDatasource
        >
    with $Provider<SocialAuthDatasource> {
  SocialAuthDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialAuthDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialAuthDatasourceHash();

  @$internal
  @override
  $ProviderElement<SocialAuthDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialAuthDatasource create(Ref ref) {
    return socialAuthDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialAuthDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialAuthDatasource>(value),
    );
  }
}

String _$socialAuthDatasourceHash() =>
    r'da2bca9a7b7c553924f058f30015434d843cb695';
