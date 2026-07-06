// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LaunchNotifier)
final launchProvider = LaunchNotifierProvider._();

final class LaunchNotifierProvider
    extends $AsyncNotifierProvider<LaunchNotifier, LaunchDestination> {
  LaunchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchNotifierHash();

  @$internal
  @override
  LaunchNotifier create() => LaunchNotifier();
}

String _$launchNotifierHash() => r'40099ccc64dd8eac0680156d7f52c4fc6920a228';

abstract class _$LaunchNotifier extends $AsyncNotifier<LaunchDestination> {
  FutureOr<LaunchDestination> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LaunchDestination>, LaunchDestination>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LaunchDestination>, LaunchDestination>,
              AsyncValue<LaunchDestination>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
